// Схема та валідація для функції на базі моделі "ШІ-Майстерня скінів" (практична робота 6).
export const PROMPT_VERSION = "1.0.0";

export const SYSTEM_PROMPT = `Ти — генератор скінів для симулятора GoiCoins Skin Simulator.
На основі опису користувача створи скін і поверни ТІЛЬКИ JSON за наданою схемою.
Правила гри:
1. weapon: лише одна зі списку дозволених моделей CS.
2. category: Гвинтівки, Пістолети, Снайперські гвинтівки або Ножі.
3. rarity: Ширпотреб, Промислова якість, Військова якість, Заборонена, Засекречена, Таємна або Надзвичайна.
4. price: ціле додатне число від 50 до 50000 GC.
5. У текстових полях суворо заборонено будь-яку HTML-розмітку чи теги (<, >).`;

export const ALLOWED_WEAPONS = [
  "AK-47",
  "M4A4",
  "AWP",
  "Desert Eagle",
  "Glock-18",
  "USP-S",
  "Karambit",
  "Butterfly",
] as const;

export const ALLOWED_RARITIES = [
  "Ширпотреб",
  "Промислова якість",
  "Військова якість",
  "Заборонена",
  "Засекречена",
  "Таємна",
  "Надзвичайна",
] as const;

export const SKIN_SCHEMA = {
  type: "object",
  properties: {
    name: { type: "string" },
    weapon: { type: "string", enum: [...ALLOWED_WEAPONS] },
    category: { type: "string" },
    rarity: { type: "string", enum: [...ALLOWED_RARITIES] },
    price: { type: "integer", minimum: 50, maximum: 50000 },
    image: { type: "string" },
  },
  required: ["name", "weapon", "category", "rarity", "price", "image"],
  additionalProperties: false,
};

export type ValidSkinData = {
  name: string;
  weapon: string;
  category: string;
  rarity: string;
  price: number;
  image: string;
};

export type CheckedReply =
  | { ok: true; value: ValidSkinData }
  | { ok: false; reason: string };

export function checkSkinReply(text: string): CheckedReply {
  let data: unknown;
  try {
    data = JSON.parse(text);
  } catch {
    return { ok: false, reason: "відповідь не є валідним JSON" };
  }

  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return { ok: false, reason: "відповідь не є об'єктом" };
  }

  const obj = data as Record<string, unknown>;
  const required = ["name", "weapon", "category", "rarity", "price", "image"];
  for (const field of required) {
    if (obj[field] === undefined) {
      return { ok: false, reason: `відсутнє обов'язкове поле: ${field}` };
    }
  }

  if (typeof obj.name !== "string" || !obj.name.trim() || obj.name.length > 50) {
    return { ok: false, reason: "невалідна назва скіна" };
  }

  // Дефект Д6: перевірка на розмітку або скрипти в текстових полях
  if (/<|>/.test(obj.name) || (typeof obj.image === "string" && /<|>/.test(obj.image))) {
    return { ok: false, reason: "розмітка або скрипт у текстовому полі" };
  }

  if (typeof obj.weapon !== "string" || !(ALLOWED_WEAPONS as readonly string[]).includes(obj.weapon)) {
    return { ok: false, reason: `невідома модель зброї: ${obj.weapon}` };
  }

  if (typeof obj.rarity !== "string" || !(ALLOWED_RARITIES as readonly string[]).includes(obj.rarity)) {
    return { ok: false, reason: `неприпустима рідкість: ${obj.rarity}` };
  }

  if (
    typeof obj.price !== "number" ||
    !Number.isInteger(obj.price) ||
    obj.price < 50 ||
    obj.price > 50000
  ) {
    return {
      ok: false,
      reason: `неприпустима ціна (має бути ціле число від 50 до 50000 GC): ${obj.price}`,
    };
  }

  if (typeof obj.image !== "string" || !obj.image.trim()) {
    return { ok: false, reason: "невалідне посилання на зображення" };
  }

  return {
    ok: true,
    value: {
      name: obj.name.trim(),
      weapon: obj.weapon,
      category: typeof obj.category === "string" ? obj.category : "Гвинтівки",
      rarity: obj.rarity,
      price: obj.price,
      image: obj.image,
    },
  };
}
