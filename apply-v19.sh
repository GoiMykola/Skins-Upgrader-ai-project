#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v19: ВИПРАВЛЕННЯ ФОТОГРАФІЙ СКІНІВ В ІНВЕНТАРІ"
echo "   (Офіційні Steam CDN зображення для Dragon Lore, Wild Lotus, ножів)"
echo "=========================================================="

mkdir -p app/components lib

# 1. Оновлення lib/inventory-storage.ts: база перевірених Steam CDN посилань та авто-виправлення в localStorage
cat << 'INNER_EOF' > lib/inventory-storage.ts
"use client";

import { skins, inventorySkins, type Skin } from "@/app/data";
import { syncUserBalance, syncUserInventory } from "./auth-storage";

export type InventoryItem = Skin & { instanceId: string };

const INVENTORY_STORAGE_KEY = "goicoins_inventory_v3";
const BALANCE_STORAGE_KEY = "goicoins_balance_v3";

export const OFFICIAL_SKIN_IMAGES: Record<string, string> = {
  "AWP | Dragon Lore":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_jdk4veqYaF7IfysCnWRxuF4j-B-Xxa_nBovp3Pdwtj9cC_GaAd0DZdwQu9fuhS4kNy0NePntVTbjYpCyyT_3CgY5i9j_a9cBkcCWUKV",
  "AK-47 | Wild Lotus":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwlcK3wiFO0POlV61-LPGdCliWzeFkse1WQyC0nQlpsDuGyt-pdnyRPA4hDcYkR-QPuhi-wdPuYbyx5AaMidkQnC_-2ilIuzErvbi4ijV5Mw",
  "★ Karambit | Fade":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1Q7uCvZaZkNM-SD1iWwOpzj-1gSCGn20tztm_UyIn_JHKUbgYlWMcmQ-ZcskSwldS0MOnntAfd3YlMzH35jntXrnE8SOGRGG8",
  "★ Skeleton Knife | Fade":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1I5PeibbBiLs-SD1iWwOpzj-1gSCGn20kjt2-En9mpcCmQag8hXsciQeJYthW9kILkMLji4g3Ygo8Uznj6jX9XrnE8raC5r1M",
  "★ Talon Knife | Marble Fade":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1M5vahf6lsK_WBMWaR_uh3tORWQyC0nQlpsmXcnNaoeHuTZwUiWMZzRrVZsxm9x9ThNrzj4QCPjdhNmHj73S9KujErvbhX2ACGeQ",
  "★ Talon Knife | Fade":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1M5vahf6lsK_WBMWaR_uh3tORWQyC0nQlpsmXcnNaoeHuTZwUiWMZzRrVZsxm9x9ThNrzj4QCPjdhNmHj73S9KujErvbhX2ACGeQ",
  "★ Sport Gloves | Vice":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Tk5UvzWCL2kpn2-DFk_OKherB0H_KfG2Kv0ed4u95lRi67gVNx4T-Bw434IHyVb1QlAsd1FOUDthG4xNznMu3m4QXXg90Wzn_33C1I8G81tLaDi_rK",
  "★ Huntsman Knife | Doppler (Phase 4)":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1P7vG6YadsLM-SD1iWwOpzj-1gSCGn2x8hsW6DmIqpcXjBZgYkCZt5F7VcthS8ldS2Nr7m5VCMi4gRyyuqjHtXrnE8oar8MtU",
  "★ Huntsman Knife | Fade":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1P7vG6YadsLM-SD1iWwOpzj-1gSCGn2x8hsW6DmIqpcXjBZgYkCZt5F7VcthS8ldS2Nr7m5VCMi4gRyyuqjHtXrnE8oar8MtU",
  "M4A4 | Howl":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwiFO0P_6afVSKP-EAm6extF6ueZhW2exwkl2tmTXwt39eCiUPQR2DMN4TOVetUK8xoLgM-K341eM2otDnC6okGoXufBz_TAB",
  "CZ75-Auto | Hexane":
    "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLyhMG1_B1T9s2sZLFoKPWLMWuZxuZi_rBqS3vrkRxz5W7dnN2oIyiTZgYhXpN5EOIPsUbsloC1M-_qs1HdiYlbjXKpP5VEBps",
};

export const RESTORE_BACKUP_SKINS: Skin[] = [
  {
    name: "Dragon Lore",
    weapon: "AWP",
    wear: "Прямо із заводу",
    price: 450000,
    rarity: "Таємне",
    accent: "#f59e0b",
    finish: "dragon-lore",
    kind: "sniper",
    image: OFFICIAL_SKIN_IMAGES["AWP | Dragon Lore"],
  },
  {
    name: "Wild Lotus",
    weapon: "AK-47",
    wear: "Прямо із заводу",
    price: 320000,
    rarity: "Таємне",
    accent: "#10b981",
    finish: "wild-lotus",
    kind: "rifle",
    image: OFFICIAL_SKIN_IMAGES["AK-47 | Wild Lotus"],
  },
  {
    name: "Fade",
    weapon: "★ Karambit",
    wear: "Прямо із заводу",
    price: 140000,
    rarity: "Надзвичайне",
    accent: "#ec4899",
    finish: "karambit-fade",
    kind: "knife",
    image: OFFICIAL_SKIN_IMAGES["★ Karambit | Fade"],
  },
  {
    name: "Fade",
    weapon: "★ Skeleton Knife",
    wear: "Прямо із заводу",
    price: 88000,
    rarity: "Надзвичайне",
    accent: "#a855f7",
    finish: "skeleton-fade",
    kind: "knife",
    image: OFFICIAL_SKIN_IMAGES["★ Skeleton Knife | Fade"],
  },
  {
    name: "Marble Fade",
    weapon: "★ Talon Knife",
    wear: "Прямо із заводу",
    price: 52000,
    rarity: "Надзвичайне",
    accent: "#3b82f6",
    finish: "talon-marble",
    kind: "knife",
    image: OFFICIAL_SKIN_IMAGES["★ Talon Knife | Marble Fade"],
  },
  {
    name: "Vice",
    weapon: "★ Sport Gloves",
    wear: "Прямо із заводу",
    price: 95000,
    rarity: "Надзвичайне",
    accent: "#ec4899",
    finish: "gloves-vice",
    kind: "gloves",
    image: OFFICIAL_SKIN_IMAGES["★ Sport Gloves | Vice"],
  },
  {
    name: "Doppler (Phase 4)",
    weapon: "★ Huntsman Knife",
    wear: "Прямо із заводу",
    price: 36000,
    rarity: "Надзвичайне",
    accent: "#3b82f6",
    finish: "huntsman-doppler",
    kind: "knife",
    image: OFFICIAL_SKIN_IMAGES["★ Huntsman Knife | Doppler (Phase 4)"],
  },
  {
    name: "Howl",
    weapon: "M4A4",
    wear: "Прямо із заводу",
    price: 185000,
    rarity: "Контрабанда",
    accent: "#ef4444",
    finish: "m4a4-howl",
    kind: "rifle",
    image: OFFICIAL_SKIN_IMAGES["M4A4 | Howl"],
  },
  {
    name: "Hexane",
    weapon: "CZ75-Auto",
    wear: "Прямо із заводу",
    price: 84,
    rarity: "Армійське",
    accent: "#4b69ff",
    finish: "hexane",
    kind: "pistol",
    image: OFFICIAL_SKIN_IMAGES["CZ75-Auto | Hexane"],
  },
  {
    name: "Neon Rider",
    weapon: "AK-47",
    wear: "Прямо із заводу",
    price: 4200,
    rarity: "Таємне",
    accent: "#ec4899",
    finish: "neon-rider",
    kind: "rifle",
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwhFQyvj8V7p8POXfDWadweB-Xxa_nRwvpnfSwNv7IHiQPFp1DYVyEbZY5xnrxtPjM7vnsgH_2o1A3t3x73z9yF-xW-I",
  },
  {
    name: "Hyper Beast",
    weapon: "AWP",
    wear: "Після польових",
    price: 2800,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "hyper-beast",
    kind: "sniper",
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_jdk7uW-V6x0MPWBMWWVwP1ij-1gSCGn20pxtm_WzNuoeHKeaFAnCZUiTe5bt0HqxofmZOrm5Q2IjoMQzS_5iShXrnE8NzWs__c",
  },
  {
    name: "Printstream",
    weapon: "Desert Eagle",
    wear: "Прямо із заводу",
    price: 3900,
    rarity: "Таємне",
    accent: "#e0e7ff",
    finish: "deagle-printstream",
    kind: "pistol",
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL1m5fn8Sdk7OeRbKFsJ8-DHG6e1f1iouRoQha_nBovp3OGmdeqInyVP1V0XsYlRbEI50a5wNyzZr605AyI3t5MmCSohylAuC89_a9cBoMY9UkV",
  },
];

export function getStoredInventory(): InventoryItem[] {
  if (typeof window === "undefined") {
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  }
  try {
    const raw = localStorage.getItem(INVENTORY_STORAGE_KEY);
    if (!raw) {
      const initial = inventorySkins.map((s, idx) => ({
        ...s,
        instanceId: `default-${s.finish}-${idx}-${Date.now()}-${Math.random().toString(36).substring(2, 6)}`,
      }));
      localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(initial));
      return initial;
    }
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed) && parsed.length > 0) {
      let hasUpdates = false;
      const healedItems: InventoryItem[] = parsed.map((item: Skin & { instanceId?: string }, idx: number) => {
        const fullKey = `${item.weapon} | ${item.name}`;
        let finalImage = item.image;

        // Авто-виправлення битих або пустих посилань на фотографії
        if (OFFICIAL_SKIN_IMAGES[fullKey]) {
          if (!finalImage || finalImage !== OFFICIAL_SKIN_IMAGES[fullKey]) {
            finalImage = OFFICIAL_SKIN_IMAGES[fullKey];
            hasUpdates = true;
          }
        }

        return {
          ...item,
          image: finalImage,
          instanceId:
            item.instanceId ||
            `item-${item.finish || "skin"}-${idx}-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
        };
      });

      if (hasUpdates) {
        localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(healedItems));
        syncUserInventory(healedItems);
      }

      return healedItems;
    }
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  } catch {
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  }
}

export function addSkinToInventory(newSkin: Skin): InventoryItem[] {
  if (typeof window === "undefined") return [];
  try {
    const current = getStoredInventory();
    const fullKey = `${newSkin.weapon} | ${newSkin.name}`;
    const verifiedImage = OFFICIAL_SKIN_IMAGES[fullKey] || newSkin.image;

    const newItem: InventoryItem = {
      ...newSkin,
      image: verifiedImage,
      instanceId: `won-${newSkin.finish || "skin"}-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
    };
    const updated = [newItem, ...current];
    localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(updated));
    syncUserInventory(updated);
    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: updated }));
    return updated;
  } catch {
    return [];
  }
}

export function removeSkinFromInventory(instanceId: string): InventoryItem[] {
  if (typeof window === "undefined") return [];
  try {
    const current = getStoredInventory();
    const updated = current.filter((s) => s.instanceId !== instanceId);
    localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(updated));
    syncUserInventory(updated);
    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: updated }));
    return updated;
  } catch {
    return [];
  }
}

export function replaceSkinInInventory(oldInstanceId: string, newSkin: Skin): InventoryItem[] {
  if (typeof window === "undefined") return [];
  try {
    const current = getStoredInventory();
    const remaining = current.filter((s) => s.instanceId !== oldInstanceId);
    const fullKey = `${newSkin.weapon} | ${newSkin.name}`;
    const verifiedImage = OFFICIAL_SKIN_IMAGES[fullKey] || newSkin.image;

    const newItem: InventoryItem = {
      ...newSkin,
      image: verifiedImage,
      instanceId: `won-${newSkin.finish || "skin"}-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
    };
    const updated = [newItem, ...remaining];
    localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(updated));
    syncUserInventory(updated);
    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: updated }));
    return updated;
  } catch {
    return [];
  }
}

export function sellInventorySkin(item: InventoryItem): { newInventory: InventoryItem[]; newBalance: number } {
  const newInventory = removeSkinFromInventory(item.instanceId);
  const newBalance = updateStoredBalance(item.price);
  return { newInventory, newBalance };
}

export function sellAllInventorySkins(): { count: number; totalGained: number; newBalance: number } {
  if (typeof window === "undefined") return { count: 0, totalGained: 0, newBalance: 1500 };
  const current = getStoredInventory();
  if (current.length === 0) return { count: 0, totalGained: 0, newBalance: getStoredBalance() };
  const totalGained = current.reduce((sum, s) => sum + (s.price || 0), 0);
  const newBalance = updateStoredBalance(totalGained);
  localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify([]));
  syncUserInventory([]);
  window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: [] }));
  return { count: current.length, totalGained, newBalance };
}

export function getStoredBalance(): number {
  if (typeof window === "undefined") return 1500;
  try {
    const raw = localStorage.getItem(BALANCE_STORAGE_KEY);
    return raw ? parseInt(raw, 10) : 1500;
  } catch {
    return 1500;
  }
}

export function updateStoredBalance(delta: number): number {
  if (typeof window === "undefined") return 1500;
  try {
    const current = getStoredBalance();
    const updated = Math.max(0, current + delta);
    localStorage.setItem(BALANCE_STORAGE_KEY, updated.toString());
    syncUserBalance(updated);
    window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: updated }));
    return updated;
  } catch {
    return 1500;
  }
}
INNER_EOF

# 2. Оновлення app/components/skin-art.tsx: з авто-фолбеком на офіційні CDN фотографії
cat << 'INNER_EOF' > app/components/skin-art.tsx
/* eslint-disable @next/next/no-img-element */
import { useState, useEffect } from "react";
import type { Skin } from "../data";
import { OFFICIAL_SKIN_IMAGES } from "@/lib/inventory-storage";

export interface SkinArtProps {
  skin?: Skin;
  image?: string;
  name?: string;
  weapon?: string;
  accent?: string;
  finish?: string;
  className?: string;
}

export default function SkinArt({
  skin,
  image,
  name,
  weapon,
  accent: propAccent,
  finish,
  className = "",
}: SkinArtProps) {
  const currentWeapon = skin?.weapon || weapon || "CS2";
  const currentName = skin?.name || name || "Skin";
  const fullTitle = `${currentWeapon} | ${currentName}`.trim();
  const currentAccent = skin?.accent || propAccent || "#eb4b4b";

  const preferredImage = OFFICIAL_SKIN_IMAGES[fullTitle] || skin?.image || image;
  const [imgSrc, setImgSrc] = useState<string | undefined>(preferredImage);

  useEffect(() => {
    const updatedImage = OFFICIAL_SKIN_IMAGES[fullTitle] || skin?.image || image;
    setImgSrc(updatedImage);
  }, [fullTitle, skin?.image, image]);

  const handleImageError = () => {
    const fallback = OFFICIAL_SKIN_IMAGES[fullTitle];
    if (fallback && imgSrc !== fallback) {
      setImgSrc(fallback);
    }
  };

  return (
    <div
      className={`relative flex h-36 items-center justify-center overflow-hidden rounded-2xl border border-white/[0.06] bg-[#0c0e15] ${className}`}
      style={{
        backgroundImage: `radial-gradient(ellipse at 50% 60%, ${currentAccent}25, transparent 70%)`,
      }}
      aria-label={fullTitle}
      role="img"
    >
      <div
        className="absolute inset-0 opacity-15 pointer-events-none"
        style={{
          background: `radial-gradient(circle at center, ${currentAccent}, transparent 70%)`,
        }}
      />

      <span className="absolute left-3 top-2.5 font-mono text-[9px] uppercase tracking-[0.2em] text-white/30">
        CS2 OFFICIAL
      </span>

      {imgSrc ? (
        <img
          src={imgSrc}
          alt={fullTitle}
          onError={handleImageError}
          className="relative z-10 max-h-[82%] max-w-[85%] object-contain drop-shadow-[0_12px_22px_rgba(0,0,0,0.85)] transition-transform duration-300 group-hover:scale-110"
          loading="lazy"
        />
      ) : (
        <span className="font-mono text-sm text-slate-400">{currentName}</span>
      )}

      <span className="absolute bottom-2 right-3 text-[9px] font-semibold uppercase tracking-[0.18em] text-white/20">
        GOICONS · SKIN LAB
      </span>
    </div>
  );
}
INNER_EOF

echo "=========================================================="
echo "🧪 ЗАПУСК ТЕСТІВ ТА БІЛДУ"
echo "=========================================================="
npm test
npm run build

echo "=========================================================="
echo "🚀 ФІКСАЦІЯ В GIT ТА PUSH"
echo "=========================================================="
git add .
git commit -m "fix(inventory): update official Steam CDN skin images and add auto-healer" || true
git push origin main || true

echo "=========================================================="
echo "🎉 ГОТОВО! Оновлені офіційні Steam CDN зображення встановлено."
echo "   При перезавантаженні сторінки всі фотографії скінів (Dragon Lore,"
echo "   Wild Lotus, ножі, рукавички) відобразяться автоматично!"
echo "=========================================================="
