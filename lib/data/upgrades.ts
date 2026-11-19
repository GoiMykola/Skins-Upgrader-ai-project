import { SkinItem, MOCK_SKINS } from "./skins";
import { withMockMode } from "./mock-mode";

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

const MOCK_LIVE_DROPS: LiveDrop[] = [
  { id: "drop-1", userName: "demo-player", userAvatar: "D", skin: MOCK_SKINS[2], chance: 25.1, timestamp: "щойно" },
  { id: "drop-2", userName: "Kira.exe", userAvatar: "K", skin: MOCK_SKINS[1], chance: 42.0, timestamp: "2 хв тому" },
  { id: "drop-3", userName: "v1per", userAvatar: "V", skin: MOCK_SKINS[3], chance: 12.5, timestamp: "5 хв тому" },
  { id: "drop-4", userName: "n0va", userAvatar: "N", skin: MOCK_SKINS[0], chance: 68.4, timestamp: "12 хв тому" },
];

export async function listLiveDrops(): Promise<LiveDrop[]> {
  return withMockMode(MOCK_LIVE_DROPS);
}

export async function calculateUpgradeChance(inputPrice: number, targetPrice: number): Promise<number> {
  if (targetPrice <= 0) return 0;
  return Math.min(95, Math.max(1, Math.round((inputPrice / targetPrice) * 100 * 10) / 10));
}

export async function executeUpgrade(userId: string, inventoryItemId: string, targetSkinId: string): Promise<UpgradeResult> {
  const targetSkin = MOCK_SKINS.find((s) => s.id === targetSkinId) || MOCK_SKINS[2];
  const chance = 35.5;
  const isSuccess = true;
  return {
    success: isSuccess,
    chance,
    targetSkin,
    message: isSuccess ? "Успішний апгрейд! Предмет додано до інвентаря." : "Апгрейд невдалий, скін втрачено.",
  };
}
