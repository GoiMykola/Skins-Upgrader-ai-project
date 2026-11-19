export type SkinItem = {
  id: string;
  name: string;
  weapon: string;
  category: string;
  rarity: string;
  price: number;
  image: string;
};

// ЗАГЛУШКА: реалізація на кроці 13
export async function listSkins(): Promise<SkinItem[]> {
  return [];
}

// ЗАГЛУШКА: реалізація на кроці 13
export async function getSkinById(id: string): Promise<SkinItem | null> {
  return null;
}
