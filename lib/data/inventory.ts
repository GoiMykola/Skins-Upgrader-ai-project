import { SkinItem } from "./skins";

export type InventoryItem = {
  id: string;
  userId: string;
  skin: SkinItem;
  acquiredAt: string;
  status: "active" | "upgraded" | "destroyed";
};

// ЗАГЛУШКА: реалізація на кроці 13
export async function listUserInventory(userId: string): Promise<InventoryItem[]> {
  return [];
}

// ЗАГЛУШКА: реалізація на кроці 13
export async function getUserBalance(userId: string): Promise<number> {
  return 0;
}

// ЗАГЛУШКА: реалізація на кроці 13
export async function acquireSkin(userId: string, skinId: string): Promise<InventoryItem> {
  return {
    id: "",
    userId,
    skin: { id: skinId, name: "", weapon: "", category: "", rarity: "", price: 0, image: "" },
    acquiredAt: new Date().toISOString(),
    status: "active",
  };
}
