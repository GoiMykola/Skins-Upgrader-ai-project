export type SkinInput = {
  name: string;
  weapon: string;
  category: string;
  rarity: string;
  price: number;
  image: string;
};

export type Checked<T> =
  | { ok: true; value: T }
  | { ok: false; fieldErrors: Record<string, string> };

export function checkSkin(formData: FormData): Checked<SkinInput> {
  const name = String(formData.get("name") ?? "").trim();
  const weapon = String(formData.get("weapon") ?? "").trim();
  const category = String(formData.get("category") ?? "").trim();
  const rarity = String(formData.get("rarity") ?? "").trim();
  const priceRaw = String(formData.get("price") ?? "").trim();
  const image = String(formData.get("image") ?? "neon").trim();

  const fieldErrors: Record<string, string> = {};

  if (!name) fieldErrors.name = "Назва скіна обов'язкова.";
  else if (name.length > 100) fieldErrors.name = "Назва — не довше 100 символів.";

  if (!weapon) fieldErrors.weapon = "Тип зброї обов'язковий.";
  if (!category) fieldErrors.category = "Категорія обов'язкова.";
  if (!rarity) fieldErrors.rarity = "Рідкісність обов'язкова.";

  const price = parseInt(priceRaw, 10);
  if (isNaN(price) || price <= 0) {
    fieldErrors.price = "Ціна має бути додатним числом.";
  }

  if (Object.keys(fieldErrors).length > 0) return { ok: false, fieldErrors };
  return { ok: true, value: { name, weapon, category, rarity, price, image } };
}
