#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v17: ВІДНОВЛЕННЯ БАЛАНСУ 60 922 GC ТА СКІНІВ"
echo "   + ВИПРАВЛЕННЯ ПОМИЛКИ SkinArt (reading 'accent')"
echo "   + ПЛЕЙСХОЛДЕР 'Goi Master' ТА ЗБЕРЕЖЕННЯ ПРОГРЕСУ"
echo "=========================================================="

mkdir -p app/components app/inventory app/topup components lib

# 1. Куленепробивний app/components/skin-art.tsx
cat << 'INNER_EOF' > app/components/skin-art.tsx
/* eslint-disable @next/next/no-img-element */
import type { Skin } from "../data";

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
  const currentAccent = skin?.accent || propAccent || "#eb4b4b";
  const currentImage = skin?.image || image;
  const currentWeapon = skin?.weapon || weapon || "CS2";
  const currentName = skin?.name || name || "Skin";
  const fullTitle = `${currentWeapon} | ${currentName}`.trim();

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

      {currentImage ? (
        <img
          src={currentImage}
          alt={fullTitle}
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

# 2. Оновлення lib/inventory-storage.ts з відновленням 60 922 GC
cat << 'INNER_EOF' > lib/inventory-storage.ts
"use client";

import { skins, inventorySkins, type Skin } from "@/app/data";
import { syncUserBalance, syncUserInventory } from "./auth-storage";

export type InventoryItem = Skin & { instanceId: string };

const INVENTORY_STORAGE_KEY = "goicoins_inventory_v3";
const BALANCE_STORAGE_KEY = "goicoins_balance_v3";

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
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_jdk7uW-V7V1Mf6TMWedw-B-Xxa-mxwvpnfcwN-uJXqTP1p1DYVyEbZY5xnrxtPjM7vnsgH_2o1A3t3x73z9yF-xW-I",
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
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwhFQyvj8V7p8POXfDWadweB-Xxa_nRwvpnfSwNv7IHiQPFp1DYVyEbZY5xnrxtPjM7vnsgH_2o1A3t3x73z9yF-xW-I",
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
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ype13RxSxfv1f6x5Ne-bwmjA1bTsdGfnw-G-z97S5YvW_154_rPwrVwhrM_t3",
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
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ype13RxSxfv1f6x5Ne-bwmjA1bTsdGfnw-G-z97S5YvW_154_rPwrVwhrM_t3",
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
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ype13RxSxfv1f6x5Ne-bwmjA1bTsdGfnw-G-z97S5YvW_154_rPwrVwhrM_t3",
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
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ype13RxSxfv1f6x5Ne-bwmjA1bTsdGfnw-G-z97S5YvW_154_rPwrVwhrM_t3",
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
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ype13RxSxfv1f6x5Ne-bwmjA1bTsdGfnw-G-z97S5YvW_154_rPwrVwhrM_t3",
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
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ype13RxSxfv1f6x5Ne-bwmjA1bTsdGfnw-G-z97S5YvW_154_rPwrVwhrM_t3",
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
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ype13RxSxfv1f6x5Ne-bwmjA1bTsdGfnw-G-z97S5YvW_154_rPwrVwhrM_t3",
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
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ype13RxSxfv1f6x5Ne-bwmjA1bTsdGfnw-G-z97S5YvW_154_rPwrVwhrM_t3",
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
      return parsed.map((item: Skin & { instanceId?: string }, idx: number) => ({
        ...item,
        instanceId:
          item.instanceId ||
          `item-${item.finish || "skin"}-${idx}-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
      }));
    }
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  } catch {
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  }
}

export function restoreUserProgress(targetBalance = 60922): { restoredBalance: number; restoredCount: number } {
  if (typeof window === "undefined") return { restoredBalance: targetBalance, restoredCount: 0 };
  try {
    const currentInv = getStoredInventory();
    const existingKeys = new Set(currentInv.map((s) => `${s.weapon}-${s.name}`));
    const toAdd: InventoryItem[] = RESTORE_BACKUP_SKINS.filter(
      (s) => !existingKeys.has(`${s.weapon}-${s.name}`)
    ).map((s, idx) => ({
      ...s,
      instanceId: `restored-${s.finish}-${Date.now()}-${idx}-${Math.random().toString(36).substring(2, 6)}`,
    }));

    const fullInventory = [...toAdd, ...currentInv];
    localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(fullInventory));
    syncUserInventory(fullInventory);

    const currentBal = getStoredBalance();
    const finalBal = Math.max(currentBal, targetBalance);
    localStorage.setItem(BALANCE_STORAGE_KEY, finalBal.toString());
    syncUserBalance(finalBal);

    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: fullInventory }));
    window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: finalBal }));

    return { restoredBalance: finalBal, restoredCount: fullInventory.length };
  } catch {
    return { restoredBalance: targetBalance, restoredCount: 0 };
  }
}

export function addSkinToInventory(newSkin: Skin): InventoryItem[] {
  if (typeof window === "undefined") return [];
  try {
    const current = getStoredInventory();
    const newItem: InventoryItem = {
      ...newSkin,
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
    const newItem: InventoryItem = {
      ...newSkin,
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
  if (typeof window === "undefined") return { count: 0, totalGained: 0, newBalance: 60922 };
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
  if (typeof window === "undefined") return 60922;
  try {
    const raw = localStorage.getItem(BALANCE_STORAGE_KEY);
    return raw ? parseInt(raw, 10) : 60922;
  } catch {
    return 60922;
  }
}

export function updateStoredBalance(delta: number): number {
  if (typeof window === "undefined") return 60922;
  try {
    const current = getStoredBalance();
    const updated = Math.max(0, current + delta);
    localStorage.setItem(BALANCE_STORAGE_KEY, updated.toString());
    syncUserBalance(updated);
    window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: updated }));
    return updated;
  } catch {
    return 60922;
  }
}
INNER_EOF

# 3. lib/auth-storage.ts: злиття балансу та скінів при реєстрації
cat << 'INNER_EOF' > lib/auth-storage.ts
"use client";

import type { InventoryItem } from "./inventory-storage";

export interface UserProfile {
  id: string;
  email: string;
  nickname: string;
  avatar: string;
  balance: number;
  rank: string;
  createdAt: number;
}

export interface StoredUserAccount extends UserProfile {
  password: string;
  inventory: InventoryItem[];
}

export interface AuthResult {
  success: boolean;
  message?: string;
  user?: UserProfile;
}

export const AUTH_USER_KEY = "goicoins_current_user";
export const AUTH_USERS_DB_KEY = "goicoins_users_db";
export const STARTER_REGISTRATION_BONUS_GC = 2500;

export const STARTER_REGISTRATION_SKINS = [
  {
    name: "Neon Rider",
    weapon: "AK-47",
    wear: "Прямо із заводу",
    price: 4200,
    rarity: "Таємне",
    accent: "#ec4899",
    finish: "neon-rider",
    kind: "rifle" as const,
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
    kind: "sniper" as const,
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
    kind: "pistol" as const,
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ype13RxSxfv1f6x5Ne-bwmjA1bTsdGfnw-G-z97S5YvW_154_rPwrVwhrM_t3",
  },
  {
    name: "Kill Confirmed",
    weapon: "USP-S",
    wear: "Прямо із заводу",
    price: 3200,
    rarity: "Таємне",
    accent: "#ef4444",
    finish: "usps-kill-confirmed",
    kind: "pistol" as const,
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ype13RxSxfv1f6x5Ne-bwmjA1bTsdGfnw-G-z97S5YvW_154_rPwrVwhrM_t3",
  },
];

export function getAllStoredUsers(): StoredUserAccount[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem(AUTH_USERS_DB_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

export function getCurrentUser(): UserProfile | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = localStorage.getItem(AUTH_USER_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

export function registerUser(email: string, nickname: string, password: string): AuthResult {
  if (typeof window === "undefined") return { success: false, message: "Серверне середовище" };

  const cleanEmail = email.trim().toLowerCase();
  const cleanNickname = nickname.trim();

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(cleanEmail)) {
    return { success: false, message: "Введіть дійсну пошту (наприклад: player@cs2goi.ua)!" };
  }

  if (cleanNickname.length < 2) {
    return { success: false, message: "Нікнейм повинен містити щонайменше 2 символи!" };
  }

  if (password.length < 6) {
    return { success: false, message: "Пароль повинен містити щонайменше 6 символів!" };
  }

  const users = getAllStoredUsers();
  if (users.some((u) => u.email.toLowerCase() === cleanEmail)) {
    return { success: false, message: "Користувач із цією поштою вже зареєстрований!" };
  }

  let existingInv: InventoryItem[] = [];
  let existingBalance = 0;
  try {
    const rawInv = localStorage.getItem("goicoins_inventory_v3");
    if (rawInv) existingInv = JSON.parse(rawInv);
    const rawBal = localStorage.getItem("goicoins_balance_v3");
    if (rawBal) existingBalance = parseInt(rawBal, 10);
  } catch {}

  const starterInventory: InventoryItem[] = STARTER_REGISTRATION_SKINS.map((s, idx) => ({
    ...s,
    instanceId: `starter-${s.finish}-${Date.now()}-${idx}-${Math.random().toString(36).substring(2, 6)}`,
  }));

  const existingKeys = new Set(existingInv.map((s) => s.instanceId || `${s.weapon}-${s.name}`));
  const starterFiltered = starterInventory.filter((s) => !existingKeys.has(s.instanceId));
  const mergedInventory: InventoryItem[] = [...existingInv, ...starterFiltered];

  const initialBalance = existingBalance > 0
    ? existingBalance + STARTER_REGISTRATION_BONUS_GC
    : 60922 + STARTER_REGISTRATION_BONUS_GC;

  const initials = cleanNickname.length >= 2
    ? cleanNickname.substring(0, 2).toUpperCase()
    : cleanNickname.substring(0, 1).toUpperCase();

  const newAccount: StoredUserAccount = {
    id: "gp_" + Math.random().toString(36).substring(2, 9),
    email: cleanEmail,
    nickname: cleanNickname,
    avatar: initials,
    balance: initialBalance,
    rank: "Global Elite",
    createdAt: Date.now(),
    password,
    inventory: mergedInventory,
  };

  users.push(newAccount);
  localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));

  const profile: UserProfile = {
    id: newAccount.id,
    email: newAccount.email,
    nickname: newAccount.nickname,
    avatar: newAccount.avatar,
    balance: newAccount.balance,
    rank: newAccount.rank,
    createdAt: newAccount.createdAt,
  };

  localStorage.setItem(AUTH_USER_KEY, JSON.stringify(profile));
  localStorage.setItem("goicoins_balance_v3", newAccount.balance.toString());
  localStorage.setItem("goicoins_inventory_v3", JSON.stringify(mergedInventory));

  window.dispatchEvent(new CustomEvent("goi-auth-updated", { detail: profile }));
  window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: newAccount.balance }));
  window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: mergedInventory }));

  return {
    success: true,
    user: profile,
    message: `Вітаємо, ${cleanNickname}! Тобі нараховано +${STARTER_REGISTRATION_BONUS_GC.toLocaleString("uk-UA")} GC та збережено інвентар!`,
  };
}

export function loginUser(email: string, password: string): AuthResult {
  if (typeof window === "undefined") return { success: false, message: "Серверне середовище" };

  const cleanEmail = email.trim().toLowerCase();
  const users = getAllStoredUsers();

  let user = users.find((u) => u.email.toLowerCase() === cleanEmail);

  if (!user && (cleanEmail === "demo@cs2goi.ua" || cleanEmail === "admin@cs2goi.ua")) {
    return registerUser(cleanEmail, "Goi Master", password || "123456");
  }

  if (!user) {
    return {
      success: false,
      message: "Користувача з такою поштою не знайдено!",
    };
  }

  if (user.password !== password) {
    return {
      success: false,
      message: "Невірний пароль! Спробуйте ще раз.",
    };
  }

  const profile: UserProfile = {
    id: user.id,
    email: user.email,
    nickname: user.nickname,
    avatar: user.avatar,
    balance: user.balance,
    rank: user.rank,
    createdAt: user.createdAt,
  };

  localStorage.setItem(AUTH_USER_KEY, JSON.stringify(profile));
  localStorage.setItem("goicoins_balance_v3", user.balance.toString());
  localStorage.setItem("goicoins_inventory_v3", JSON.stringify(user.inventory || []));

  window.dispatchEvent(new CustomEvent("goi-auth-updated", { detail: profile }));
  window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: user.balance }));
  window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: user.inventory || [] }));

  return {
    success: true,
    user: profile,
    message: `Раді бачити, ${user.nickname}! Дані синхронізовано.`,
  };
}

export function logoutUser(): void {
  if (typeof window === "undefined") return;

  const currentUser = getCurrentUser();
  if (currentUser) {
    const users = getAllStoredUsers();
    const idx = users.findIndex((u) => u.id === currentUser.id);
    if (idx !== -1) {
      try {
        const curBalRaw = localStorage.getItem("goicoins_balance_v3");
        const curInvRaw = localStorage.getItem("goicoins_inventory_v3");
        if (curBalRaw) users[idx].balance = parseInt(curBalRaw, 10);
        if (curInvRaw) users[idx].inventory = JSON.parse(curInvRaw);
        localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
      } catch {}
    }
  }

  localStorage.removeItem(AUTH_USER_KEY);
  window.dispatchEvent(new CustomEvent("goi-auth-updated", { detail: null }));
}

export function syncUserBalance(newBalance: number) {
  if (typeof window === "undefined") return;
  const user = getCurrentUser();
  if (!user) return;
  user.balance = newBalance;
  localStorage.setItem(AUTH_USER_KEY, JSON.stringify(user));

  const users = getAllStoredUsers();
  const idx = users.findIndex((u) => u.id === user.id);
  if (idx !== -1) {
    users[idx].balance = newBalance;
    localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
  }
}

export function syncUserInventory(newInventory: InventoryItem[]) {
  if (typeof window === "undefined") return;
  const user = getCurrentUser();
  if (!user) return;

  const users = getAllStoredUsers();
  const idx = users.findIndex((u) => u.id === user.id);
  if (idx !== -1) {
    users[idx].inventory = newInventory;
    localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
  }
}
INNER_EOF

# 4. components/auth-modal.tsx з плейсхолдером 'Goi Master'
cat << 'INNER_EOF' > components/auth-modal.tsx
"use client";

import { useState, useEffect } from "react";
import { registerUser, loginUser, type UserProfile } from "@/lib/auth-storage";
import { playClickSound, playWinSound, playLossSound } from "@/lib/sound-fx";

interface AuthModalProps {
  isOpen: boolean;
  initialTab?: "login" | "register";
  onClose: () => void;
  onSuccess?: (user: UserProfile) => void;
}

export function AuthModal({
  isOpen,
  initialTab = "login",
  onClose,
  onSuccess,
}: AuthModalProps) {
  const [tab, setTab] = useState<"login" | "register">(initialTab);
  const [email, setEmail] = useState("");
  const [nickname, setNickname] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  useEffect(() => {
    setTab(initialTab);
    setError(null);
    setSuccessMsg(null);
  }, [initialTab, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccessMsg(null);

    if (tab === "login") {
      const res = loginUser(email, password);
      if (res.success && res.user) {
        playWinSound();
        setSuccessMsg(res.message || "Успішний вхід!");
        setTimeout(() => {
          onSuccess?.(res.user!);
          onClose();
        }, 800);
      } else {
        playLossSound();
        setError(res.message || "Помилка входу");
      }
    } else {
      const res = registerUser(email, nickname, password);
      if (res.success && res.user) {
        playWinSound();
        setSuccessMsg(res.message || "Успішна реєстрація!");
        setTimeout(() => {
          onSuccess?.(res.user!);
          onClose();
        }, 1200);
      } else {
        playLossSound();
        setError(res.message || "Помилка реєстрації");
      }
    }
  };

  const handleQuickDemo = (demoType: "user" | "admin") => {
    playClickSound();
    if (demoType === "user") {
      setEmail("player@cs2goi.ua");
      setNickname("Goi Master");
      setPassword("cs2goi123");
    } else {
      setEmail("admin@cs2goi.ua");
      setNickname("Goi Admin");
      setPassword("admin123");
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
      <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-white/10 bg-[#0d1018]/95 p-6 sm:p-8 shadow-[0_0_50px_rgba(16,185,129,0.15)]">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-4 top-4 rounded-xl p-2 text-slate-400 hover:bg-white/5 hover:text-white transition"
          aria-label="Закрити"
        >
          ✕
        </button>

        <div className="flex items-center gap-3 mb-6">
          <div className="flex size-11 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 text-xl font-black text-[#05130d] shadow-lg shadow-emerald-500/20">
            G
          </div>
          <div>
            <h2 className="text-xl font-black text-white">GoiCoins Simulator</h2>
            <p className="text-xs text-slate-400">Система акаунтів та хмарний інвентар</p>
          </div>
        </div>

        <div className="flex rounded-xl bg-black/40 p-1 mb-6 border border-white/5">
          <button
            onClick={() => {
              playClickSound();
              setTab("login");
              setError(null);
            }}
            className={`flex-1 rounded-lg py-2 text-xs font-bold transition ${
              tab === "login"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            Увійти
          </button>
          <button
            onClick={() => {
              playClickSound();
              setTab("register");
              setError(null);
            }}
            className={`flex-1 rounded-lg py-2 text-xs font-bold transition ${
              tab === "register"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            Реєстрація (+2.5k GC) 🎁
          </button>
        </div>

        {error && (
          <div className="mb-4 rounded-xl border border-rose-500/30 bg-rose-500/10 p-3 text-xs font-medium text-rose-400 animate-fade-in">
            ⚠️ {error}
          </div>
        )}

        {successMsg && (
          <div className="mb-4 rounded-xl border border-emerald-500/30 bg-emerald-500/10 p-3 text-xs font-medium text-emerald-400 animate-fade-in">
            🎉 {successMsg}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-[11px] font-bold text-slate-300 mb-1">
              Електронна пошта
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="player@cs2goi.ua"
              className="w-full rounded-xl border border-white/10 bg-black/40 px-3.5 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
            />
          </div>

          {tab === "register" && (
            <div className="animate-fade-in">
              <label className="block text-[11px] font-bold text-slate-300 mb-1">
                Ігровий нікнейм (позивний)
              </label>
              <input
                type="text"
                required
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                placeholder="Goi Master"
                className="w-full rounded-xl border border-white/10 bg-black/40 px-3.5 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
            </div>
          )}

          <div>
            <label className="block text-[11px] font-bold text-slate-300 mb-1">
              Пароль {tab === "register" && "(мінімум 6 символів)"}
            </label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Введіть пароль"
                className="w-full rounded-xl border border-white/10 bg-black/40 px-3.5 py-2 pr-10 text-xs text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-slate-400 hover:text-white"
              >
                {showPassword ? "🙈" : "👁️"}
              </button>
            </div>
          </div>

          <button
            type="submit"
            className="w-full rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 py-2.5 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/25 hover:brightness-110 active:scale-[0.99] transition mt-2"
          >
            {tab === "login" ? "Увійти в акаунт ⚡" : "Зареєструватися (+2 500 GC) 🎁"}
          </button>
        </form>

        <div className="mt-5 border-t border-white/5 pt-4">
          <p className="text-[10px] font-bold uppercase tracking-wider text-slate-500 text-center mb-2.5">
            Швидкі демо-профілі для перевірки:
          </p>
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => handleQuickDemo("user")}
              className="flex-1 rounded-lg border border-white/10 bg-white/5 py-1.5 text-[11px] font-medium text-slate-300 hover:bg-white/10 hover:text-white transition"
            >
              👤 Гравець
            </button>
            <button
              type="button"
              onClick={() => handleQuickDemo("admin")}
              className="flex-1 rounded-lg border border-white/10 bg-white/5 py-1.5 text-[11px] font-medium text-slate-300 hover:bg-white/10 hover:text-white transition"
            >
              👑 Адмін
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
INNER_EOF

# 5. app/inventory/page.tsx: виправлення SkinArt та кнопка відновлення 60 922 GC
cat << 'INNER_EOF' > app/inventory/page.tsx
"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { formatCoins } from "@/app/data";
import SkinArt from "@/app/components/skin-art";
import {
  getStoredInventory,
  getStoredBalance,
  sellInventorySkin,
  sellAllInventorySkins,
  restoreUserProgress,
  type InventoryItem,
} from "@/lib/inventory-storage";
import { getCurrentUser, type UserProfile } from "@/lib/auth-storage";
import { playCoinSound, playClickSound } from "@/lib/sound-fx";

export default function InventoryPage() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [balance, setBalance] = useState(60922);
  const [user, setUser] = useState<UserProfile | null>(null);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const [skinToSell, setSkinToSell] = useState<InventoryItem | null>(null);
  const [confirmSellAll, setConfirmSellAll] = useState(false);

  useEffect(() => {
    setInventory(getStoredInventory());
    setBalance(getStoredBalance());
    setUser(getCurrentUser());

    const handleInv = (e: CustomEvent<InventoryItem[]>) => {
      if (e.detail) setInventory(e.detail);
    };
    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    const handleAuth = (e: CustomEvent<UserProfile | null>) => {
      setUser(e.detail ?? null);
    };

    window.addEventListener("goi-inventory-updated", handleInv as EventListener);
    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    window.addEventListener("goi-auth-updated", handleAuth as EventListener);

    return () => {
      window.removeEventListener("goi-inventory-updated", handleInv as EventListener);
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
      window.removeEventListener("goi-auth-updated", handleAuth as EventListener);
    };
  }, []);

  const totalValue = inventory.reduce((acc, s) => acc + (s.price || 0), 0);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  };

  const handleRestore = () => {
    playCoinSound();
    const res = restoreUserProgress(60922);
    setInventory(getStoredInventory());
    setBalance(res.restoredBalance);
    showToast(`🎉 Успішно відновлено ${res.restoredBalance.toLocaleString("uk-UA")} GC та ${res.restoredCount} скінів!`);
  };

  const requestSellSkin = (item: InventoryItem) => {
    playClickSound();
    setSkinToSell(item);
  };

  const executeSellSkin = () => {
    if (!skinToSell) return;
    playCoinSound();
    const { newInventory, newBalance } = sellInventorySkin(skinToSell);
    setInventory(newInventory);
    setBalance(newBalance);
    showToast(`💰 Продано ${skinToSell.weapon} | ${skinToSell.name} за +${formatCoins(skinToSell.price)} GC!`);
    setSkinToSell(null);
  };

  const requestSellAll = () => {
    if (inventory.length === 0) return;
    playClickSound();
    setConfirmSellAll(true);
  };

  const executeSellAll = () => {
    playCoinSound();
    const { count, totalGained, newBalance } = sellAllInventorySkins();
    setInventory([]);
    setBalance(newBalance);
    showToast(`🎉 Продано всі ${count} скінів на суму +${formatCoins(totalGained)} GC!`);
    setConfirmSellAll(false);
  };

  const handleSelectAsUpgradeSource = (item: InventoryItem) => {
    playClickSound();
    try {
      localStorage.setItem("goicoins_selected_source", JSON.stringify(item));
    } catch {}
  };

  const openRegisterModal = () => {
    playClickSound();
    window.dispatchEvent(new CustomEvent("goi-open-auth", { detail: "register" }));
  };

  return (
    <div className="mx-auto max-w-[1760px] px-4 py-8 sm:px-6 lg:px-10 xl:px-12 min-h-screen">
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 rounded-2xl border border-emerald-500/40 bg-[#0d1614]/95 px-5 py-3 text-sm font-bold text-emerald-300 shadow-2xl backdrop-blur-md animate-fade-in">
          {toastMessage}
        </div>
      )}

      {/* Верхня панель профілю */}
      <div className="mb-6 overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 sm:p-8 shadow-xl">
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div className="flex items-center gap-4">
            <div className="flex size-16 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 text-2xl font-black text-[#05130d] shadow-lg shadow-emerald-500/20">
              {user?.avatar || "G"}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-2xl font-black text-white">
                  Гравець {user?.nickname || "Гість (Goi Master)"}
                </h1>
                <span className="rounded-md bg-emerald-400/20 px-2 py-0.5 text-xs font-bold text-emerald-300">
                  {user?.rank || "Global Elite"}
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">
                {user ? user.email : "ID: #GP-88391 · Твій персональний інвентар CS2"}
              </p>
            </div>
          </div>

          <div className="flex flex-wrap gap-4">
            <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 px-5 py-3 flex items-center gap-3">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-wider text-emerald-300">Баланс GC</p>
                <p className="mt-0.5 font-mono text-xl font-black text-white">
                  {balance.toLocaleString("uk-UA")} GC
                </p>
              </div>
              <Link
                href="/topup"
                title="Поповнити баланс (+)"
                className="flex size-8 items-center justify-center rounded-xl bg-emerald-500 hover:bg-emerald-400 text-[#05130d] font-black text-lg shadow-md shadow-emerald-500/30 hover:scale-105 active:scale-95 transition"
              >
                +
              </Link>
            </div>
            <div className="rounded-2xl border border-white/[0.06] bg-black/40 px-5 py-3">
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Вартість інвентаря</p>
              <p className="mt-0.5 font-mono text-xl font-black text-emerald-400">
                {formatCoins(totalValue)} GC
              </p>
            </div>
            <div className="rounded-2xl border border-white/[0.06] bg-black/40 px-5 py-3">
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Кількість предметів</p>
              <p className="mt-0.5 font-mono text-xl font-black text-white">
                {inventory.length} шт.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Золотий банер швидкого відновлення балансу 60 922 GC */}
      <div className="mb-6 rounded-3xl border border-amber-500/40 bg-gradient-to-r from-amber-500/15 via-[#181308] to-transparent p-5 sm:p-6 shadow-xl flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="flex size-12 items-center justify-center rounded-2xl bg-amber-500/20 text-2xl shadow-md shadow-amber-500/20">
            🔄
          </div>
          <div>
            <h3 className="text-base font-black text-amber-300">
              Повернути збережений баланс та скіни?
            </h3>
            <p className="text-xs text-slate-300 mt-0.5">
              Натисни, щоб миттєво повернути свій точний баланс <strong className="text-amber-400">60 922 GC</strong> та всі топові ножі, рукавички й скіни!
            </p>
          </div>
        </div>
        <button
          onClick={handleRestore}
          className="rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 hover:brightness-110 px-6 py-2.5 text-xs font-black text-[#1a1104] shadow-lg shadow-amber-500/20 transition transform active:scale-95"
        >
          Повернути 60 922 GC + Скіни ⚡
        </button>
      </div>

      {!user && (
        <div className="mb-8 rounded-3xl border border-emerald-500/30 bg-gradient-to-r from-emerald-500/10 via-[#0e1713] to-emerald-500/5 p-5 sm:p-6 flex flex-wrap items-center justify-between gap-4 shadow-lg animate-fade-in">
          <div className="flex items-center gap-4">
            <div className="flex size-12 items-center justify-center rounded-2xl bg-emerald-500/20 text-2xl">
              🎁
            </div>
            <div>
              <h3 className="text-base font-black text-white">
                Ти граєш як Гість! Зареєструйся та отримай бонус
              </h3>
              <p className="text-xs text-slate-300 mt-0.5">
                Прив&apos;яжи свої скіни до власної пошти та отримай <strong className="text-emerald-400">+2 500 GoiCoins</strong> та 4 стартових скіни!
              </p>
            </div>
          </div>
          <button
            onClick={openRegisterModal}
            className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-6 py-2.5 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition"
          >
            Зареєструватися (+2.5k GC) ⚡
          </button>
        </div>
      )}

      {/* Заголовок списку скінів */}
      <div className="mb-6 flex flex-wrap items-center justify-between gap-4 border-b border-white/[0.08] pb-4">
        <div>
          <h2 className="text-2xl font-black text-white">
            Предмети в інвентарі ({inventory.length})
          </h2>
          <p className="text-xs text-slate-400 mt-0.5">
            Ти можеш продати будь-який скін за повну вартість у GoiCoins (з підтвердженням) або запустити його в кібер-апгрейд.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2.5">
          {inventory.length > 0 && (
            <button
              onClick={requestSellAll}
              className="rounded-xl border border-amber-500/40 bg-amber-500/10 hover:bg-amber-500/20 px-4 py-2 text-xs font-bold text-amber-300 transition"
            >
              Продати весь інвентар (+{formatCoins(totalValue)} GC) 💰
            </button>
          )}
          <Link
            href="/"
            className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-4 py-2 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition"
          >
            До Апгрейдера ⚡
          </Link>
        </div>
      </div>

      {/* Сітка інвентарю */}
      {inventory.length === 0 ? (
        <div className="flex min-h-[400px] flex-col items-center justify-center rounded-3xl border border-dashed border-white/10 bg-[#0d1018]/50 p-12 text-center">
          <div className="text-6xl mb-4">🎒</div>
          <h3 className="text-xl font-bold text-white">Твій інвентар порожній</h3>
          <p className="text-sm text-slate-400 max-w-md mt-1 mb-6">
            Віднови збережений прогрес кнопкою вище, купи скіни на CS2 Ринку або скористайся поповненням!
          </p>
          <div className="flex flex-wrap justify-center gap-3">
            <button
              onClick={handleRestore}
              className="rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 hover:brightness-110 px-6 py-2.5 text-xs font-black text-[#1a1104] shadow-lg shadow-amber-500/20 transition"
            >
              Відновити 60 922 GC + Скіни 🔄
            </button>
            <Link
              href="/market"
              className="rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 px-6 py-2.5 text-xs font-bold text-slate-300 transition"
            >
              Перейти на Ринок CS2 →
            </Link>
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-7">
          {inventory.map((item) => (
            <div
              key={item.instanceId}
              className="group relative flex flex-col justify-between overflow-hidden rounded-2xl border border-white/[0.08] bg-[#0d1018]/90 p-3.5 transition duration-200 hover:border-emerald-500/50 hover:bg-[#121622] hover:shadow-xl hover:shadow-emerald-500/10"
            >
              <div className="flex items-center justify-between text-[10px]">
                <span
                  className="rounded px-1.5 py-0.5 font-bold uppercase tracking-wider"
                  style={{ backgroundColor: `${item.accent || "#eb4b4b"}20`, color: item.accent || "#eb4b4b" }}
                >
                  {item.rarity}
                </span>
                <span className="font-mono font-bold text-emerald-400">
                  {formatCoins(item.price)} GC
                </span>
              </div>

              <div className="relative my-3 flex aspect-video items-center justify-center">
                <div
                  className="absolute inset-0 opacity-20 blur-xl transition group-hover:opacity-40"
                  style={{ backgroundColor: item.accent || "#eb4b4b" }}
                />
                <SkinArt
                  skin={item}
                  className="h-24 w-full object-contain drop-shadow-lg transition-transform duration-300 group-hover:scale-105"
                />
              </div>

              <div>
                <p className="text-[11px] font-semibold text-slate-400">{item.weapon}</p>
                <p className="truncate text-xs font-black text-white group-hover:text-emerald-300 transition">
                  {item.name}
                </p>
                <p className="text-[10px] text-slate-500">{item.wear}</p>
              </div>

              <div className="mt-3 flex gap-1.5 pt-2 border-t border-white/[0.06]">
                <Link
                  href="/"
                  onClick={() => handleSelectAsUpgradeSource(item)}
                  className="flex-1 rounded-lg bg-emerald-500/15 hover:bg-emerald-500/25 py-1.5 text-center text-[10px] font-bold text-emerald-300 transition"
                >
                  В Апгрейд ⚡
                </Link>
                <button
                  onClick={() => requestSellSkin(item)}
                  title={`Продати за +${formatCoins(item.price)} GC`}
                  className="rounded-lg bg-white/5 hover:bg-amber-500/20 px-2.5 py-1.5 text-center text-[10px] font-bold text-slate-300 hover:text-amber-300 transition"
                >
                  Продати 💰
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Модалка підтвердження продажу окремого скіна */}
      {skinToSell && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
          <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-amber-500/30 bg-[#0d1018]/95 p-6 sm:p-7 shadow-[0_0_50px_rgba(245,158,11,0.18)]">
            <div className="text-center">
              <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-amber-500/20 text-2xl">
                ⚠️
              </div>
              <h3 className="mt-3 text-xl font-black text-white">Підтвердження продажу</h3>
              <p className="mt-1 text-xs text-slate-400">
                Ти дійсно хочеш продати цей скін за GoiCoins?
              </p>
            </div>

            <div className="mt-5 rounded-2xl border border-white/10 bg-black/40 p-4 text-center">
              <div className="relative mx-auto flex h-24 w-full items-center justify-center">
                <div
                  className="absolute inset-0 opacity-20 blur-xl"
                  style={{ backgroundColor: skinToSell.accent || "#eb4b4b" }}
                />
                <SkinArt
                  skin={skinToSell}
                  className="h-20 w-full object-contain drop-shadow-lg"
                />
              </div>
              <p className="mt-2 text-xs font-semibold text-slate-400">{skinToSell.weapon}</p>
              <p className="text-base font-black text-white">{skinToSell.name}</p>
              <div className="mt-1 flex items-center justify-center gap-2 text-[11px]">
                <span
                  className="rounded px-1.5 py-0.5 font-bold uppercase"
                  style={{ backgroundColor: `${skinToSell.accent || "#eb4b4b"}20`, color: skinToSell.accent || "#eb4b4b" }}
                >
                  {skinToSell.rarity}
                </span>
                <span className="text-slate-500">·</span>
                <span className="text-slate-400">{skinToSell.wear}</span>
              </div>
              <div className="mt-3 rounded-xl bg-emerald-500/10 border border-emerald-500/30 py-2">
                <span className="text-[10px] font-bold text-emerald-300 uppercase">Отримаєш: </span>
                <span className="text-base font-black text-emerald-400 font-mono">
                  +{formatCoins(skinToSell.price)} GC
                </span>
              </div>
            </div>

            <div className="mt-6 flex gap-3">
              <button
                onClick={() => setSkinToSell(null)}
                className="flex-1 rounded-xl border border-white/10 bg-white/5 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/10 hover:text-white transition"
              >
                Скасувати
              </button>
              <button
                onClick={executeSellSkin}
                className="flex-1 rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 py-2.5 text-xs font-black text-[#1a1104] shadow-lg shadow-amber-500/20 hover:brightness-110 transition"
              >
                Підтвердити продаж 💰
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Модалка підтвердження продажу ВСЬОГО інвентаря */}
      {confirmSellAll && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
          <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-rose-500/40 bg-[#0d1018]/95 p-6 sm:p-7 shadow-[0_0_50px_rgba(244,63,94,0.2)]">
            <div className="text-center">
              <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-rose-500/20 text-2xl text-rose-400">
                🚨
              </div>
              <h3 className="mt-3 text-xl font-black text-white">Продати весь інвентар?</h3>
              <p className="mt-1 text-xs text-slate-400">
                Ця дія безповоротно продасть <strong className="text-white">{inventory.length} скінів</strong> за повну ринкову вартість.
              </p>
            </div>

            <div className="mt-5 rounded-2xl border border-white/10 bg-black/40 p-4 text-center">
              <p className="text-xs text-slate-400">Загальне нарахування на баланс:</p>
              <p className="mt-1 font-mono text-2xl font-black text-emerald-400">
                +{formatCoins(totalValue)} GC
              </p>
              <p className="mt-1 text-[11px] text-slate-500">
                Новий баланс: {(balance + totalValue).toLocaleString("uk-UA")} GC
              </p>
            </div>

            <div className="mt-6 flex gap-3">
              <button
                onClick={() => setConfirmSellAll(false)}
                className="flex-1 rounded-xl border border-white/10 bg-white/5 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/10 hover:text-white transition"
              >
                Скасувати
              </button>
              <button
                onClick={executeSellAll}
                className="flex-1 rounded-xl bg-rose-500 hover:bg-rose-400 py-2.5 text-xs font-black text-white shadow-lg shadow-rose-500/25 transition"
              >
                Так, продати все 💥
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
INNER_EOF

# 6. app/topup/page.tsx: промокод GOI60K
cat << 'INNER_EOF' > app/topup/page.tsx
"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { formatCoins } from "@/app/data";
import { getStoredBalance, updateStoredBalance, restoreUserProgress } from "@/lib/inventory-storage";
import { getCurrentUser, type UserProfile } from "@/lib/auth-storage";
import { playCoinSound, playWinSound, playLossSound, playClickSound } from "@/lib/sound-fx";

const PROMO_CODES: Record<string, { reward: number; desc: string }> = {
  MARCHENKO: { reward: 5000, desc: "Спеціальний бонус від викладача Марченка (+5 000 GC)" },
  GOI60K: { reward: 60922, desc: "Відновлення збереженого балансу (+60 922 GC)" },
  RESTORE: { reward: 60922, desc: "Повне відновлення прогресу (+60 922 GC)" },
  S1MPLE: { reward: 2500, desc: "Промокод легенди CS s1mple (+2 500 GC)" },
  GOI2026: { reward: 1000, desc: "Святковий промокод GoiCoins 2026 (+1 000 GC)" },
  CS2: { reward: 1500, desc: "Valve Counter-Strike 2 Booster (+1 500 GC)" },
  FREECOINS: { reward: 777, desc: "Стартовий набір новачка (+777 GC)" },
};

export default function TopUpPage() {
  const [balance, setBalance] = useState(60922);
  const [user, setUser] = useState<UserProfile | null>(null);
  const [promoInput, setPromoInput] = useState("");
  const [statusMessage, setStatusMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);
  const [usedPromos, setUsedPromos] = useState<string[]>([]);
  const [lastDailyClaim, setLastDailyClaim] = useState<number | null>(null);

  useEffect(() => {
    setBalance(getStoredBalance());
    setUser(getCurrentUser());

    try {
      const storedUsed = localStorage.getItem("goicoins_used_promos");
      if (storedUsed) setUsedPromos(JSON.parse(storedUsed));
      const storedDaily = localStorage.getItem("goicoins_last_daily");
      if (storedDaily) setLastDailyClaim(parseInt(storedDaily, 10));
    } catch {}

    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    const handleAuth = (e: CustomEvent<UserProfile | null>) => {
      setUser(e.detail ?? null);
    };

    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    window.addEventListener("goi-auth-updated", handleAuth as EventListener);

    return () => {
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
      window.removeEventListener("goi-auth-updated", handleAuth as EventListener);
    };
  }, []);

  const canClaimDaily = !lastDailyClaim || Date.now() - lastDailyClaim > 24 * 60 * 60 * 1000;

  const handleClaimDaily = () => {
    if (!canClaimDaily) return;
    playWinSound();
    const newBal = updateStoredBalance(500);
    setBalance(newBal);
    const now = Date.now();
    setLastDailyClaim(now);
    try {
      localStorage.setItem("goicoins_last_daily", now.toString());
    } catch {}
    setStatusMessage({
      type: "success",
      text: "🎁 Щоденний бонус +500 GC успішно нараховано на твій баланс!",
    });
  };

  const handleApplyPromo = (e: React.FormEvent) => {
    e.preventDefault();
    const code = promoInput.trim().toUpperCase();
    if (!code) return;

    if (usedPromos.includes(code)) {
      playLossSound();
      setStatusMessage({
        type: "error",
        text: `Промокод "${code}" вже був активований на цьому акаунті!`,
      });
      return;
    }

    const promo = PROMO_CODES[code];
    if (promo) {
      playWinSound();
      const newBal = updateStoredBalance(promo.reward);
      setBalance(newBal);
      const updated = [...usedPromos, code];
      setUsedPromos(updated);
      try {
        localStorage.setItem("goicoins_used_promos", JSON.stringify(updated));
      } catch {}
      setStatusMessage({
        type: "success",
        text: `🎉 Промокод активовано! ${promo.desc}`,
      });
      setPromoInput("");
    } else {
      playLossSound();
      setStatusMessage({
        type: "error",
        text: `Недійсний промокод "${code}". Спробуйте MARCHENKO або GOI60K.`,
      });
    }
  };

  const handleInstantFaucet = (amount: number, label: string) => {
    playCoinSound();
    const newBal = updateStoredBalance(amount);
    setBalance(newBal);
    setStatusMessage({
      type: "success",
      text: `⚡ Тестовий кран (${label}) успішно нарахував +${formatCoins(amount)} GC!`,
    });
  };

  const handleFullRestore = () => {
    playCoinSound();
    const res = restoreUserProgress(60922);
    setBalance(res.restoredBalance);
    setStatusMessage({
      type: "success",
      text: `🔄 Повний прогрес відновлено! Баланс: ${res.restoredBalance.toLocaleString("uk-UA")} GC та ${res.restoredCount} скінів.`,
    });
  };

  return (
    <div className="mx-auto max-w-5xl px-4 py-8 sm:px-6 lg:px-8 min-h-screen">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-4 border-b border-white/[0.08] pb-4">
        <div>
          <h1 className="text-3xl font-black text-white">Поповнення балансу GoiCoins</h1>
          <p className="text-xs text-slate-400 mt-0.5">
            Отримуй безкоштовні GoiCoins через промокоди, щоденні бонуси або тестовий кран симулятора.
          </p>
        </div>
        <Link
          href="/inventory"
          className="rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 px-4 py-2 text-xs font-bold text-slate-300 transition"
        >
          ← До інвентаря
        </Link>
      </div>

      {statusMessage && (
        <div
          className={`mb-6 rounded-2xl border p-4 text-xs font-bold animate-fade-in ${
            statusMessage.type === "success"
              ? "border-emerald-500/40 bg-emerald-500/10 text-emerald-300"
              : "border-rose-500/40 bg-rose-500/10 text-rose-300"
          }`}
        >
          {statusMessage.text}
        </div>
      )}

      {/* Картка балансу */}
      <div className="mb-8 rounded-3xl border border-emerald-500/30 bg-gradient-to-br from-[#0e1915] via-[#0d1018] to-black p-6 sm:p-8 shadow-xl flex flex-wrap items-center justify-between gap-6">
        <div>
          <span className="text-[10px] font-bold uppercase tracking-wider text-emerald-400">
            Поточний баланс користувача
          </span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="font-mono text-4xl font-black text-white">
              {balance.toLocaleString("uk-UA")}
            </span>
            <span className="text-lg font-bold text-emerald-400 font-mono">GC</span>
          </div>
          <p className="text-xs text-slate-400 mt-1">
            Акаунт: <strong className="text-white">{user?.nickname || "Гість (Goi Master)"}</strong> · Ранг:{" "}
            <span className="text-emerald-300">{user?.rank || "Global Elite"}</span>
          </p>
        </div>

        <button
          onClick={handleFullRestore}
          className="rounded-2xl bg-gradient-to-r from-amber-400 to-orange-500 hover:brightness-110 px-6 py-3.5 text-xs font-black text-[#1a1104] shadow-lg shadow-amber-500/20 transition transform active:scale-95"
        >
          Відновити баланс 60 922 GC 🔄
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        {/* Активація промокоду */}
        <div className="rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 shadow-xl">
          <div className="flex items-center gap-3 mb-4">
            <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-500/20 text-xl text-emerald-300">
              🎟️
            </div>
            <div>
              <h3 className="text-base font-black text-white">Активація промокоду</h3>
              <p className="text-[11px] text-slate-400">Введи секретний код для миттєвих монет</p>
            </div>
          </div>

          <form onSubmit={handleApplyPromo} className="space-y-3">
            <input
              type="text"
              value={promoInput}
              onChange={(e) => setPromoInput(e.target.value)}
              placeholder="Введи промокод (напр. MARCHENKO або GOI60K)"
              className="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-2.5 text-xs text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition font-mono uppercase"
            />
            <button
              type="submit"
              className="w-full rounded-xl bg-emerald-500 hover:bg-emerald-400 py-2.5 text-xs font-black text-[#05130d] shadow-md shadow-emerald-500/20 transition"
            >
              Активувати промокод ⚡
            </button>
          </form>

          <div className="mt-4 pt-3 border-t border-white/[0.06]">
            <p className="text-[10px] font-bold uppercase tracking-wider text-slate-500 mb-2">
              Підказка бонусних кодів:
            </p>
            <div className="flex flex-wrap gap-1.5">
              {Object.keys(PROMO_CODES).map((code) => (
                <button
                  key={code}
                  type="button"
                  onClick={() => {
                    playClickSound();
                    setPromoInput(code);
                  }}
                  className={`rounded-lg px-2.5 py-1 text-[10px] font-mono font-bold transition ${
                    usedPromos.includes(code)
                      ? "bg-white/5 text-slate-500 line-through"
                      : "bg-emerald-500/10 text-emerald-300 hover:bg-emerald-500/20 border border-emerald-500/20"
                  }`}
                >
                  {code} (+{PROMO_CODES[code].reward})
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Щоденна нагорода */}
        <div className="rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 shadow-xl flex flex-col justify-between">
          <div>
            <div className="flex items-center gap-3 mb-4">
              <div className="flex size-10 items-center justify-center rounded-xl bg-amber-500/20 text-xl text-amber-300">
                ⭐
              </div>
              <div>
                <h3 className="text-base font-black text-white">Щоденна винагорода (Daily Drop)</h3>
                <p className="text-[11px] text-slate-400">Забирай безкоштовні +500 GC кожні 24 години</p>
              </div>
            </div>
            <p className="text-xs text-slate-300 mb-4">
              Підтримуй серію щоденних входів, щоб збільшувати свій баланс для великих апгрейдів у грі.
            </p>
          </div>

          <button
            onClick={handleClaimDaily}
            disabled={!canClaimDaily}
            className={`w-full rounded-xl py-2.5 text-xs font-black transition ${
              canClaimDaily
                ? "bg-gradient-to-r from-amber-400 to-orange-500 text-[#1a1104] hover:brightness-110 shadow-lg shadow-amber-500/20"
                : "bg-white/5 text-slate-500 cursor-not-allowed border border-white/5"
            }`}
          >
            {canClaimDaily ? "Забрати +500 GC зараз! 🎁" : "Вже отримано (повертайся завтра) ⏳"}
          </button>
        </div>
      </div>

      {/* Тестовий Faucet симулятора */}
      <div className="rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 sm:p-8 shadow-xl">
        <div className="mb-4">
          <h3 className="text-lg font-black text-white">🧪 Тестовий симуляторний Faucet</h3>
          <p className="text-xs text-slate-400">
            Оскільки це академічний симулятор без реальних грошей, ти можеш миттєво нарахувати будь-яку суму для тестування механіки апгрейдів.
          </p>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <button
            onClick={() => handleInstantFaucet(2000, "+2k GC")}
            className="rounded-2xl border border-white/10 bg-white/5 hover:bg-emerald-500/20 hover:border-emerald-500/30 p-4 text-center transition group"
          >
            <p className="text-xs text-slate-400">Стартовий</p>
            <p className="font-mono text-lg font-black text-white group-hover:text-emerald-300 transition">
              +2 000 GC
            </p>
          </button>
          <button
            onClick={() => handleInstantFaucet(10000, "+10k GC")}
            className="rounded-2xl border border-white/10 bg-white/5 hover:bg-emerald-500/20 hover:border-emerald-500/30 p-4 text-center transition group"
          >
            <p className="text-xs text-slate-400">Середній</p>
            <p className="font-mono text-lg font-black text-white group-hover:text-emerald-300 transition">
              +10 000 GC
            </p>
          </button>
          <button
            onClick={() => handleInstantFaucet(50000, "+50k GC")}
            className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 p-4 text-center transition group"
          >
            <p className="text-xs text-emerald-300">Хайроллер</p>
            <p className="font-mono text-lg font-black text-emerald-400 group-hover:scale-105 transition">
              +50 000 GC
            </p>
          </button>
          <button
            onClick={() => handleInstantFaucet(200000, "+200k GC")}
            className="rounded-2xl border border-amber-500/30 bg-amber-500/10 hover:bg-amber-500/20 p-4 text-center transition group"
          >
            <p className="text-xs text-amber-300">Кібер-Магнат</p>
            <p className="font-mono text-lg font-black text-amber-400 group-hover:scale-105 transition">
              +200 000 GC
            </p>
          </button>
        </div>
      </div>
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
git commit -m "fix(inventory): fix SkinArt undefined accent error and add 60k balance restore" || true
git push origin main || true

echo "=========================================================="
echo "🎉 ГОТОВО! Онови сторінку в браузері (Ctrl+F5)."
echo "   Помилку SkinArt виправлено, а баланс 60 922 GC та всі скіни"
echo "   можна відновити в 1 клік кнопкою 'Повернути 60 922 GC + Скіни'!"
echo "=========================================================="
