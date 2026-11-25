"use client";

import { updateStoredBalance, addSkinToInventory } from "./inventory-storage";

export interface WheelPrize {
  id: string;
  label: string;
  type: "coins" | "skin";
  value: number;
  color: string;
  skin?: {
    name: string;
    weapon: string;
    price: number;
    image: string;
    rarity: string;
    accent: string;
  };
}

export const WHEEL_PRIZES: WheelPrize[] = [
  { id: "p1", label: "100 GC", type: "coins", value: 100, color: "#10b981" },
  { id: "p2", label: "250 GC", type: "coins", value: 250, color: "#059669" },
  { id: "p3", label: "500 GC", type: "coins", value: 500, color: "#06b6d4" },
  { id: "p4", label: "1 000 GC", type: "coins", value: 1000, color: "#3b82f6" },
  { id: "p5", label: "2 500 GC", type: "coins", value: 2500, color: "#8b5cf6" },
  { id: "p6", label: "5 000 GC", type: "coins", value: 5000, color: "#ec4899" },
  { id: "p7", label: "10 000 GC 🔥", type: "coins", value: 10000, color: "#f59e0b" },
  {
    id: "p8",
    label: "🎁 AK-47 Slate",
    type: "skin",
    value: 1200,
    color: "#eab308",
    skin: {
      name: "Slate",
      weapon: "AK-47",
      price: 1200,
      image: "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot7HxfDhjxszJemkV08y5nY6fqPP9ILrDhGpI18h0juDU-MKt2wXt-EJrNzzycoXDclI3MwvU_gS2yO7phMe9up-anXcy7ic8pSGKnW0m-lM/360fx360f",
      rarity: "Заборонене",
      accent: "#8847ff",
    },
  },
];

const LAST_SPIN_KEY = "goicoins_wheel_last_spin";

export function canSpinWheel(): { allowed: boolean; remainingSec: number } {
  if (typeof window === "undefined") return { allowed: true, remainingSec: 0 };
  const raw = localStorage.getItem(LAST_SPIN_KEY);
  if (!raw) return { allowed: true, remainingSec: 0 };
  const lastTime = parseInt(raw, 10);
  const now = Date.now();
  const cooldownMs = 24 * 60 * 60 * 1000;
  const diff = now - lastTime;
  if (diff >= cooldownMs) return { allowed: true, remainingSec: 0 };
  return { allowed: false, remainingSec: Math.ceil((cooldownMs - diff) / 1000) };
}

export function claimWheelReward(prize: WheelPrize) {
  if (typeof window === "undefined") return;
  localStorage.setItem(LAST_SPIN_KEY, Date.now().toString());

  if (prize.type === "coins") {
    updateStoredBalance(prize.value);
  } else if (prize.type === "skin" && prize.skin) {
    addSkinToInventory({
      name: prize.skin.name,
      weapon: prize.skin.weapon,
      price: prize.skin.price,
      image: prize.skin.image,
      rarity: prize.skin.rarity,
      accent: prize.skin.accent,
      wear: "Прямо із заводу",
      floatValue: 0.02,
    });
  }
}

export function resetWheelCooldownForTest() {
  if (typeof window !== "undefined") {
    localStorage.removeItem(LAST_SPIN_KEY);
  }
}
