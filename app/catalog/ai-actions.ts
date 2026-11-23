"use server";

import { askModel } from "@/lib/ai/model";
import type { ActionResult } from "@/lib/action-result";
import { createSkin } from "@/lib/data/db/skins";
import { revalidatePath } from "next/cache";
import {
  SYSTEM_PROMPT,
  SKIN_SCHEMA,
  checkSkinReply,
  type ValidSkinData,
} from "@/lib/ai/skin-crafter";
import { countMyCallsSince, appCallsToday, recordCall } from "@/lib/data/db/ai-guard";

export async function createAiSkinAction(
  previous: ActionResult | null,
  formData: FormData
): Promise<ActionResult> {
  const prompt = formData.get("prompt");
  if (!prompt || typeof prompt !== "string" || !prompt.trim()) {
    return {
      status: 400,
      fieldErrors: { prompt: "Введіть опис бажаного скіна" },
    };
  }

  const trimmedPrompt = prompt.trim();

  // Т5: Валідація довжини вводу користувача
  if (trimmedPrompt.length > 300) {
    return {
      status: 400,
      fieldErrors: { prompt: "Опис занадто довгий (максимум 300 символів)" },
    };
  }

  // Т2: Перевірка лімітів викликів і витрат (Крок 13)
  const userLimit = Number(process.env.AI_USER_LIMIT_PER_HOUR ?? 20);
  const appLimit = Number(process.env.AI_APP_LIMIT_PER_DAY ?? 100);

  if (userLimit <= 0) {
    return {
      status: 429,
      message: "Вичерпано погодинний ліміт запитів до моделі. Спробуйте пізніше.",
    };
  }

  try {
    const oneHourAgo = new Date(Date.now() - 3600 * 1000).toISOString();
    const userCalls = await countMyCallsSince(oneHourAgo);
    if (userCalls >= userLimit) {
      return {
        status: 429,
        message: "Вичерпано погодинний ліміт запитів до моделі. Спробуйте пізніше.",
      };
    }

    const appCalls = await appCallsToday();
    if (appCalls >= appLimit) {
      return {
        status: 429,
        message: "Вичерпано добовий бюджет застосунку на запити до моделі. Спробуйте завтра.",
      };
    }
  } catch (err) {
    if (userLimit <= 0) {
      return { status: 429, message: "Ліміт вичерпано." };
    }
  }

  let validSkin: ValidSkinData | null = null;
  const maxAttempts = 2; // одна повторна спроба

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      const reply = await askModel({
        system: SYSTEM_PROMPT,
        user: trimmedPrompt,
        jsonSchema: SKIN_SCHEMA,
      });

      const checked = checkSkinReply(reply.text);
      if (checked.ok) {
        validSkin = checked.value;
        await recordCall(false); // фіксуємо платний виклик у базі
        break;
      }
    } catch (err: any) {
      if (attempt === maxAttempts - 1) {
        return {
          status: 503,
          message: err?.message || "Модель недоступна або не відповіла вчасно",
        };
      }
    }
  }

  if (!validSkin) {
    return {
      status: 503,
      message: "Модель відповіла не за схемою або порушила правила генерації.",
    };
  }

  try {
    const newSkin = await createSkin({
      name: validSkin.name,
      weapon: validSkin.weapon,
      category: validSkin.category,
      rarity: validSkin.rarity,
      price: validSkin.price,
      image: validSkin.image,
    });

    revalidatePath("/catalog");
    revalidatePath("/inventory");

    return {
      status: 201,
      message: `Скін «${newSkin.name}» успішно згенеровано моделлю та додано в каталог!`,
      id: newSkin.id,
    };
  } catch (dbError: any) {
    return {
      status: 503,
      message: dbError?.message || "Помилка збереження скіна в базі",
    };
  }
}
