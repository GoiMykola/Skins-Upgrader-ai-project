import { db } from "./client";
import type { SkinItem } from "../skins";

type SkinRow = {
  id: string;
  name: string;
  weapon: string;
  category: string;
  rarity: string;
  price_coins: number;
  image_url: string;
};

function toSkin(row: SkinRow): SkinItem {
  return {
    id: row.id,
    name: row.name,
    weapon: row.weapon,
    category: row.category,
    rarity: row.rarity,
    price: row.price_coins,
    image: row.image_url,
  };
}

export async function listSkins(): Promise<SkinItem[]> {
  const { data, error } = await db()
    .from("skins")
    .select("id, name, weapon, category, rarity, price_coins, image_url");
  if (error) throw new Error(error.message);
  return (data as SkinRow[]).map(toSkin);
}

export async function getSkin(id: string): Promise<SkinItem | null> {
  const { data, error } = await db()
    .from("skins")
    .select("id, name, weapon, category, rarity, price_coins, image_url")
    .eq("id", id)
    .maybeSingle();
  if (error) throw new Error(error.message);
  return data ? toSkin(data as SkinRow) : null;
}

export async function createSkin(input: Omit<SkinItem, "id">): Promise<SkinItem> {
  const { data, error } = await db()
    .from("skins")
    .insert({
      name: input.name,
      weapon: input.weapon,
      category: input.category,
      rarity: input.rarity,
      price_coins: input.price,
      image_url: input.image,
    })
    .select("id, name, weapon, category, rarity, price_coins, image_url")
    .single();
  if (error) throw new Error(error.message);
  return toSkin(data as SkinRow);
}

export async function deleteSkin(id: string): Promise<void> {
  const { error } = await db().from("skins").delete().eq("id", id);
  if (error) throw new Error(error.message);
}
