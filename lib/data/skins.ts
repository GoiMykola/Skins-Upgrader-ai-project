import { withMockMode } from "./mock-mode";

export type SkinItem = {
  id: string;
  name: string;
  weapon: string;
  category: string;
  rarity: string;
  price: number;
  image: string;
};

export const MOCK_SKINS: SkinItem[] = [
  { id: "skin-ak47", name: "Неонова гонка", weapon: "AK-47", category: "Штурмові гвинтівки", rarity: "Засекречена", price: 1250, image: "neon" },
  { id: "skin-awp", name: "Гіперзвір", weapon: "AWP", category: "Снайперські", rarity: "Засекречена", price: 3480, image: "hyper" },
  { id: "skin-howl", name: "Виття", weapon: "M4A4", category: "Штурмові гвинтівки", rarity: "Контрабандний", price: 4980, image: "howl" },
  { id: "skin-knife", name: "Гамма-хвилі", weapon: "Ніж-метелик", category: "Ножі", rarity: "Таємний", price: 9200, image: "gamma" },
  { id: "skin-m4a4", name: "Елітне спорядження", weapon: "M4A4", category: "Штурмові гвинтівки", rarity: "Армійська", price: 890, image: "gold" },
  { id: "skin-ak47-case", name: "Поверхневий гарт", weapon: "AK-47", category: "Штурмові гвинтівки", rarity: "Засекречена", price: 2130, image: "blue" },
];

export async function listSkins(): Promise<SkinItem[]> {
  return withMockMode(MOCK_SKINS);
}

export async function getSkinById(id: string): Promise<SkinItem | null> {
  const skins = await listSkins();
  return skins.find((s) => s.id === id) || null;
}
