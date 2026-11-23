"use server";

import { askModel } from "@/lib/ai/model";
import type { ActionResult } from "@/lib/action-result";
import { createSkin } from "@/lib/data/db/skins";
import { revalidatePath } from "next/cache";

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

  try {
    const systemInstruction = `Ти — генератор унікальних CS скінів для симулятора GoiCoins.
На основі опису користувача придумай скін і поверни ТІЛЬКИ JSON наступного формату без зайвого тексту:
{
  "name": "Назва скіна українською мовою",
  "weapon": "AK-47" (або M4A4, AWP, Desert Eagle, Glock-18, USP-S, Karambit, Butterfly),
  "category": "Гвинтівки" (або Пістолети, Снайперські гвинтівки, Ножі),
  "rarity": "Таємна" (або Засекречена, Заборонена, Військова якість),
  "price": 2500,
  "image": "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=400&auto=format&fit=crop&q=80"
}`;

    // Наївний виклик моделі: без jsonSchema, без timeoutMs, без перевірки лімітів
    const reply = await askModel({
      system: systemInstruction,
      user: prompt.trim(),
    });

    // Наївний парсинг без перевірки схеми
    const skinData = JSON.parse(reply.text);

    const newSkin = await createSkin({
      name: String(skinData.name || "ШІ Скін"),
      weapon: String(skinData.weapon || "AK-47"),
      category: String(skinData.category || "Гвинтівки"),
      rarity: String(skinData.rarity || "Таємна"),
      price: Number(skinData.price) || 1500,
      image: String(
        skinData.image ||
          "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=400&auto=format&fit=crop&q=80"
      ),
    });

    revalidatePath("/catalog");
    revalidatePath("/inventory");

    return {
      status: 201,
      message: `Скін «${newSkin.name}» успішно згенеровано моделлю та додано в каталог!`,
      id: newSkin.id,
    };
  } catch (error: any) {
    return {
      status: 503,
      message: error?.message || "Помилка при виклику мовної моделі",
    };
  }
}
