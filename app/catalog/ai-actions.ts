"use server";

import { createHash } from "node:crypto";
import { revalidatePath } from "next/cache";
import type { ActionResult } from "@/lib/action-result";
import {
  askModel,
  ModelNotConfiguredError,
  ModelTimeoutError,
  ModelUnavailableError,
} from "@/lib/ai/model";
import {
  SYSTEM_PROMPT,
  PROMPT_VERSION,
  SKIN_SCHEMA,
  checkSkinReply,
} from "@/lib/ai/skin-crafter";
import {
  countMyCallsSince,
  appCallsToday,
  recordCall,
  readCache,
  writeCache,
} from "@/lib/data/db/ai-guard";
import { createSkinRecord } from "@/lib/data/db/skins";

// Нормалізація вводу для стабільного ключа кешу
function normalizePrompt(prompt: string): string {
  return prompt.trim().replace(/\s+/g, " ").toLowerCase();
}

// Формування ключа кешу (sha256) від версії промпту, інструкції та нормалізованого вводу
function getCacheKey(normalizedPrompt: string): string {
  return createHash("sha256")
    .update(`${PROMPT_VERSION}:${SYSTEM_PROMPT}:${normalizedPrompt}`)
    .digest("hex");
}

export async function createAiSkinAction(
  _prevState: ActionResult | null,
  formData: FormData
): Promise<ActionResult> {
  const rawPrompt = String(formData.get("prompt") ?? "").trim();

  // 1. Валідація наявності вводу
  if (!rawPrompt) {
    return {
      status: 400,
      message: "Будь ласка, вкажіть опис або ідею скіна",
      fieldErrors: { prompt: "Опис скіна не може бути порожнім" },
    };
  }

  // 2. Валідація довжини вводу (до 300 символів)
  if (rawPrompt.length > 300) {
    return {
      status: 400,
      message: "Занадто довгий опис скіна (максимум 300 символів)",
      fieldErrors: { prompt: "Довжина опису перевищує 300 символів" },
    };
  }

  // 3. Кешування (Крок 14): перевіряємо кеш перед перевіркою лімітів
  const normPrompt = normalizePrompt(rawPrompt);
  const cacheKey = getCacheKey(normPrompt);

  try {
    const cachedReply = await readCache(cacheKey);
    if (cachedReply) {
      const checked = checkSkinReply(cachedReply);
      if (checked.ok) {
        // Фіксуємо безкоштовний виклик із кешу (не витрачає ліміти)
        await recordCall(true);
        const skin = await createSkinRecord(checked.value);
        revalidatePath("/catalog");
        return {
          status: 201,
          message: `Скін "${skin.name}" успішно створено (з кешу)!`,
          id: skin.id,
        };
      }
    }
  } catch (err) {
    console.error("Помилка читання кешу:", err);
  }

  // 4. Перевірка лімітів викликів
  const userLimit = Number(process.env.AI_USER_LIMIT_PER_HOUR || 20);
  const appLimit = Number(process.env.AI_APP_LIMIT_PER_DAY || 100);

  const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
  const userCalls = await countMyCallsSince(oneHourAgo);
  if (userCalls >= userLimit) {
    return {
      status: 429,
      message: `Вичерпано погодинний ліміт генерацій (${userLimit}/год). Зачекайте або поверніться пізніше.`,
    };
  }

  const appCalls = await appCallsToday();
  if (appCalls >= appLimit) {
    return {
      status: 429,
      message: "Вичерпано добовий ліміт генерацій для застосунку. Спробуйте завтра.",
    };
  }

  // 5. Виклик моделі з повторною спробою (retry) та таймаутом
  const maxAttempts = 2;
  let validSkin = null;
  let rawReplyText = "";

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      const reply = await askModel({
        system: SYSTEM_PROMPT,
        user: rawPrompt,
        jsonSchema: SKIN_SCHEMA,
        timeoutMs: 15000,
      });

      const checked = checkSkinReply(reply.text);
      if (checked.ok) {
        validSkin = checked.value;
        rawReplyText = reply.text;
        break;
      }
    } catch (err: unknown) {
      if (attempt === maxAttempts - 1) {
        if (err instanceof ModelTimeoutError) {
          return {
            status: 503,
            message: "Модель не відповіла за 15 секунд. Сервіс перевантажений, спробуйте пізніше.",
          };
        }
        if (err instanceof ModelUnavailableError) {
          return {
            status: 503,
            message: err.message || "Сервіс генерації тимчасово недоступний (код 503). Спробуйте за кілька хвилин.",
          };
        }
        if (err instanceof ModelNotConfiguredError) {
          return {
            status: 503,
            message: "Генерація скінів вимкнена: ключ API провайдера не налаштовано.",
          };
        }
        return {
          status: 503,
          message: err instanceof Error ? err.message : "Помилка при виклику моделі",
        };
      }
    }
  }

  if (!validSkin) {
    return {
      status: 503,
      message: "Модель відповіла не за схемою після повторної спроби. Спробуйте змінити опис.",
    };
  }

  // 6. Фіксація платного виклику моделі
  await recordCall(false);

  // 7. Збереження результату в кеш на 24 години (86400 с)
  try {
    await writeCache(cacheKey, rawReplyText, 86400);
  } catch (err) {
    console.error("Помилка запису в кеш:", err);
  }

  // 8. Створення скіна в базі під обліковим записом гравця
  const skin = await createSkinRecord(validSkin);
  revalidatePath("/catalog");

  return {
    status: 201,
    message: `Скін "${skin.name}" успішно згенеровано ШІ та додано до каталогу!`,
    id: skin.id,
  };
}
