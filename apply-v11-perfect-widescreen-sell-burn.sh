#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "🚀 UPGRADER v11: Widescreen 16:9 + Продаж скінів + Спалення при програші + Звуковий фікс"
echo "=========================================================="

# 1. Оновлення app/data.ts: офіційні назви Valve (Fade замість Fade 99.8%) та експорт players
cat << 'EOF' > app/data.ts
export type Skin = {
  name: string;
  weapon: string;
  wear: string;
  price: number;
  rarity: string;
  accent: string;
  finish: string;
  kind: "rifle" | "sniper" | "knife" | "pistol";
  image: string;
};

export type MarketSkin = {
  id: string;
  name: string;
  weapon: string;
  fullName: string;
  category: "knives" | "gloves" | "snipers" | "rifles" | "pistols" | "smgs" | "heavy" | "other";
  rarity: string;
  rarityUk: string;
  rarityColor: string;
  price: number;
  image: string;
  minFloat?: number;
  maxFloat?: number;
};

// Розумне форматування цін: 1 грн = 1 GC (420к, 185к, 8.9к, 1.2M)
export function formatCoins(amount: number): string {
  if (!amount && amount !== 0) return "0";
  if (amount >= 1_000_000) {
    const val = amount / 1_000_000;
    return (val % 1 === 0 ? val.toFixed(0) : val.toFixed(1)) + "M";
  }
  if (amount >= 10_000) {
    const val = amount / 1_000;
    return (val % 1 === 0 ? val.toFixed(0) : val.toFixed(1)) + "к";
  }
  if (amount >= 1_000) {
    const val = amount / 1_000;
    return (val % 1 === 0 ? val.toFixed(0) : val.toFixed(1)) + "к";
  }
  return amount.toLocaleString("uk-UA");
}

// Конвертація предмету з Ринку в формат Скіна для Апгрейдера та Інвентаря
export function marketSkinToSkin(item: MarketSkin): Skin {
  return {
    name: item.name,
    weapon: item.weapon,
    wear: "Прямо із заводу",
    price: item.price,
    rarity: item.rarityUk || item.rarity,
    accent: item.rarityColor || "#eb4b4b",
    finish: item.id || item.name.toLowerCase().replace(/[^a-z0-9]/g, "-"),
    kind: (item.category === "knives" ? "knife" : item.category === "snipers" ? "sniper" : item.category === "pistols" ? "pistol" : "rifle") as any,
    image: item.image,
  };
}

// Початковий пул скінів з офіційними назвами CS2 (★ Karambit | Fade виправлено)
export const skins: Skin[] = [
  {
    name: "Neon Rider",
    weapon: "AK-47",
    wear: "Прямо із заводу",
    price: 4200,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "neon-rider",
    kind: "rifle",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwlcK3wiFO0POlV6poL_6sHG6UxPxJvOhuRz39xkQhsTnVzoygdy7Ea1UoCZQkRe9bs0brl9TvN-m0tVHYjY5CyS35jjQJsHhk4o5zcA",
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
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_jdk7uW-V6x0MPWBMWWVwP1ij-1gSCGn20pxtm_WzNuoeHKeaFAnCZUiTe5bt0HqxofmZOrm5Q2IjoMQzS_5iShXrnE8NzWs__c",
  },
  {
    name: "Howl",
    weapon: "M4A4",
    wear: "Трохи поношене",
    price: 185000,
    rarity: "Контрабандний",
    accent: "#e4ae39",
    finish: "howl",
    kind: "rifle",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwiFO0P_6afVSKP-EAm6extF6ueZhW2exwkl2tmTXwt39eCiUPQR2DMN4TOVetUK8xoLgM-K341eM2otDnC6okGoXufBz_TAB",
  },
  {
    name: "Dragon Lore",
    weapon: "AWP",
    wear: "Прямо із заводу",
    price: 450000,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "dragon-lore",
    kind: "sniper",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_jdk4veqYaF7IfysCnWRxuF4j-B-Xxa_nBovp3Pdwtj9cC_GaAd0DZdwQu9fuhS4kNy0NePntVTbjYpCyyT_3CgY5i9j_a9cBkcCWUKV",
  },
  {
    name: "Gamma Doppler (Emerald)",
    weapon: "★ Butterfly Knife",
    wear: "Прямо із заводу",
    price: 420000,
    rarity: "Надзвичайне",
    accent: "#34d399",
    finish: "gamma-doppler",
    kind: "knife",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1Z-ua6bbZrLOmsD2qvxONzouBlSxa-lA8lvziMgIr9HifOOV5kFJp2Ee9b4Rntm4GxY7_ntQHc2o1DmH6r3Hgcv3w4t-pXU6ZzrPHQjQnfcepq0dwfRJw",
  },
  {
    name: "Fade",
    weapon: "★ Karambit",
    wear: "Прямо із заводу",
    price: 140000,
    rarity: "Надзвичайне",
    accent: "#ffd700",
    finish: "karambit-fade",
    kind: "knife",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1Q7uCvZaZkNM-SD1iWwOpzj-1gSCGn20tztm_UyIn_JHKUbgYlWMcmQ-ZcskSwldS0MOnntAfd3YlMzH35jntXrnE8SOGRGG8",
  },
  {
    name: "Printstream",
    weapon: "AWP",
    wear: "Мінімальний знос",
    price: 6400,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "printstream-awp",
    kind: "sniper",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_DVL0OK8Yap5M-SBC2ad_uJ_t-l9AX_qlk4k5GyAzo6ocC-QZgZxX8AjEbZY5xnrxtPjM7vnsgGIj9oTmXngznQeg3pfcPs",
  },
  {
    name: "Case Hardened",
    weapon: "AK-47",
    wear: "Мінімальний знос",
    price: 18500,
    rarity: "Засекречена",
    accent: "#d32ce6",
    finish: "case-hardened",
    kind: "rifle",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwlcK3wiNK0P2nZKFpH_yaCW-Ej7sk5bE8Sn-2lEpz4zndzoyvdHuUPwFzWZYiE7EK4Bi4k9TlY-y24FbAy9USGSiZd5Q",
  },
  {
    name: "Printstream",
    weapon: "Desert Eagle",
    wear: "Прямо із заводу",
    price: 3900,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "printstream-deagle",
    kind: "pistol",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL1m5fn8Sdk7OeRbKFsJ8-DHG6e1f1iouRoQha_nBovp3OGmdeqInyVP1V0XsYlRbEI50a5wNyzZr605AyI3t5MmCSohylAuC89_a9cBoMY9UkV",
  },
  {
    name: "Kill Confirmed",
    weapon: "USP-S",
    wear: "Після польових",
    price: 3200,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "kill-confirmed",
    kind: "pistol",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL1m5fn8S1E8emXZadkM-GGCWWZ_eJ_t-loA36mxw4u5GyAzNuufC3XPlNxA5YmEbZI71W8kIznZ-y6v1Xp2t9NzS_5mStXrnE9vW0vK9c",
  },
];

export const inventorySkins: Skin[] = [
  skins[0], // AK-47 Neon Rider (4 200 GC)
  skins[1], // AWP Hyper Beast (2 800 GC)
  skins[8], // Desert Eagle Printstream (3 900 GC)
  skins[9], // USP-S Kill Confirmed (3 200 GC)
];

export const players = [
  { rank: "01", name: "s1mple.ua", level: "Легенда", value: 890000, skins: 34 },
  { rank: "02", name: "demo-player", level: "Global Elite", value: 320000, skins: 18 },
  { rank: "03", name: "Kira.exe", level: "Майстер", value: 195000, skins: 14 },
  { rank: "04", name: "v1per", level: "Майстер", value: 145000, skins: 12 },
  { rank: "05", name: "n0va", level: "Ветеран", value: 85000, skins: 11 },
];
EOF

# 2. Оновлення lib/sound-fx.ts: правильний експорт isMuted, плавні звуки та звук продажу
cat << 'EOF' > lib/sound-fx.ts
let audioCtx: AudioContext | null = null;
let isMutedState = false;

function getAudioContext(): AudioContext | null {
  if (typeof window === "undefined") return null;
  if (!audioCtx) {
    const AudioClass =
      window.AudioContext ||
      (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
    if (AudioClass) audioCtx = new AudioClass();
  }
  if (audioCtx && audioCtx.state === "suspended") {
    audioCtx.resume();
  }
  return audioCtx;
}

export function isMuted(): boolean {
  return isMutedState;
}

export function toggleMute(): boolean {
  isMutedState = !isMutedState;
  return isMutedState;
}

export function playClickSound() {
  if (isMutedState) return;
  const ctx = getAudioContext();
  if (!ctx) return;
  try {
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = "sine";
    osc.frequency.setValueAtTime(800, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(300, ctx.currentTime + 0.04);
    gain.gain.setValueAtTime(0.12, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.04);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + 0.04);
  } catch {}
}

export function playTickSound(freq: number = 600) {
  if (isMutedState) return;
  const ctx = getAudioContext();
  if (!ctx) return;
  try {
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = "triangle";
    osc.frequency.setValueAtTime(freq, ctx.currentTime);
    gain.gain.setValueAtTime(0.07, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.03);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start();
    osc.stop(ctx.currentTime + 0.03);
  } catch {}
}

export function playWinSound() {
  if (isMutedState) return;
  const ctx = getAudioContext();
  if (!ctx) return;
  try {
    const now = ctx.currentTime;
    [523.25, 659.25, 783.99, 1046.5].forEach((freq, idx) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "sine";
      osc.frequency.setValueAtTime(freq, now + idx * 0.08);
      gain.gain.setValueAtTime(0.15, now + idx * 0.08);
      gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.08 + 0.25);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now + idx * 0.08);
      osc.stop(now + idx * 0.08 + 0.25);
    });
  } catch {}
}

export function playLossSound() {
  if (isMutedState) return;
  const ctx = getAudioContext();
  if (!ctx) return;
  try {
    const now = ctx.currentTime;
    [320, 260, 190, 120].forEach((freq, idx) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "sawtooth";
      osc.frequency.setValueAtTime(freq, now + idx * 0.12);
      gain.gain.setValueAtTime(0.12, now + idx * 0.12);
      gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.12 + 0.22);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now + idx * 0.12);
      osc.stop(now + idx * 0.12 + 0.22);
    });
  } catch {}
}

export function playCoinSound() {
  if (isMutedState) return;
  const ctx = getAudioContext();
  if (!ctx) return;
  try {
    const now = ctx.currentTime;
    [987.77, 1318.51].forEach((freq, idx) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "sine";
      osc.frequency.setValueAtTime(freq, now + idx * 0.09);
      gain.gain.setValueAtTime(0.14, now + idx * 0.09);
      gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.09 + 0.2);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now + idx * 0.09);
      osc.stop(now + idx * 0.09 + 0.2);
    });
  } catch {}
}
EOF

# 3. Оновлення lib/inventory-storage.ts: продаж скінів, спалення при програші, гарантія унікальних ключів
cat << 'EOF' > lib/inventory-storage.ts
import { skins, inventorySkins, type Skin } from "@/app/data";

export type InventoryItem = Skin & { instanceId: string };

const INVENTORY_STORAGE_KEY = "goicoins_inventory_v3";
const BALANCE_STORAGE_KEY = "goicoins_balance_v3";

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
    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: updated }));
    return updated;
  } catch {
    return [];
  }
}

// Видалення скіна з інвентаря за унікальним instanceId (для спалення або продажу)
export function removeSkinFromInventory(instanceId: string): InventoryItem[] {
  if (typeof window === "undefined") return [];
  try {
    const current = getStoredInventory();
    const updated = current.filter((s) => s.instanceId !== instanceId);
    localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(updated));
    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: updated }));
    return updated;
  } catch {
    return [];
  }
}

// Продаж окремого скіна за повну ціну в GoiCoins (1 грн = 1 GC)
export function sellInventorySkin(item: InventoryItem): { newInventory: InventoryItem[]; newBalance: number } {
  const newInventory = removeSkinFromInventory(item.instanceId);
  const newBalance = updateStoredBalance(item.price);
  return { newInventory, newBalance };
}

// Продаж всього інвентаря одночасно
export function sellAllInventorySkins(): { count: number; totalGained: number; newBalance: number } {
  if (typeof window === "undefined") return { count: 0, totalGained: 0, newBalance: 1500 };
  const current = getStoredInventory();
  if (current.length === 0) return { count: 0, totalGained: 0, newBalance: getStoredBalance() };
  const totalGained = current.reduce((sum, s) => sum + s.price, 0);
  const newBalance = updateStoredBalance(totalGained);
  localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify([]));
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
    window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: updated }));
    return updated;
  } catch {
    return 1500;
  }
}
EOF

# 4. Оновлення app/components/site-header.tsx:
# - Розтягнутий на всю ширину Widescreen (max-w-[1760px])
# - Прибрано кнопку +100 GC (залишено тільки живий баланс валюти)
cat << 'EOF' > app/components/site-header.tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { getStoredBalance } from "@/lib/inventory-storage";

export default function SiteHeader() {
  const pathname = usePathname();
  const [balance, setBalance] = useState(1500);

  useEffect(() => {
    setBalance(getStoredBalance());
    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    return () => {
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
    };
  }, []);

  const navLinks = [
    { href: "/", label: "Апгрейдер" },
    { href: "/catalog", label: "Каталог" },
    { href: "/market", label: "Ринок 🔥", badge: "2.2к" },
    { href: "/inventory", label: "Інвентар" },
    { href: "/leaderboard", label: "Лідери" },
  ];

  return (
    <header className="sticky top-0 z-40 border-b border-white/[0.08] bg-[#080a10]/90 backdrop-blur-xl">
      <div className="mx-auto flex h-16 max-w-[1760px] items-center justify-between px-4 sm:px-6 lg:px-10 xl:px-12">
        <Link href="/" className="flex items-center gap-3">
          <div className="flex size-9 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-base font-black text-[#05130d] shadow-lg shadow-emerald-500/20">
            G
          </div>
          <div className="leading-tight">
            <span className="font-mono text-sm font-black tracking-wider text-white">
              GOICOINS
            </span>
            <span className="block text-[10px] font-semibold uppercase tracking-widest text-emerald-400">
              Skin Simulator
            </span>
          </div>
        </Link>

        <nav className="hidden md:flex items-center gap-1 rounded-2xl border border-white/[0.06] bg-black/40 p-1">
          {navLinks.map((link) => {
            const isActive = pathname === link.href;
            return (
              <Link
                key={link.href}
                href={link.href}
                className={`relative flex items-center gap-1.5 rounded-xl px-4 py-1.5 text-xs font-bold transition ${
                  isActive
                    ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20 font-black"
                    : "text-slate-400 hover:text-white hover:bg-white/5"
                }`}
              >
                <span>{link.label}</span>
                {link.badge && (
                  <span
                    className={`rounded-full px-1.5 py-0.2 text-[9px] font-black ${
                      isActive ? "bg-black/20 text-[#05130d]" : "bg-emerald-400/20 text-emerald-300"
                    }`}
                  >
                    {link.badge}
                  </span>
                )}
              </Link>
            );
          })}
        </nav>

        {/* Відображення балансу без кнопки +100 GC */}
        <div className="flex items-center gap-2">
          <div className="flex items-center gap-2 rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-3.5 py-1.5 font-mono text-xs font-black text-emerald-300 shadow-[0_0_15px_rgba(16,185,129,0.15)]">
            <span className="text-emerald-400">🪙</span>
            <span>{balance.toLocaleString("uk-UA")} GC</span>
          </div>
        </div>
      </div>
    </header>
  );
}
EOF

# 5. Оновлення головної сторінки app/page.tsx:
# - Розширений Widescreen контейнер max-w-[1760px] на весь екран
# - Смарагдовий монохромний стиль без кислотних градієнтів
cat << 'EOF' > app/page.tsx
import Link from "next/link";
import { skins } from "./data";
import { LiveDropsTicker } from "@/components/live-drops-ticker";
import { InteractiveUpgrader } from "@/components/interactive-upgrader";
import SkinTile from "./components/skin-tile";

export default function Home() {
  return (
    <div className="min-h-screen pb-20">
      <LiveDropsTicker />

      <main className="mx-auto max-w-[1760px] px-4 pt-8 sm:px-6 lg:px-10 xl:px-12">
        {/* Заголовок у смарагдовому стилі */}
        <div className="text-center max-w-4xl mx-auto mb-8">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-3.5 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-300">
            <span className="size-2 rounded-full bg-emerald-400 shadow-[0_0_8px_#10b981]" />
            Сезон 04 · Симулятор апгрейду скінів CS2
          </div>

          <h1 className="mt-4 text-4xl font-black tracking-tight text-white sm:text-5xl lg:text-6xl">
            Твій наступний скін —{" "}
            <span className="text-emerald-400 drop-shadow-[0_0_25px_rgba(52,211,153,0.35)]">
              за крок від тебе.
            </span>
          </h1>

          <p className="mt-3 text-sm sm:text-base text-slate-400">
            Обирай скін з інвентаря, вказуй бажану ціль та випробовуй удачу в кібер-рулетці.
          </p>
        </div>

        {/* Інтерактивний Апгрейдер Widescreen */}
        <InteractiveUpgrader />

        {/* Популярні скіни каталогу на всю ширину */}
        <section className="mt-16">
          <div className="flex items-center justify-between border-b border-white/[0.08] pb-4 mb-6">
            <div>
              <h2 className="text-xl font-bold text-white">Трендові скіни каталогу</h2>
              <p className="text-xs text-slate-400 mt-0.5">Найпопулярніші предмети серед гравців</p>
            </div>
            <Link
              href="/market"
              className="text-xs font-bold text-emerald-400 hover:text-emerald-300 transition"
            >
              Всі 2 246 скінів на Ринку →
            </Link>
          </div>
          <div className="grid gap-5 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
            {skins.slice(0, 8).map((skin, idx) => (
              <SkinTile key={`trending-skin-${skin.finish}-${idx}`} skin={skin} action="Апгрейдити" href="/" />
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}
EOF

# 6. Оновлення components/interactive-upgrader.tsx:
# - Розтягнута widescreen 16:9 арена на всю ширину
# - Напис "РЕЖИМ ОБЕРТАННЯ РУЛЕТКИ:" над режимами
# - Фільтр цін (< 500, 500-5k, 5k-50k, 50k-150k, 150k+) та сортування в модалці
# - Спалення програного скіна з інвентаря при невдалому апгрейді
# - Анімація згоряння скіна на екрані поразки
# - Виправлення звуків: сувора зупинка звуку після завершення та зменшена частота клацань
# - Усунення помилки React duplicate keys через instanceId
cat << 'EOF' > components/interactive-upgrader.tsx
"use client";

/* eslint-disable @next/next/no-img-element */
import { useState, useRef, useEffect, useMemo } from "react";
import type { Skin, MarketSkin } from "@/app/data";
import { formatCoins, skins, marketSkinToSkin } from "@/app/data";
import SkinArt from "@/app/components/skin-art";
import {
  playClickSound,
  playTickSound,
  playWinSound,
  playLossSound,
  toggleMute,
  isMuted,
} from "@/lib/sound-fx";
import {
  getStoredInventory,
  addSkinToInventory,
  removeSkinFromInventory,
  type InventoryItem,
} from "@/lib/inventory-storage";

type SpinMode = "fast" | "normal" | "long" | "suspense";

interface SpinConfig {
  label: string;
  spins: number;
  duration: number;
  description: string;
  icon: string;
}

const SPIN_CONFIGS: Record<SpinMode, SpinConfig> = {
  fast: {
    label: "Швидка",
    spins: 3,
    duration: 1600,
    description: "Миттєвий розіграш за 1.6с для тих, хто не любить чекати",
    icon: "⚡",
  },
  normal: {
    label: "Звичайна",
    spins: 6,
    duration: 3800,
    description: "Збалансоване обертання рулетки з плавним гальмуванням",
    icon: "🎯",
  },
  long: {
    label: "Довга",
    spins: 10,
    duration: 6500,
    description: "Максимальна напруга: 10 обертів з протяжним сповільненням",
    icon: "⏳",
  },
  suspense: {
    label: "Азартна",
    spins: 7,
    duration: 5400,
    description: "Динамічний розгін + 3 секунди повільного повзунка через межу перемоги!",
    icon: "🔥",
  },
};

export function InteractiveUpgrader() {
  const [userInventory, setUserInventory] = useState<InventoryItem[]>([]);
  const [sourceSkin, setSourceSkin] = useState<Skin>(skins[0]);
  const [targetSkin, setTargetSkin] = useState<Skin>(skins[1]);
  const [isSpinning, setIsSpinning] = useState(false);
  const [spinMode, setSpinMode] = useState<SpinMode>("normal");
  const [rotation, setRotation] = useState(0);
  const [spinTransition, setSpinTransition] = useState<string>("none");
  const [outcome, setOutcome] = useState<"win" | "loss" | null>(null);
  const [showResultModal, setShowResultModal] = useState(false);
  const [muted, setMuted] = useState(false);
  const [lostSkinBackup, setLostSkinBackup] = useState<Skin | null>(null);

  // Модалка вибору з ринку (2 246 скінів)
  const [marketSkins, setMarketSkins] = useState<MarketSkin[]>([]);
  const [isPickerOpen, setIsPickerOpen] = useState(false);
  const [pickerSlot, setPickerSlot] = useState<"source" | "target">("target");
  const [pickerSearch, setPickerSearch] = useState("");
  const [pickerCategory, setPickerCategory] = useState("all");
  const [pickerPriceRange, setPickerPriceRange] = useState("all");
  const [pickerSort, setPickerSort] = useState<"price_desc" | "price_asc" | "name_asc" | "rarity_desc">("price_desc");
  const [onlyValidUpgrades, setOnlyValidUpgrades] = useState(true);

  // Таймери та аудіо інтервали
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const crawlIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const tickIntervalRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    const inv = getStoredInventory();
    setUserInventory(inv);
    if (inv.length > 0) setSourceSkin(inv[0]);
    setMuted(isMuted());

    try {
      const selectedSourceRaw = localStorage.getItem("goicoins_selected_source");
      if (selectedSourceRaw) {
        const parsed = JSON.parse(selectedSourceRaw);
        if (parsed && parsed.name && parsed.price) {
          setSourceSkin(parsed);
          localStorage.removeItem("goicoins_selected_source");
        }
      }
    } catch {}

    try {
      const selectedTargetRaw = localStorage.getItem("goicoins_selected_target");
      if (selectedTargetRaw) {
        const parsed = JSON.parse(selectedTargetRaw);
        if (parsed && parsed.name && parsed.price) {
          setTargetSkin(parsed);
          localStorage.removeItem("goicoins_selected_target");
        }
      }
    } catch {}

    fetch("/data/cs2-market.json")
      .then((res) => res.json())
      .then((data) => setMarketSkins(data))
      .catch(() => {});

    const handleInvUpdate = (e: CustomEvent<InventoryItem[]>) => {
      if (e.detail) setUserInventory(e.detail);
    };
    window.addEventListener("goi-inventory-updated", handleInvUpdate as EventListener);

    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
      if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
      if (tickIntervalRef.current) clearInterval(tickIntervalRef.current);
      window.removeEventListener("goi-inventory-updated", handleInvUpdate as EventListener);
    };
  }, []);

  // Економіка: перевірка на даунгрейд (ціль завжди дорожча за джерело)
  const isDowngrade = targetSkin.price <= sourceSkin.price;
  const multiplier = Math.round((targetSkin.price / sourceSkin.price) * 100) / 100;
  
  // Розрахунок шансу (якщо ціль дешевша — шанс 0%)
  const rawChance = isDowngrade ? 0 : (sourceSkin.price / targetSkin.price) * 100 * 0.95;
  const chance = isDowngrade ? 0 : Math.min(95, Math.max(0.5, Math.round(rawChance * 10) / 10));
  
  const winAngle = (chance / 100) * 360;
  const circleCircumference = 270.2;
  const winStrokeDash = (winAngle / 360) * circleCircumference;
  const currentConfig = SPIN_CONFIGS[spinMode];

  const handleSoundToggle = () => {
    const next = toggleMute();
    setMuted(next);
  };

  // Вибір швидких множників
  const handleMultiplierSelect = (mult: number) => {
    playClickSound();
    const targetPrice = sourceSkin.price * mult;
    const pool = marketSkins.length > 0 ? marketSkins.map(marketSkinToSkin) : skins;
    const validPool = pool.filter((s) => s.price >= sourceSkin.price * 1.05);
    const searchPool = validPool.length > 0 ? validPool : pool;
    const bestMatch = searchPool.reduce((prev, curr) =>
      Math.abs(curr.price - targetPrice) < Math.abs(prev.price - targetPrice) ? curr : prev
    );
    setTargetSkin(bestMatch);
  };

  const handleSelectSource = (s: Skin) => {
    playClickSound();
    setSourceSkin(s);
    if (targetSkin.price <= s.price) {
      const pool = marketSkins.length > 0 ? marketSkins.map(marketSkinToSkin) : skins;
      const candidates = pool.filter((item) => item.price >= s.price * 1.2);
      if (candidates.length > 0) {
        const idealPrice = s.price * 1.5;
        const best = candidates.reduce((prev, curr) =>
          Math.abs(curr.price - idealPrice) < Math.abs(prev.price - idealPrice) ? curr : prev
        );
        setTargetSkin(best);
      }
    }
  };

  const openMarketPicker = (slot: "source" | "target") => {
    playClickSound();
    setPickerSlot(slot);
    setPickerSearch("");
    setPickerCategory("all");
    setPickerPriceRange("all");
    setOnlyValidUpgrades(slot === "target");
    setIsPickerOpen(true);
  };

  const handleSelectFromPicker = (item: MarketSkin) => {
    playClickSound();
    const converted = marketSkinToSkin(item);
    if (pickerSlot === "target") {
      setTargetSkin(converted);
    } else {
      handleSelectSource(converted);
    }
    setIsPickerOpen(false);
  };

  // Фільтрація та сортування в модалці вибору з ринку (2 246 скінів)
  const filteredPickerSkins = useMemo(() => {
    let result = marketSkins.filter((s) => {
      if (pickerSlot === "target" && onlyValidUpgrades && s.price <= sourceSkin.price) {
        return false;
      }
      if (pickerSearch.trim()) {
        const q = pickerSearch.toLowerCase().trim();
        if (!s.fullName.toLowerCase().includes(q) && !s.weapon.toLowerCase().includes(q)) return false;
      }
      if (pickerCategory !== "all") {
        if (pickerCategory === "smgs" && s.category !== "smgs") return false;
        else if (pickerCategory === "heavy" && s.category !== "heavy") return false;
        else if (pickerCategory !== "smgs" && pickerCategory !== "heavy" && s.category !== pickerCategory) return false;
      }
      if (pickerPriceRange !== "all") {
        if (pickerPriceRange === "tier1" && s.price >= 500) return false;
        if (pickerPriceRange === "tier2" && (s.price < 500 || s.price > 5000)) return false;
        if (pickerPriceRange === "tier3" && (s.price < 5000 || s.price > 50000)) return false;
        if (pickerPriceRange === "tier4" && (s.price < 50000 || s.price > 150000)) return false;
        if (pickerPriceRange === "tier5" && s.price <= 150000) return false;
      }
      return true;
    });

    result.sort((a, b) => {
      if (pickerSort === "price_desc") return b.price - a.price;
      if (pickerSort === "price_asc") return a.price - b.price;
      if (pickerSort === "name_asc") return a.fullName.localeCompare(b.fullName);
      if (pickerSort === "rarity_desc") return b.price - a.price;
      return 0;
    });

    return result.slice(0, 60);
  }, [marketSkins, pickerSearch, pickerCategory, pickerPriceRange, pickerSort, pickerSlot, onlyValidUpgrades, sourceSkin.price]);

  // Запуск апгрейду
  const handleUpgrade = () => {
    if (isSpinning || isDowngrade) return;
    playClickSound();
    setIsSpinning(true);
    setOutcome(null);
    setShowResultModal(false);

    // Зберігаємо копію скіна для показу на екрані спалення
    setLostSkinBackup({ ...sourceSkin });

    const isWin = Math.random() * 100 <= chance;

    let targetSectorAngle: number;
    if (isWin) {
      const safeMax = Math.max(5, winAngle - 4);
      targetSectorAngle = 3 + Math.random() * (safeMax - 3);
    } else {
      const darkSpan = 360 - winAngle - 10;
      targetSectorAngle = winAngle + 6 + Math.random() * Math.max(1, darkSpan);
    }

    const currentBaseCycle = Math.floor(rotation / 360);

    // Очищення попередніх таймерів
    if (tickIntervalRef.current) clearInterval(tickIntervalRef.current);
    if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
    if (timerRef.current) clearTimeout(timerRef.current);

    if (spinMode === "suspense") {
      const crawlDegrees = 110;
      const finalDegree = (currentBaseCycle + 7) * 360 + targetSectorAngle;
      const intermediateDegree = finalDegree - crawlDegrees;

      setSpinTransition("transform 2400ms cubic-bezier(0.12, 0.85, 0.25, 1)");
      requestAnimationFrame(() => {
        setRotation(intermediateDegree);
      });

      let tickFastCount = 0;
      tickIntervalRef.current = setInterval(() => {
        tickFastCount++;
        playTickSound(550 + (tickFastCount % 5) * 40);
        if (tickFastCount >= 14) {
          if (tickIntervalRef.current) clearInterval(tickIntervalRef.current);
        }
      }, 160);

      setTimeout(() => {
        setSpinTransition("transform 3000ms linear");
        setRotation(finalDegree);

        let crawlTicks = 0;
        crawlIntervalRef.current = setInterval(() => {
          crawlTicks++;
          playTickSound(490 + (crawlTicks % 3) * 35);
          if (crawlTicks >= 9) {
            if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
          }
        }, 320);

        setTimeout(() => {
          finishSpin(isWin);
        }, 3050);
      }, 2400);

    } else {
      const totalSpins = currentConfig.spins;
      const finalDegree = (currentBaseCycle + totalSpins) * 360 + targetSectorAngle;
      const duration = currentConfig.duration;
      const easing =
        spinMode === "fast"
          ? "cubic-bezier(0.2, 0.9, 0.3, 1)"
          : spinMode === "long"
          ? "cubic-bezier(0.08, 0.95, 0.12, 1)"
          : "cubic-bezier(0.1, 0.88, 0.18, 1)";

      setSpinTransition(`transform ${duration}ms ${easing}`);
      requestAnimationFrame(() => {
        setRotation(finalDegree);
      });

      // Знижена частота клацань звуку, щоб не дратувати вуха
      const tickMs = spinMode === "fast" ? 100 : spinMode === "long" ? 320 : 220;
      const maxTicks = Math.floor((duration - 250) / tickMs);
      let tickCount = 0;
      tickIntervalRef.current = setInterval(() => {
        tickCount++;
        playTickSound(520 + (tickCount % 5) * 30);
        if (tickCount >= maxTicks) {
          if (tickIntervalRef.current) clearInterval(tickIntervalRef.current);
        }
      }, tickMs);

      timerRef.current = setTimeout(() => {
        finishSpin(isWin);
      }, duration + 100);
    }
  };

  // Завершення обертання: сувора зупинка звуку, нарахування скіна при виграші або спалення при поразці
  const finishSpin = (isWin: boolean) => {
    if (tickIntervalRef.current) clearInterval(tickIntervalRef.current);
    if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
    if (timerRef.current) clearTimeout(timerRef.current);

    setIsSpinning(false);
    setOutcome(isWin ? "win" : "loss");
    setShowResultModal(true);

    if (isWin) {
      playWinSound();
      const updatedInv = addSkinToInventory(targetSkin);
      setUserInventory(updatedInv);
    } else {
      playLossSound();
      // РЕАЛЬНЕ СПАЛЕННЯ СКІНА: при програші скін безповоротно видаляється з інвентаря
      const currentItem = userInventory.find(
        (i) => i.instanceId === (sourceSkin as InventoryItem).instanceId || i.finish === sourceSkin.finish
      );
      if (currentItem && currentItem.instanceId) {
        const remaining = removeSkinFromInventory(currentItem.instanceId);
        setUserInventory(remaining);
        if (remaining.length > 0) {
          setSourceSkin(remaining[0]);
        } else {
          setSourceSkin(skins[0]);
        }
      }
    }
  };

  return (
    <div className="relative overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0d1018]/95 p-6 sm:p-8 lg:p-10 shadow-2xl shadow-black/80 backdrop-blur-xl w-full">
      {/* Верхній статус бар: назва, типи прокрутки з підписом та звук */}
      <div className="flex flex-wrap items-center justify-between gap-4 border-b border-white/[0.06] pb-5">
        <div className="flex items-center gap-2.5">
          <span className="size-2.5 rounded-full bg-emerald-400 shadow-[0_0_12px_#10b981]" />
          <h2 className="text-sm font-black uppercase tracking-wider text-white">
            CS2 UPGRADER ARENA · КІБЕР-РУЛЕТКА
          </h2>
        </div>

        {/* Секція типів прокрутки з чітким підписом */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center gap-2">
          <span className="text-[10px] font-black uppercase tracking-wider text-slate-400">
            РЕЖИМ ОБЕРТАННЯ РУЛЕТКИ:
          </span>
          <div className="flex items-center gap-1 rounded-xl border border-white/[0.08] bg-black/40 p-1">
            {(Object.keys(SPIN_CONFIGS) as SpinMode[]).map((mode) => {
              const cfg = SPIN_CONFIGS[mode];
              const isActive = spinMode === mode;
              return (
                <button
                  key={`mode-btn-${mode}`}
                  onClick={() => {
                    if (!isSpinning) {
                      playClickSound();
                      setSpinMode(mode);
                    }
                  }}
                  disabled={isSpinning}
                  title={cfg.description}
                  className={`flex items-center gap-1 rounded-lg px-2.5 py-1 text-xs font-bold transition ${
                    isActive
                      ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20 font-black"
                      : "text-slate-400 hover:text-white hover:bg-white/5"
                  }`}
                >
                  <span>{cfg.icon}</span>
                  <span>{cfg.label}</span>
                </button>
              );
            })}
          </div>
        </div>

        <button
          onClick={handleSoundToggle}
          className="rounded-lg border border-white/10 bg-white/5 px-3 py-1.5 text-xs font-semibold text-slate-400 hover:text-white transition"
        >
          {muted ? "🔇 Без звуку" : "🔊 Звук увімкнено"}
        </button>
      </div>

      {/* 3-Колонкова арена Widescreen: рівномірно розподілена по всьому екрану */}
      <div className="mt-8 grid grid-cols-1 items-stretch gap-6 xl:gap-8 lg:grid-cols-[1fr_auto_1fr]">
        
        {/* ЛІВА КОЛОНКА (Твій скін для апгрейду) */}
        <div className="w-full flex flex-col justify-between rounded-2xl border border-white/[0.08] bg-black/50 p-6 shadow-xl">
          <div>
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Твій скін (для апгрейду)
              </span>
              <span className="font-mono text-sm font-bold text-emerald-400">
                {formatCoins(sourceSkin.price)} GC
              </span>
            </div>
            <div className="my-4 cursor-pointer" onClick={() => openMarketPicker("source")} title="Клікни, щоб обрати інший скін">
              <SkinArt skin={sourceSkin} className="h-40 sm:h-44" />
            </div>
            <p className="font-bold text-white truncate text-lg">
              {sourceSkin.weapon} | {sourceSkin.name}
            </p>
            <p className="text-xs text-slate-400 mt-1">{sourceSkin.wear}</p>
          </div>

          <div className="mt-6 border-t border-white/[0.06] pt-4">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Твій інвентар:
              </span>
              <button
                onClick={() => openMarketPicker("source")}
                className="text-xs font-bold text-emerald-400 hover:text-emerald-300 underline"
              >
                З Ринку 🛒
              </button>
            </div>
            <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
              {userInventory.map((s, idx) => (
                <button
                  key={s.instanceId ? `inv-${s.instanceId}` : `inv-fallback-${s.finish}-${idx}`}
                  onClick={() => handleSelectSource(s)}
                  className={`shrink-0 rounded-lg border px-2.5 py-1 text-xs font-semibold transition ${
                    sourceSkin.finish === s.finish
                      ? "border-emerald-400 bg-emerald-400/20 text-emerald-200"
                      : "border-white/5 bg-white/5 text-slate-400 hover:bg-white/10"
                  }`}
                >
                  {s.weapon}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* ЦЕНТРАЛЬНА КОЛОНКА: СМАРАГДОВЕ КОЛЕСО ПО ЦЕНТРУ */}
        <div className="flex flex-col items-center justify-center justify-self-center px-4 min-w-[320px] sm:min-w-[400px]">
          <div className="relative flex size-80 items-center justify-center sm:size-96">
            <svg className="size-full -rotate-90 transform" viewBox="0 0 100 100">
              <circle
                cx="50"
                cy="50"
                r="43"
                className="stroke-[#131826]"
                strokeWidth="6"
                fill="transparent"
              />
              {!isDowngrade && (
                <circle
                  cx="50"
                  cy="50"
                  r="43"
                  className="stroke-emerald-400 transition-all duration-300 drop-shadow-[0_0_15px_rgba(52,211,153,0.6)]"
                  strokeWidth="6"
                  strokeDasharray={`${winStrokeDash} ${circleCircumference}`}
                  strokeLinecap="butt"
                  fill="transparent"
                />
              )}
            </svg>

            {/* Стрілка: Смарагдовий лазерний шеврон */}
            <div
              className="pointer-events-none absolute inset-0 z-20 flex items-center justify-center will-change-transform"
              style={{
                transform: `rotate(${rotation}deg)`,
                transition: spinTransition,
              }}
            >
              <div className="absolute top-2.5 flex flex-col items-center">
                <div className="h-5 w-1 bg-gradient-to-t from-emerald-400 to-transparent shadow-[0_0_10px_#34d399]" />
                <div className="size-0 border-x-[8px] border-t-[14px] border-x-transparent border-t-emerald-400 drop-shadow-[0_0_12px_#34d399]" />
                <div className="size-2 -mt-1 rounded-full bg-white shadow-[0_0_8px_#34d399]" />
              </div>
            </div>

            {/* Центр рулетки */}
            <div className="absolute flex flex-col items-center justify-center text-center max-w-[220px]">
              {isDowngrade ? (
                <div className="flex flex-col items-center">
                  <span className="text-xs font-black uppercase tracking-wider text-rose-400">
                    ⚠️ ДАУНГРЕЙД
                  </span>
                  <span className="mt-1 text-xs font-bold text-slate-300">
                    Ціль дешевша за скін!
                  </span>
                  <span className="mt-2 rounded-lg border border-amber-500/30 bg-amber-500/10 px-2 py-0.5 text-[10px] font-bold text-amber-300">
                    Обери від {formatCoins(Math.round(sourceSkin.price * 1.1))} GC
                  </span>
                </div>
              ) : (
                <>
                  <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
                    ШАНС АПГРЕЙДУ
                  </span>
                  <span className="font-mono text-4xl font-black text-white sm:text-5xl">
                    {chance}%
                  </span>
                  <span className="mt-1.5 rounded-full border border-emerald-500/20 bg-emerald-500/10 px-3 py-0.5 font-mono text-xs font-bold text-emerald-300">
                    ×{multiplier}
                  </span>
                  <span className="mt-1 text-xs text-slate-400 font-medium">
                    Режим: {currentConfig.label}
                  </span>
                </>
              )}
            </div>
          </div>

          {/* Швидкі множники */}
          <div className="mt-4 flex items-center gap-1.5 rounded-xl border border-white/[0.06] bg-black/40 p-2">
            {[1.5, 2, 3, 5, 10, 15].map((m) => (
              <button
                key={`mult-btn-${m}`}
                onClick={() => handleMultiplierSelect(m)}
                disabled={isSpinning}
                className="rounded-lg px-3 py-1 font-mono text-xs font-bold text-slate-400 transition hover:bg-emerald-500/10 hover:text-emerald-300 disabled:opacity-40"
              >
                {m}×
              </button>
            ))}
          </div>
        </div>

        {/* ПРАВА КОЛОНКА (Бажана ціль для виграшу) */}
        <div className="w-full flex flex-col justify-between rounded-2xl border border-white/[0.08] bg-black/50 p-6 shadow-xl">
          <div>
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Бажаний скін (ціль)
              </span>
              <span className={`font-mono text-sm font-bold ${isDowngrade ? "text-rose-400" : "text-emerald-400"}`}>
                {formatCoins(targetSkin.price)} GC
              </span>
            </div>
            <div className="my-4 cursor-pointer" onClick={() => openMarketPicker("target")} title="Клікни, щоб обрати іншу ціль">
              <SkinArt skin={targetSkin} className="h-40 sm:h-44" />
            </div>
            <p className="font-bold text-white truncate text-lg">
              {targetSkin.weapon} | {targetSkin.name}
            </p>
            <p className="text-xs text-slate-400 mt-1">{targetSkin.wear}</p>
          </div>

          <div className="mt-6 border-t border-white/[0.06] pt-4">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Швидка ціль:
              </span>
              <button
                onClick={() => openMarketPicker("target")}
                className="text-xs font-bold text-emerald-400 hover:text-emerald-300 underline"
              >
                Обрати з Ринку (2.2к) 🔍
              </button>
            </div>
            <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
              {skins.map((s, idx) => (
                <button
                  key={`target-select-btn-${s.finish}-${idx}`}
                  onClick={() => {
                    playClickSound();
                    setTargetSkin(s);
                  }}
                  className={`shrink-0 rounded-lg border px-2.5 py-1 text-xs font-semibold transition ${
                    targetSkin.finish === s.finish
                      ? "border-emerald-400 bg-emerald-400/20 text-emerald-200"
                      : "border-white/5 bg-white/5 text-slate-400 hover:bg-white/10"
                  }`}
                >
                  {s.weapon}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Велика смарагдова кнопка апгрейду */}
      <div className="mt-10 flex justify-center">
        <button
          onClick={handleUpgrade}
          disabled={isSpinning || isDowngrade}
          className={`w-full max-w-xl rounded-2xl py-4 text-base font-black uppercase tracking-wider transition shadow-2xl ${
            isSpinning
              ? "cursor-not-allowed bg-slate-800 text-slate-500 border border-white/5"
              : isDowngrade
              ? "cursor-not-allowed bg-slate-800/90 text-rose-400 border border-rose-500/30 shadow-none"
              : "bg-emerald-500 hover:bg-emerald-400 text-[#05130d] shadow-emerald-500/25 border border-emerald-400/40 active:scale-[0.99]"
          }`}
        >
          {isSpinning
            ? "Крутимо рулетку..."
            : isDowngrade
            ? "⚠️ ДАУНГРЕЙД ЗАБОРОНЕНО (ОБЕРИ ДОРОЖЧУ ЦІЛЬ)"
            : "АПГРЕЙДИТИ СКІН ⚡"}
        </button>
      </div>

      {/* Модальне вікно вибору будь-якого скіна з Ринку (фільтри за ціною + сортування) */}
      {isPickerOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
          <div className="w-full max-w-5xl max-h-[90vh] flex flex-col rounded-3xl border border-white/10 bg-[#0e111a] p-6 shadow-2xl">
            <div className="flex items-center justify-between border-b border-white/[0.08] pb-4">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-emerald-400">
                  {pickerSlot === "target" ? "🎯 ОБЕРИ БАЖАНУ ЦІЛЬ ДЛЯ АПГРЕЙДУ" : "🎒 ОБЕРИ СКІН ДЛЯ АПГРЕЙДУ"}
                </span>
                <h3 className="text-2xl font-black text-white">Каталог скінів CS2 (2 246 скінів)</h3>
              </div>
              <button
                onClick={() => setIsPickerOpen(false)}
                className="size-9 rounded-full border border-white/10 bg-white/5 text-base font-bold text-slate-400 hover:text-white"
              >
                ✕
              </button>
            </div>

            {/* Панель фільтрів: Пошук, Цінові діапазони, Сортування та Категорії */}
            <div className="my-4 space-y-3">
              <div className="flex flex-col sm:flex-row gap-3 items-center">
                <input
                  type="text"
                  value={pickerSearch}
                  onChange={(e) => setPickerSearch(e.target.value)}
                  placeholder="Швидкий пошук: Dragon Lore, Doppler, Fade, AK-47, Printstream..."
                  className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-2.5 text-sm text-white placeholder-slate-500 outline-none focus:border-emerald-400"
                />
                
                {/* Сортування */}
                <select
                  value={pickerSort}
                  onChange={(e) => setPickerSort(e.target.value as any)}
                  className="rounded-xl border border-white/10 bg-black/50 px-3 py-2.5 text-xs font-bold text-white outline-none focus:border-emerald-400 shrink-0"
                >
                  <option value="price_desc">Ціна: від дорогих</option>
                  <option value="price_asc">Ціна: від дешевих</option>
                  <option value="name_asc">Назва: А - Я</option>
                  <option value="rarity_desc">Рідкість</option>
                </select>

                {pickerSlot === "target" && (
                  <label className="flex items-center gap-2 shrink-0 text-xs font-bold text-slate-300 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={onlyValidUpgrades}
                      onChange={(e) => setOnlyValidUpgrades(e.target.checked)}
                      className="size-4 rounded accent-emerald-500"
                    />
                    <span>Дорожчі за скін ({formatCoins(sourceSkin.price)} GC)</span>
                  </label>
                )}
              </div>

              {/* Фільтри за діапазоном цін */}
              <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar">
                <span className="text-[10px] font-bold uppercase text-slate-400 shrink-0">Ціна:</span>
                {[
                  { id: "all", label: "Всі ціни" },
                  { id: "tier1", label: "< 500 GC" },
                  { id: "tier2", label: "500 - 5 000 GC" },
                  { id: "tier3", label: "5k - 50 000 GC" },
                  { id: "tier4", label: "50k - 150 000 GC" },
                  { id: "tier5", label: "> 150 000 GC ★" },
                ].map((tier) => (
                  <button
                    key={`price-tier-${tier.id}`}
                    onClick={() => {
                      playClickSound();
                      setPickerPriceRange(tier.id);
                    }}
                    className={`rounded-lg px-2.5 py-1 text-xs font-bold transition shrink-0 ${
                      pickerPriceRange === tier.id
                        ? "bg-emerald-500 text-[#05130d] font-black"
                        : "border border-white/5 bg-white/5 text-slate-400 hover:text-white"
                    }`}
                  >
                    {tier.label}
                  </button>
                ))}
              </div>

              {/* Категорії */}
              <div className="flex gap-1.5 overflow-x-auto pb-1 no-scrollbar">
                {[
                  { id: "all", label: "Всі" },
                  { id: "knives", label: "Ножі ★" },
                  { id: "gloves", label: "Рукавички ★" },
                  { id: "snipers", label: "Снайперки" },
                  { id: "rifles", label: "Гвинтівки" },
                  { id: "pistols", label: "Пістолети" },
                  { id: "smgs", label: "ПП" },
                  { id: "heavy", label: "Важке" },
                ].map((c) => (
                  <button
                    key={`picker-cat-${c.id}`}
                    onClick={() => {
                      playClickSound();
                      setPickerCategory(c.id);
                    }}
                    className={`rounded-lg px-3 py-1 text-xs font-bold transition ${
                      pickerCategory === c.id
                        ? "bg-emerald-500 text-[#05130d] font-black"
                        : "border border-white/5 bg-white/5 text-slate-400 hover:text-white"
                    }`}
                  >
                    {c.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Список скінів */}
            <div className="overflow-y-auto flex-1 pr-1 grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3">
              {filteredPickerSkins.map((item, idx) => (
                <button
                  key={`picker-item-${item.id}-${idx}`}
                  onClick={() => handleSelectFromPicker(item)}
                  className="group relative flex flex-col justify-between rounded-xl border border-white/10 bg-[#080a10] p-3 text-left transition hover:border-emerald-400 hover:bg-emerald-400/5 hover:-translate-y-0.5"
                >
                  <div
                    className="relative flex h-24 items-center justify-center overflow-hidden rounded-lg bg-black/40"
                    style={{
                      backgroundImage: `radial-gradient(circle at center, ${item.rarityColor}20, transparent 75%)`,
                    }}
                  >
                    <img
                      src={item.image}
                      alt={item.fullName}
                      className="max-h-[85%] max-w-[90%] object-contain drop-shadow transition-transform group-hover:scale-110"
                      loading="lazy"
                    />
                    <span
                      className="absolute top-1 right-1 rounded px-1.5 py-0.2 text-[8px] font-black uppercase"
                      style={{ color: item.rarityColor }}
                    >
                      {item.rarityUk}
                    </span>
                  </div>

                  <div className="mt-2">
                    <p className="text-[10px] font-bold text-slate-500 uppercase truncate">{item.weapon}</p>
                    <p className="text-xs font-bold text-white truncate">{item.name}</p>
                    <p className="font-mono text-xs font-black text-emerald-400 mt-1">
                      {formatCoins(item.price)} GC
                    </p>
                  </div>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Модальне вікно результату з анімацією спалення при поразці */}
      {showResultModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
          <div className="w-full max-w-sm rounded-3xl border border-white/10 bg-[#0e111a] p-6 text-center shadow-2xl">
            {outcome === "win" ? (
              <>
                <div className="mx-auto flex size-16 items-center justify-center rounded-full bg-emerald-500/20 text-3xl shadow-[0_0_20px_#10b981]">
                  🎉
                </div>
                <h3 className="mt-4 text-2xl font-black text-white">УСПІШНИЙ АПГРЕЙД!</h3>
                <p className="mt-1 text-sm text-emerald-400 font-bold">
                  {targetSkin.weapon} | {targetSkin.name} додано до твого інвентаря!
                </p>
                <div className="my-4">
                  <SkinArt skin={targetSkin} className="h-32" />
                </div>
              </>
            ) : (
              <>
                <div className="mx-auto flex size-16 items-center justify-center rounded-full bg-rose-500/20 text-3xl shadow-[0_0_25px_#ef4444] animate-pulse">
                  🔥
                </div>
                <h3 className="mt-4 text-2xl font-black text-rose-400">СКІН ЗГОРІВ У РУЛЕТЦІ!</h3>
                <p className="mt-1 text-xs text-slate-400">
                  Стрілка зупинилася в темній зоні. Скін втрачено назавжди!
                </p>
                
                {/* Анімація згоряння скіна на очах у гравця */}
                <div className="relative my-4 overflow-hidden rounded-2xl border border-rose-500/30 bg-rose-950/20 p-2">
                  <div className="transition-all duration-1000 scale-90 opacity-20 blur-[1px] grayscale contrast-150">
                    <SkinArt skin={lostSkinBackup || sourceSkin} className="h-28" />
                  </div>
                  <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                    <span className="text-2xl animate-bounce">🔥</span>
                    <span className="mt-1 rounded-full bg-rose-500/40 px-2.5 py-0.5 font-mono text-[11px] font-black text-rose-200 border border-rose-500/50">
                      −{formatCoins((lostSkinBackup || sourceSkin).price)} GC (СПАЛЕНО)
                    </span>
                  </div>
                </div>
              </>
            )}
            <div className="mt-6 flex flex-col gap-2">
              <button
                onClick={() => {
                  playClickSound();
                  setShowResultModal(false);
                }}
                className="w-full rounded-xl bg-emerald-500 hover:bg-emerald-400 py-3 text-sm font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition"
              >
                Продовжити апгрейд ⚡
              </button>
              {outcome === "win" && (
                <a
                  href="/inventory"
                  className="w-full rounded-xl border border-white/10 bg-white/5 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/10 transition"
                >
                  Переглянути в інвентарі →
                </a>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
EOF

# 7. Оновлення сторінки Інвентаря app/inventory/page.tsx:
# - Розтягнутий на всю ширину Widescreen (max-w-[1760px])
# - Можливість продажу будь-якого скіна за повну ціну в GoiCoins (GC)
# - Кнопка "Продати весь інвентар" з миттєвим нарахуванням монет
# - Звукові ефекти та сповіщення про продаж
cat << 'EOF' > app/inventory/page.tsx
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
  type InventoryItem,
} from "@/lib/inventory-storage";
import { playCoinSound, playClickSound } from "@/lib/sound-fx";

export default function InventoryPage() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [balance, setBalance] = useState(1500);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  useEffect(() => {
    setInventory(getStoredInventory());
    setBalance(getStoredBalance());

    const handleInv = (e: CustomEvent<InventoryItem[]>) => {
      if (e.detail) setInventory(e.detail);
    };
    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };

    window.addEventListener("goi-inventory-updated", handleInv as EventListener);
    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    return () => {
      window.removeEventListener("goi-inventory-updated", handleInv as EventListener);
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
    };
  }, []);

  const totalValue = inventory.reduce((acc, s) => acc + s.price, 0);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 3000);
  };

  const handleSellSkin = (item: InventoryItem) => {
    playCoinSound();
    const { newInventory, newBalance } = sellInventorySkin(item);
    setInventory(newInventory);
    setBalance(newBalance);
    showToast(`💰 Продано ${item.weapon} | ${item.name} за +${formatCoins(item.price)} GC!`);
  };

  const handleSellAll = () => {
    if (inventory.length === 0) return;
    playCoinSound();
    const { count, totalGained, newBalance } = sellAllInventorySkins();
    setInventory([]);
    setBalance(newBalance);
    showToast(`🎉 Продано всі ${count} скінів на суму +${formatCoins(totalGained)} GC!`);
  };

  const handleSelectAsUpgradeSource = (item: InventoryItem) => {
    playClickSound();
    try {
      localStorage.setItem("goicoins_selected_source", JSON.stringify(item));
    } catch {}
  };

  return (
    <div className="mx-auto max-w-[1760px] px-4 py-8 sm:px-6 lg:px-10 xl:px-12 min-h-screen">
      {/* Спливаюче сповіщення про продаж */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 rounded-2xl border border-emerald-500/40 bg-[#0d1614]/95 px-5 py-3 text-sm font-bold text-emerald-300 shadow-2xl backdrop-blur-md animate-fade-in">
          {toastMessage}
        </div>
      )}

      {/* Верхня панель профілю та балансу */}
      <div className="mb-8 overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 sm:p-8 shadow-xl">
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div className="flex items-center gap-4">
            <div className="flex size-16 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 text-2xl font-black text-[#05130d] shadow-lg shadow-emerald-500/20">
              G
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-2xl font-black text-white">Гравець demo-player</h1>
                <span className="rounded-md bg-emerald-400/20 px-2 py-0.5 text-xs font-bold text-emerald-300">
                  Global Elite
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">ID: #GP-88391 · Твій персональний інвентар CS2</p>
            </div>
          </div>

          <div className="flex flex-wrap gap-4">
            <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 px-5 py-3">
              <p className="text-[10px] font-bold uppercase tracking-wider text-emerald-300">Баланс GC</p>
              <p className="mt-0.5 font-mono text-xl font-black text-white">
                {balance.toLocaleString("uk-UA")} GC
              </p>
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

      {/* Панель дій над інвентарем */}
      <div className="mb-6 flex flex-wrap items-center justify-between gap-4 border-b border-white/[0.08] pb-4">
        <div>
          <h2 className="text-2xl font-black text-white">
            Предмети в інвентарі ({inventory.length})
          </h2>
          <p className="text-xs text-slate-400 mt-0.5">
            Ти можеш продати будь-який скін за повну вартість у GoiCoins або запустити його в кібер-апгрейд.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2.5">
          {inventory.length > 0 && (
            <button
              onClick={handleSellAll}
              className="rounded-xl border border-amber-500/30 bg-amber-500/10 px-4 py-2 text-xs font-black text-amber-300 hover:bg-amber-500/20 transition"
            >
              💰 Продати весь інвентар ({formatCoins(totalValue)} GC)
            </button>
          )}
          <Link
            href="/market"
            className="rounded-xl border border-white/10 bg-white/5 px-4 py-2 text-xs font-bold text-slate-300 hover:bg-white/10 transition"
          >
            Ринок скінів (2.2к) 🛒
          </Link>
          <Link
            href="/"
            className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-4 py-2 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition"
          >
            До Апгрейдера ⚡
          </Link>
        </div>
      </div>

      {/* Сітка предметів Widescreen */}
      {inventory.length === 0 ? (
        <div className="flex flex-col items-center justify-center rounded-3xl border border-dashed border-white/10 bg-[#0c0f17] py-20 text-center">
          <div className="text-4xl">🎒</div>
          <h3 className="mt-4 text-xl font-bold text-white">Твій інвентар порожній</h3>
          <p className="mt-1 max-w-sm text-xs text-slate-400">
            Всі скіни було продано або програно в рулетці. Відвідай Ринок, щоб придбати нові предмети!
          </p>
          <Link
            href="/market"
            className="mt-6 rounded-xl bg-emerald-500 hover:bg-emerald-400 px-6 py-2.5 text-xs font-black text-[#05130d] shadow-lg transition"
          >
            Перейти на Ринок CS2 →
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
          {inventory.map((item, idx) => (
            <div
              key={`inv-grid-item-${item.instanceId || `${item.finish}-${idx}`}`}
              className="group relative flex flex-col justify-between rounded-2xl border border-white/[0.08] bg-[#0c0f17] p-3.5 transition hover:border-emerald-400/50 hover:shadow-xl hover:shadow-black/60"
            >
              <div>
                <SkinArt skin={item} className="h-32" />
                <div className="mt-3">
                  <div className="flex items-start justify-between gap-1">
                    <div>
                      <p className="text-[10px] font-bold text-slate-500 uppercase truncate">
                        {item.weapon}
                      </p>
                      <h3 className="text-xs font-bold text-white truncate">{item.name}</h3>
                    </div>
                    <span className="rounded px-1.5 py-0.2 text-[8px] font-black uppercase text-emerald-400 bg-emerald-400/10">
                      {item.rarity}
                    </span>
                  </div>
                  <p className="text-[11px] text-slate-400 mt-0.5">{item.wear}</p>
                </div>
              </div>

              <div className="mt-4 space-y-2 border-t border-white/[0.06] pt-3">
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-bold uppercase text-slate-500">Ціна продажу:</span>
                  <span className="font-mono text-xs font-black text-emerald-400">
                    {formatCoins(item.price)} GC
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-1.5">
                  <Link
                    href="/"
                    onClick={() => handleSelectAsUpgradeSource(item)}
                    className="rounded-lg bg-emerald-500 hover:bg-emerald-400 py-1.5 text-center text-[11px] font-black text-[#05130d] transition"
                  >
                    Апгрейд ⚡
                  </Link>
                  <button
                    onClick={() => handleSellSkin(item)}
                    className="rounded-lg border border-amber-500/30 bg-amber-500/10 hover:bg-amber-500/20 py-1.5 text-center text-[11px] font-bold text-amber-300 transition"
                  >
                    Продати 💰
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
EOF

# 8. Оновлення сторінки Ринку app/market/page.tsx:
# - Розтягнутий на всю ширину Widescreen (max-w-[1760px])
# - Прибрано кнопку +100 GC (залишено тільки реальний баланс)
cat << 'EOF' > app/market/page.tsx
"use client";

/* eslint-disable @next/next/no-img-element */
import { useState, useEffect, useMemo } from "react";
import Link from "next/link";
import { formatCoins, type MarketSkin, marketSkinToSkin } from "@/app/data";
import {
  getStoredBalance,
  updateStoredBalance,
  addSkinToInventory,
} from "@/lib/inventory-storage";
import { playWinSound, playClickSound } from "@/lib/sound-fx";

export default function MarketPage() {
  const [marketSkins, setMarketSkins] = useState<MarketSkin[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("all");
  const [selectedRarity, setSelectedRarity] = useState("all");
  const [priceSort, setPriceSort] = useState<"desc" | "asc">("desc");
  const [balance, setBalance] = useState(1500);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  useEffect(() => {
    setBalance(getStoredBalance());

    fetch("/data/cs2-market.json")
      .then((res) => res.json())
      .then((data: MarketSkin[]) => {
        setMarketSkins(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Помилка завантаження ринку:", err);
        setLoading(false);
      });

    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    return () => {
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
    };
  }, []);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  const handleBuySkin = (skin: MarketSkin) => {
    const currentBal = getStoredBalance();
    if (currentBal < skin.price) {
      showToast(
        `⚠️ Недостатньо GC! Твій баланс: ${currentBal.toLocaleString("uk-UA")} GC. Потрібно: ${skin.price.toLocaleString("uk-UA")} GC. Продай скіни в інвентарі або підніми баланс!`
      );
      return;
    }

    playWinSound();
    updateStoredBalance(-skin.price);
    const converted = marketSkinToSkin(skin);
    addSkinToInventory(converted);
    showToast(`🎉 Вітаємо! Скін ${skin.fullName} успішно куплено та додано в Інвентар!`);
  };

  const handleSelectForUpgrade = (skin: MarketSkin) => {
    playClickSound();
    const converted = marketSkinToSkin(skin);
    try {
      localStorage.setItem("goicoins_selected_target", JSON.stringify(converted));
    } catch {}
  };

  const categories = [
    { id: "all", label: "Всі категорії" },
    { id: "knives", label: "Ножі ★" },
    { id: "gloves", label: "Рукавички ★" },
    { id: "snipers", label: "Снайперки" },
    { id: "rifles", label: "Гвинтівки" },
    { id: "pistols", label: "Пістолети" },
    { id: "smgs", label: "ПП" },
    { id: "heavy", label: "Важке" },
  ];

  const rarities = [
    { id: "all", label: "Всі рідкості" },
    { id: "covert", label: "Таємне (Червоне)" },
    { id: "classified", label: "Засекречене (Рожеве)" },
    { id: "restricted", label: "Заборонене (Фіолетове)" },
    { id: "mil-spec", label: "Армійське (Синє)" },
    { id: "extraordinary", label: "Надзвичайне ★" },
    { id: "contraband", label: "Контрабандне" },
  ];

  const filteredSkins = useMemo(() => {
    return marketSkins
      .filter((skin) => {
        if (selectedCategory !== "all") {
          if (selectedCategory === "knives" && skin.category !== "knives") return false;
          if (selectedCategory === "gloves" && skin.category !== "gloves") return false;
          if (selectedCategory === "snipers" && skin.category !== "snipers") return false;
          if (selectedCategory === "rifles" && skin.category !== "rifles") return false;
          if (selectedCategory === "pistols" && skin.category !== "pistols") return false;
          if (selectedCategory === "smgs" && skin.category !== "smgs") return false;
          if (selectedCategory === "heavy" && skin.category !== "heavy") return false;
        }

        if (selectedRarity !== "all") {
          if (selectedRarity === "extraordinary" && !skin.rarityUk.includes("★")) return false;
          else if (selectedRarity !== "extraordinary" && !skin.rarity.toLowerCase().includes(selectedRarity)) return false;
        }

        if (search.trim()) {
          const q = search.toLowerCase().trim();
          const matchName = skin.fullName.toLowerCase().includes(q);
          const matchWeapon = skin.weapon.toLowerCase().includes(q);
          if (!matchName && !matchWeapon) return false;
        }

        return true;
      })
      .sort((a, b) => {
        return priceSort === "desc" ? b.price - a.price : a.price - b.price;
      });
  }, [marketSkins, selectedCategory, selectedRarity, search, priceSort]);

  return (
    <div className="mx-auto max-w-[1760px] px-4 py-8 sm:px-6 lg:px-10 xl:px-12 min-h-screen">
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 max-w-md rounded-2xl border border-emerald-500/40 bg-[#0e1614]/95 p-4 text-xs font-bold text-emerald-300 shadow-2xl backdrop-blur-md">
          {toastMessage}
        </div>
      )}

      {/* Верхній банер ринку Widescreen */}
      <div className="overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0c0f17] p-6 sm:p-8">
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div className="max-w-2xl">
            <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wider text-emerald-300">
              <span className="size-2 rounded-full bg-emerald-400 shadow-[0_0_8px_#10b981]" />
              Офіційний ринок CS2 · 2 246 скінів
            </div>
            <h1 className="mt-3 text-3xl font-black text-white sm:text-4xl">
              Повний Ринок Скінів Counter-Strike 2
            </h1>
            <p className="mt-2 text-sm text-slate-400 sm:text-base">
              Повний каталог скінів Counter-Strike 2 з офіційними зображеннями Steam. 
              Курс симулятора суворо калібровано: <span className="font-bold text-emerald-400">1 грн = 1 GoiCoin (GC)</span>.
            </p>
          </div>

          {/* Плашка балансу без кнопки +100 GC */}
          <div className="flex flex-col gap-3 rounded-2xl border border-white/[0.08] bg-black/40 p-5 min-w-[240px]">
            <span className="text-xs font-bold uppercase tracking-wider text-slate-400">Твій баланс</span>
            <p className="font-mono text-2xl font-black text-emerald-400">
              {balance.toLocaleString("uk-UA")} <span className="text-sm">GC</span>
            </p>
            <div className="flex gap-2">
              <Link
                href="/"
                className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-3 py-1.5 text-xs font-black text-[#05130d] text-center flex-1 transition"
              >
                До Апгрейдера ⚡
              </Link>
              <Link
                href="/inventory"
                className="rounded-xl border border-white/10 bg-white/5 px-3 py-1.5 text-xs font-bold text-slate-300 hover:bg-white/10 text-center flex-1 transition"
              >
                Інвентар 🎒
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* Панель фільтрів та пошуку */}
      <div className="mt-8 space-y-4 rounded-3xl border border-white/[0.08] bg-[#0c0f17] p-6">
        <div className="flex flex-col sm:flex-row gap-4 items-center justify-between">
          <div className="relative flex-1 w-full">
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Пошук скіна: AWP | Dragon Lore, AK-47, Printstream, Doppler..."
              className="w-full rounded-2xl border border-white/10 bg-black/50 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none focus:border-emerald-400 transition"
            />
          </div>

          <div className="flex items-center gap-2 shrink-0">
            <button
              onClick={() => {
                playClickSound();
                setPriceSort(priceSort === "desc" ? "asc" : "desc");
              }}
              className="flex items-center gap-2 rounded-2xl border border-white/10 bg-black/50 px-4 py-3 text-xs font-bold text-white hover:border-emerald-400 transition"
            >
              <span>Ціна:</span>
              <span className="text-emerald-400">
                {priceSort === "desc" ? "від дорогих ↓" : "від дешевих ↑"}
              </span>
            </button>
          </div>
        </div>

        {/* Категорії зброї */}
        <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
          {categories.map((cat) => (
            <button
              key={`market-cat-${cat.id}`}
              onClick={() => {
                playClickSound();
                setSelectedCategory(cat.id);
              }}
              className={`rounded-xl px-3.5 py-1.5 text-xs font-bold transition shrink-0 ${
                selectedCategory === cat.id
                  ? "bg-emerald-500 text-[#05130d] font-black"
                  : "border border-white/5 bg-white/5 text-slate-400 hover:text-white"
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Рідкості */}
        <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
          {rarities.map((r) => (
            <button
              key={`market-rarity-${r.id}`}
              onClick={() => {
                playClickSound();
                setSelectedRarity(r.id);
              }}
              className={`rounded-xl px-3 py-1 text-xs font-semibold transition shrink-0 ${
                selectedRarity === r.id
                  ? "border border-emerald-400 bg-emerald-400/20 text-emerald-300"
                  : "border border-white/5 bg-white/5 text-slate-400 hover:text-white"
              }`}
            >
              {r.label}
            </button>
          ))}
        </div>
      </div>

      {/* Список скінів на Widescreen сітці */}
      <div className="mt-8">
        <div className="mb-4 flex items-center justify-between text-xs text-slate-400">
          <span>Знайдено: <strong className="text-white">{filteredSkins.length}</strong> скінів</span>
        </div>

        {loading ? (
          <div className="py-20 text-center">
            <div className="inline-block size-8 animate-spin rounded-full border-4 border-emerald-500 border-t-transparent" />
            <p className="mt-3 text-sm text-slate-400">Завантажуємо каталог 2 246 скінів CS2...</p>
          </div>
        ) : filteredSkins.length === 0 ? (
          <div className="py-20 text-center">
            <p className="text-base font-bold text-slate-400">Скінів за вашим запитом не знайдено.</p>
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
            {filteredSkins.map((skin, idx) => (
              <article
                key={`market-skin-card-${skin.id}-${idx}`}
                className="group relative flex flex-col justify-between rounded-2xl border border-white/[0.08] bg-[#0c0f17] p-3.5 transition hover:-translate-y-1 hover:border-emerald-400/50 hover:shadow-xl hover:shadow-black/60"
              >
                <div>
                  <div
                    className="relative flex h-32 items-center justify-center overflow-hidden rounded-xl bg-black/40"
                    style={{
                      backgroundImage: `radial-gradient(circle at center, ${skin.rarityColor}20, transparent 75%)`,
                    }}
                  >
                    <img
                      src={skin.image}
                      alt={skin.fullName}
                      className="max-h-[85%] max-w-[90%] object-contain drop-shadow transition-transform group-hover:scale-110"
                      loading="lazy"
                    />
                    <span
                      className="absolute top-1.5 right-1.5 rounded px-1.5 py-0.5 text-[8px] font-black uppercase"
                      style={{ color: skin.rarityColor }}
                    >
                      {skin.rarityUk}
                    </span>
                  </div>

                  <div className="mt-3">
                    <p className="text-[10px] font-bold text-slate-500 uppercase truncate">
                      {skin.weapon}
                    </p>
                    <h3 className="text-xs font-bold text-white truncate">{skin.name}</h3>
                  </div>
                </div>

                <div className="mt-4 border-t border-white/[0.06] pt-3">
                  <div className="flex items-center justify-between mb-2">
                    <p className="font-mono text-sm font-black text-emerald-400">
                      {formatCoins(skin.price)} <span className="text-[10px]">GC</span>
                    </p>
                    <span className="text-[10px] text-slate-500">
                      ≈ {skin.price.toLocaleString("uk-UA")} грн
                    </span>
                  </div>

                  <div className="grid grid-cols-2 gap-1.5">
                    <button
                      onClick={() => handleBuySkin(skin)}
                      className="rounded-xl bg-emerald-500 hover:bg-emerald-400 py-1.5 text-center text-xs font-black text-[#05130d] transition"
                    >
                      Купити
                    </button>
                    <Link
                      href="/"
                      onClick={() => handleSelectForUpgrade(skin)}
                      className="rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 py-1.5 text-center text-xs font-bold text-slate-300 transition"
                    >
                      Ціль ⚡
                    </Link>
                  </div>
                </div>
              </article>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
EOF

# 9. Запуск білду, тестів та збереження в GitHub
echo "⚡ Запускаємо npm run build та vitest..."
npm run build
npm test

echo "⚡ Зберігаємо зміни у Git..."
git add .
git commit -m "feat: widescreen 16:9 layout, inventory skin selling, loss burning, sound cleanup" || true
git push origin main || true

echo "=========================================================="
echo "🎉 v11 УСПІШНО ЗАВЕРШЕНО ТА ЗБЕРЕЖЕНО В РЕПОЗИТОРІЙ!"
echo "=========================================================="
