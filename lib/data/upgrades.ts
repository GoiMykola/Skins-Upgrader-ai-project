import { SkinItem } from "./skins";

export type LiveDrop = {
  id: string;
  userName: string;
  userAvatar: string;
  skin: SkinItem;
  chance: number;
  timestamp: string;
};

export type UpgradeResult = {
  success: boolean;
  chance: number;
  targetSkin?: SkinItem;
  message: string;
};

// ЗАГЛУШКА: реалізація на кроці 13
export async function listLiveDrops(): Promise<LiveDrop[]> {
  return [];
}

// ЗАГЛУШКА: реалізація на кроці 13
export async function calculateUpgradeChance(inputPrice: number, targetPrice: number): Promise<number> {
  return 0;
}

// ЗАГЛУШКА: реалізація на кроці 13
export async function executeUpgrade(userId: string, inventoryItemId: string, targetSkinId: string): Promise<UpgradeResult> {
  return {
    success: false,
    chance: 0,
    message: "",
  };
}
