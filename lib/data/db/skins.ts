import type { SkinItem } from "@/lib/data/skins";

// ЗАГЛУШКА: реалізація на кроці 13
export async function listSkins(): Promise<SkinItem[]> {
  return [];
}

// ЗАГЛУШКА: реалізація на кроці 13
export async function getSkin(id: string): Promise<SkinItem | null> {
  void id;
  return null;
}

// ЗАГЛУШКА: реалізація на кроці 13
export async function createSkin(input: Omit<SkinItem, "id">): Promise<SkinItem> {
  return { id: "", ...input };
}

// ЗАГЛУШКА: реалізація на кроці 13
export async function deleteSkin(id: string): Promise<void> {
  void id;
}
