import { SkinItem, MOCK_SKINS } from "./skins";

export type InventoryItem = {
  id: string;
  userId: string;
  skin: SkinItem;
  acquiredAt: string;
  status: "active" | "upgraded" | "destroyed";
};

const userBalances: Record<string, number> = {
  "user-1": 1000,
  "demo-player": 24860,
};

const userInventories: InventoryItem[] = [
  { id: "inv-1", userId: "user-1", skin: MOCK_SKINS[0], acquiredAt: "2026-11-14", status: "active" },
  { id: "inv-2", userId: "user-1", skin: MOCK_SKINS[4], acquiredAt: "2026-11-14", status: "active" },
  { id: "inv-demo-1", userId: "demo-player", skin: MOCK_SKINS[2], acquiredAt: "2026-11-10", status: "active" },
  { id: "inv-demo-2", userId: "demo-player", skin: MOCK_SKINS[3], acquiredAt: "2026-11-12", status: "active" },
];

export async function listUserInventory(userId: string = "user-1"): Promise<InventoryItem[]> {
  return userInventories.filter((i) => i.userId === userId && i.status === "active");
}

export async function getUserBalance(userId: string = "user-1"): Promise<number> {
  return userBalances[userId] ?? 1000;
}

export async function acquireSkin(userId: string, skinId: string): Promise<InventoryItem> {
  const skin = MOCK_SKINS.find((s) => s.id === skinId) || MOCK_SKINS[0];
  const newItem: InventoryItem = {
    id: "inv-" + Date.now(),
    userId,
    skin,
    acquiredAt: new Date().toISOString(),
    status: "active",
  };
  userInventories.push(newItem);
  return newItem;
}
