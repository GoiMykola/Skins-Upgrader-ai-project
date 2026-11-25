"use client";

import { OFFICIAL_SKIN_IMAGES } from "./inventory-storage";

export interface LiveDrop {
  id: string;
  playerName: string;
  playerAvatar: string;
  playerRank?: string;
  weapon: string;
  name: string;
  price: number;
  image: string;
  accent: string;
  rarity: string;
  chance: string;
  multiplier: string;
  timestamp: number;
  isRealWin: boolean;
}

const STORAGE_KEY = "goicoins_live_drops_v2";

/**
 * 100% ПРАВДИВІ ДРОПИ:
 * Ніяких вигаданих чи стартових сідів (порожній масив за замовчуванням).
 * Якщо гравець ще нічого не виграв — стрічка порожня і не відображається.
 */
export function getStoredLiveDrops(): LiveDrop[] {
  if (typeof window === "undefined") return [];
  try {
    // Одноразово очищаємо старий ключ з v32, який містив стартові сіди
    if (localStorage.getItem("goicoins_live_drops")) {
      localStorage.removeItem("goicoins_live_drops");
    }

    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];

    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];

    // Суворо відфільтровуємо лише реальні виграші
    const realOnly = parsed.filter(
      (d: any) =>
        d &&
        typeof d === "object" &&
        (d.isRealWin === true || (typeof d.id === "string" && d.id.startsWith("real_win_"))) &&
        d.weapon &&
        d.name &&
        typeof d.price === "number"
    );

    if (realOnly.length !== parsed.length) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(realOnly));
    }

    return realOnly;
  } catch {
    return [];
  }
}

export function addLiveDrop(
  drop: Omit<LiveDrop, "id" | "timestamp" | "isRealWin">
): LiveDrop {
  let skinImage = drop.image;
  if (!skinImage || skinImage.trim() === "") {
    const fullName = `${drop.weapon} | ${drop.name}`;
    skinImage =
      OFFICIAL_SKIN_IMAGES[fullName] ||
      OFFICIAL_SKIN_IMAGES[drop.name] ||
      "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot621FAR17PLfYQJD_9W7m5a0mvLwOq7c2D4B6pcn3-3E99n22Qfn_kFtY2inINfAcVJtNArR-1G5wri-jce0ot2XnjXh2Y2F";
  }

  const newDrop: LiveDrop = {
    ...drop,
    image: skinImage,
    id: `real_win_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
    timestamp: Date.now(),
    isRealWin: true,
  };

  if (typeof window !== "undefined") {
    try {
      const current = getStoredLiveDrops();
      const updated = [newDrop, ...current].slice(0, 50);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
      window.dispatchEvent(new CustomEvent("goi-live-drop", { detail: newDrop }));
    } catch {}
  }

  return newDrop;
}

export function clearLiveDrops(): void {
  if (typeof window !== "undefined") {
    try {
      localStorage.removeItem(STORAGE_KEY);
      localStorage.removeItem("goicoins_live_drops");
      window.dispatchEvent(new CustomEvent("goi-live-drop-cleared"));
    } catch {}
  }
}
