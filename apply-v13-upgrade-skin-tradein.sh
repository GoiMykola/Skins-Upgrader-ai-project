#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "🔥 UPGRADER v13: Справжній CS2 Trade-In (Старий скін зникає при успішному апгрейді)"
echo "=========================================================="

# 1. Оновлення lib/inventory-storage.ts: додано функцію атомарної заміни replaceSkinInInventory
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

// Видалення скіна з інвентаря за instanceId
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

// СПРАВЖНІЙ ТРЕЙД-ІН: Атомарне вилучення старого скіна та зарахування нового виграного
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

# 2. Оновлення components/interactive-upgrader.tsx:
# При успішному виграші старий скін СПАЛЮЄТЬСЯ/ВИТРАЧАЄТЬСЯ в апгрейді, а новий займає його місце!
cat << 'EOF' > components/interactive-upgrader.tsx
"use client";

/* eslint-disable @next/next/no-img-element */
import { useState, useRef, useEffect, useMemo } from "react";
import Link from "next/link";
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
  replaceSkinInInventory,
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
  const [sourceSkin, setSourceSkin] = useState<InventoryItem | null>(null);
  const [targetSkin, setTargetSkin] = useState<Skin>(skins[1]);
  const [isSpinning, setIsSpinning] = useState(false);
  const [spinMode, setSpinMode] = useState<SpinMode>("normal");
  const [rotation, setRotation] = useState(0);
  const [spinTransition, setSpinTransition] = useState<string>("none");
  const [outcome, setOutcome] = useState<"win" | "loss" | null>(null);
  const [showResultModal, setShowResultModal] = useState(false);
  const [muted, setMuted] = useState(false);
  const [lostSkinBackup, setLostSkinBackup] = useState<InventoryItem | null>(null);
  const [usedSourceSkinBackup, setUsedSourceSkinBackup] = useState<InventoryItem | null>(null);

  // Модалка вибору зі СВОГО ІНВЕНТАРЯ
  const [isInventoryPickerOpen, setIsInventoryPickerOpen] = useState(false);
  const [invSearch, setInvSearch] = useState("");

  // Модалка вибору ЦІЛІ з ринку CS2 (2 246 скінів)
  const [marketSkins, setMarketSkins] = useState<MarketSkin[]>([]);
  const [isMarketPickerOpen, setIsMarketPickerOpen] = useState(false);
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

    let activeSkin: InventoryItem | null = inv.length > 0 ? inv[0] : null;

    try {
      const selectedSourceRaw = localStorage.getItem("goicoins_selected_source");
      if (selectedSourceRaw) {
        const parsed = JSON.parse(selectedSourceRaw);
        const match = inv.find(
          (i) => i.instanceId === parsed.instanceId || (i.finish === parsed.finish && i.name === parsed.name)
        );
        if (match) {
          activeSkin = match;
        }
        localStorage.removeItem("goicoins_selected_source");
      }
    } catch {}

    setSourceSkin(activeSkin);
    setMuted(isMuted());

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
      if (e.detail) {
        setUserInventory(e.detail);
        setSourceSkin((prev) => {
          if (!prev) return e.detail.length > 0 ? e.detail[0] : null;
          const stillThere = e.detail.find((i) => i.instanceId === prev.instanceId);
          return stillThere || (e.detail.length > 0 ? e.detail[0] : null);
        });
      }
    };
    window.addEventListener("goi-inventory-updated", handleInvUpdate as EventListener);

    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
      if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
      if (tickIntervalRef.current) clearInterval(tickIntervalRef.current);
      window.removeEventListener("goi-inventory-updated", handleInvUpdate as EventListener);
    };
  }, []);

  const currentSourcePrice = sourceSkin ? sourceSkin.price : 0;
  const isDowngrade = !sourceSkin || targetSkin.price <= currentSourcePrice;
  const multiplier = sourceSkin && sourceSkin.price > 0 ? Math.round((targetSkin.price / sourceSkin.price) * 100) / 100 : 0;
  
  const rawChance = isDowngrade || !sourceSkin ? 0 : (sourceSkin.price / targetSkin.price) * 100 * 0.95;
  const chance = isDowngrade || !sourceSkin ? 0 : Math.min(95, Math.max(0.5, Math.round(rawChance * 10) / 10));
  
  const winAngle = (chance / 100) * 360;
  const circleCircumference = 270.2;
  const winStrokeDash = (winAngle / 360) * circleCircumference;
  const currentConfig = SPIN_CONFIGS[spinMode];

  const handleSoundToggle = () => {
    const next = toggleMute();
    setMuted(next);
  };

  const handleMultiplierSelect = (mult: number) => {
    if (!sourceSkin) return;
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

  const handleSelectSourceFromInventory = (s: InventoryItem) => {
    playClickSound();
    setSourceSkin(s);
    setIsInventoryPickerOpen(false);

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

  const openMarketPickerForTarget = () => {
    playClickSound();
    setPickerSearch("");
    setPickerCategory("all");
    setPickerPriceRange("all");
    setOnlyValidUpgrades(true);
    setIsMarketPickerOpen(true);
  };

  const handleSelectTargetFromMarket = (item: MarketSkin) => {
    playClickSound();
    setTargetSkin(marketSkinToSkin(item));
    setIsMarketPickerOpen(false);
  };

  const filteredMarketTargets = useMemo(() => {
    let result = marketSkins.filter((s) => {
      if (onlyValidUpgrades && sourceSkin && s.price <= sourceSkin.price) {
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
  }, [marketSkins, pickerSearch, pickerCategory, pickerPriceRange, pickerSort, onlyValidUpgrades, sourceSkin]);

  const filteredUserInventory = useMemo(() => {
    if (!invSearch.trim()) return userInventory;
    const q = invSearch.toLowerCase().trim();
    return userInventory.filter(
      (s) => s.name.toLowerCase().includes(q) || s.weapon.toLowerCase().includes(q)
    );
  }, [userInventory, invSearch]);

  const handleUpgrade = () => {
    if (isSpinning || isDowngrade || !sourceSkin) return;
    playClickSound();
    setIsSpinning(true);
    setOutcome(null);
    setShowResultModal(false);

    setLostSkinBackup({ ...sourceSkin });
    setUsedSourceSkinBackup({ ...sourceSkin });

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

  // -------------------------------------------------------------
  // ЗАВЕРШЕННЯ АПГРЕЙДУ: СПРАВЖНІЙ TRADE-IN
  // 1. При ПЕРЕМОЗІ: старий скін ВИЛУЧАЄТЬСЯ (витрачено на апгрейд), а новий зараховується!
  // 2. При ПОРАЗЦІ: старий скін СПАЛЮЄТЬСЯ (видаляється з інвентаря).
  // -------------------------------------------------------------
  const finishSpin = (isWin: boolean) => {
    if (tickIntervalRef.current) clearInterval(tickIntervalRef.current);
    if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
    if (timerRef.current) clearTimeout(timerRef.current);

    setIsSpinning(false);
    setOutcome(isWin ? "win" : "loss");
    setShowResultModal(true);

    if (isWin) {
      playWinSound();
      
      // СПРАВЖНЯ МЕХАНІКА: старий скін забирається, новий скін додається замість нього
      let updatedInv: InventoryItem[] = [];
      if (sourceSkin && sourceSkin.instanceId) {
        updatedInv = replaceSkinInInventory(sourceSkin.instanceId, targetSkin);
      } else {
        updatedInv = addSkinToInventory(targetSkin);
      }
      setUserInventory(updatedInv);

      // Новий виграний скін стає активним у картці!
      const wonItem = updatedInv[0] || (updatedInv.length > 0 ? updatedInv[0] : null);
      setSourceSkin(wonItem);

      // Автоматично підбираємо нову ціль дорожчу за щойно виграний скін
      if (wonItem) {
        const pool = marketSkins.length > 0 ? marketSkins.map(marketSkinToSkin) : skins;
        const candidates = pool.filter((item) => item.price >= wonItem.price * 1.2);
        if (candidates.length > 0) {
          const idealPrice = wonItem.price * 1.5;
          const best = candidates.reduce((prev, curr) =>
            Math.abs(curr.price - idealPrice) < Math.abs(prev.price - idealPrice) ? curr : prev
          );
          setTargetSkin(best);
        }
      }

    } else {
      playLossSound();
      // Поразка: скін безповоротно спалюється з інвентаря
      if (sourceSkin && sourceSkin.instanceId) {
        const remaining = removeSkinFromInventory(sourceSkin.instanceId);
        setUserInventory(remaining);
        setSourceSkin(remaining.length > 0 ? remaining[0] : null);
      }
    }
  };

  return (
    <div className="relative overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0d1018]/95 p-5 sm:p-7 lg:p-9 shadow-2xl shadow-black/80 backdrop-blur-xl w-full">
      {/* Верхній статус бар: назва, типи прокрутки та звук */}
      <div className="flex flex-wrap items-center justify-between gap-4 border-b border-white/[0.06] pb-5">
        <div className="flex items-center gap-2.5">
          <span className="size-2.5 rounded-full bg-emerald-400 shadow-[0_0_12px_#10b981]" />
          <h2 className="text-sm font-black uppercase tracking-wider text-white">
            CS2 UPGRADER ARENA · КІБЕР-РУЛЕТКА
          </h2>
        </div>

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

      {/* 3-КОЛОНКОВА АРЕНА (ТВІЙ СКІН | КОЛЕСО РУЛЕТКИ | БАЖАНА ЦІЛЬ) */}
      <div className="mt-8 grid grid-cols-1 md:grid-cols-[1fr_auto_1fr] items-center justify-center gap-6 lg:gap-8">
        
        {/* ЛІВА КОЛОНКА (Твій скін строго зі свого інвентаря) */}
        <div className="min-w-0 w-full max-w-[380px] lg:max-w-[420px] justify-self-center md:justify-self-end flex flex-col justify-between rounded-2xl border border-white/[0.08] bg-black/50 p-5 sm:p-6 shadow-xl">
          <div>
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Твій скін (з інвентаря)
              </span>
              <span className="font-mono text-sm font-bold text-emerald-400">
                {sourceSkin ? `${formatCoins(sourceSkin.price)} GC` : "—"}
              </span>
            </div>

            {sourceSkin ? (
              <>
                <div
                  className="my-4 cursor-pointer"
                  onClick={() => setIsInventoryPickerOpen(true)}
                  title="Клікни, щоб обрати інший скін зі свого інвентаря"
                >
                  <SkinArt skin={sourceSkin} className="h-36 sm:h-40" />
                </div>
                <p className="font-bold text-white truncate text-base sm:text-lg">
                  {sourceSkin.weapon} | {sourceSkin.name}
                </p>
                <p className="text-xs text-slate-400 mt-0.5">{sourceSkin.wear}</p>
              </>
            ) : (
              <div className="my-6 flex flex-col items-center justify-center rounded-2xl border border-dashed border-rose-500/30 bg-rose-950/10 p-6 text-center">
                <span className="text-3xl">🎒</span>
                <p className="mt-2 text-sm font-bold text-white">Інвентар порожній</p>
                <p className="mt-1 text-xs text-slate-400 max-w-[220px]">
                  У тебе немає скінів для апгрейду. Купи свій перший скін на Ринку!
                </p>
                <Link
                  href="/market"
                  className="mt-4 rounded-xl bg-emerald-500 hover:bg-emerald-400 px-4 py-2 text-xs font-black text-[#05130d] transition shadow-md"
                >
                  Перейти на Ринок 🛒
                </Link>
              </div>
            )}
          </div>

          <div className="mt-5 border-t border-white/[0.06] pt-3.5">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Інвентар ({userInventory.length}):
              </span>
              {userInventory.length > 0 && (
                <button
                  onClick={() => setIsInventoryPickerOpen(true)}
                  className="text-xs font-bold text-emerald-400 hover:text-emerald-300 underline"
                >
                  Всі скіни 🎒
                </button>
              )}
            </div>

            {userInventory.length > 0 ? (
              <div className="flex gap-1.5 overflow-x-auto pb-1 no-scrollbar">
                {userInventory.map((s, idx) => (
                  <button
                    key={s.instanceId ? `inv-btn-${s.instanceId}` : `inv-fallback-${s.finish}-${idx}`}
                    onClick={() => handleSelectSourceFromInventory(s)}
                    className={`shrink-0 rounded-lg border px-2.5 py-1 text-xs font-semibold transition ${
                      sourceSkin && sourceSkin.instanceId === s.instanceId
                        ? "border-emerald-400 bg-emerald-400/20 text-emerald-200"
                        : "border-white/5 bg-white/5 text-slate-400 hover:bg-white/10"
                    }`}
                  >
                    {s.weapon}
                  </button>
                ))}
              </div>
            ) : (
              <p className="text-[11px] text-slate-500 italic">Скінів в інвентарі немає</p>
            )}
          </div>
        </div>

        {/* ЦЕНТРАЛЬНА КОЛОНКА: СМАРАГДОВЕ КОЛЕСО РУЛЕТКИ */}
        <div className="flex flex-col items-center justify-center justify-self-center px-2 shrink-0">
          <div className="relative flex size-72 items-center justify-center sm:size-84 lg:size-92">
            <svg className="size-full -rotate-90 transform" viewBox="0 0 100 100">
              <circle
                cx="50"
                cy="50"
                r="43"
                className="stroke-[#131826]"
                strokeWidth="6"
                fill="transparent"
              />
              {!isDowngrade && sourceSkin && (
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
            <div className="absolute flex flex-col items-center justify-center text-center max-w-[210px]">
              {!sourceSkin ? (
                <div className="flex flex-col items-center">
                  <span className="text-xs font-black uppercase tracking-wider text-amber-400">
                    🎒 НЕМАЄ СКІНА
                  </span>
                  <span className="mt-1 text-[11px] font-bold text-slate-300">
                    Купи скін на Ринку
                  </span>
                </div>
              ) : isDowngrade ? (
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
                disabled={isSpinning || !sourceSkin}
                className="rounded-lg px-2.5 sm:px-3 py-1 font-mono text-xs font-bold text-slate-400 transition hover:bg-emerald-500/10 hover:text-emerald-300 disabled:opacity-40"
              >
                {m}×
              </button>
            ))}
          </div>
        </div>

        {/* ПРАВА КОЛОНКА (Бажаний скін - ціль з Ринку CS2) */}
        <div className="min-w-0 w-full max-w-[380px] lg:max-w-[420px] justify-self-center md:justify-self-start flex flex-col justify-between rounded-2xl border border-white/[0.08] bg-black/50 p-5 sm:p-6 shadow-xl">
          <div>
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Бажаний скін (ціль)
              </span>
              <span className={`font-mono text-sm font-bold ${isDowngrade ? "text-rose-400" : "text-emerald-400"}`}>
                {formatCoins(targetSkin.price)} GC
              </span>
            </div>
            <div
              className="my-4 cursor-pointer"
              onClick={openMarketPickerForTarget}
              title="Клікни, щоб обрати іншу ціль з Ринку CS2"
            >
              <SkinArt skin={targetSkin} className="h-36 sm:h-40" />
            </div>
            <p className="font-bold text-white truncate text-base sm:text-lg">
              {targetSkin.weapon} | {targetSkin.name}
            </p>
            <p className="text-xs text-slate-400 mt-0.5">{targetSkin.wear}</p>
          </div>

          <div className="mt-5 border-t border-white/[0.06] pt-3.5">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Швидка ціль:
              </span>
              <button
                onClick={openMarketPickerForTarget}
                className="text-xs font-bold text-emerald-400 hover:text-emerald-300 underline"
              >
                Обрати з Ринку (2.2к) 🔍
              </button>
            </div>
            <div className="flex gap-1.5 overflow-x-auto pb-1 no-scrollbar">
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

      {/* Велика кнопка апгрейду */}
      <div className="mt-10 flex justify-center">
        <button
          onClick={handleUpgrade}
          disabled={isSpinning || isDowngrade || !sourceSkin}
          className={`w-full max-w-xl rounded-2xl py-4 text-base font-black uppercase tracking-wider transition shadow-2xl ${
            isSpinning
              ? "cursor-not-allowed bg-slate-800 text-slate-500 border border-white/5"
              : !sourceSkin
              ? "cursor-not-allowed bg-slate-800/90 text-amber-300 border border-amber-500/30"
              : isDowngrade
              ? "cursor-not-allowed bg-slate-800/90 text-rose-400 border border-rose-500/30 shadow-none"
              : "bg-emerald-500 hover:bg-emerald-400 text-[#05130d] shadow-emerald-500/25 border border-emerald-400/40 active:scale-[0.99]"
          }`}
        >
          {isSpinning
            ? "Крутимо рулетку..."
            : !sourceSkin
            ? "🎒 СПОЧАТКУ ОБЕРИ АБО КУПИ СКІН"
            : isDowngrade
            ? "⚠️ ДАУНГРЕЙД ЗАБОРОНЕНО (ОБЕРИ ДОРОЖЧУ ЦІЛЬ)"
            : "АПГРЕЙДИТИ СКІН ⚡"}
        </button>
      </div>

      {/* МОДАЛКА 1: ВИБІР СКІНА ЗІ СВОГО ІНВЕНТАРЯ */}
      {isInventoryPickerOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
          <div className="w-full max-w-3xl max-h-[85vh] flex flex-col rounded-3xl border border-white/10 bg-[#0e111a] p-6 shadow-2xl">
            <div className="flex items-center justify-between border-b border-white/[0.08] pb-4">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-emerald-400">
                  🎒 ТВІЙ ІНВЕНТАР ДЛЯ АПГРЕЙДУ
                </span>
                <h3 className="text-xl font-black text-white">Обери наявний скін ({userInventory.length} шт.)</h3>
              </div>
              <button
                onClick={() => setIsInventoryPickerOpen(false)}
                className="size-9 rounded-full border border-white/10 bg-white/5 text-base font-bold text-slate-400 hover:text-white"
              >
                ✕
              </button>
            </div>

            <div className="my-4">
              <input
                type="text"
                value={invSearch}
                onChange={(e) => setInvSearch(e.target.value)}
                placeholder="Швидкий пошук у своєму інвентарі..."
                className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-2.5 text-sm text-white placeholder-slate-500 outline-none focus:border-emerald-400"
              />
            </div>

            <div className="overflow-y-auto flex-1 pr-1 grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
              {filteredUserInventory.length === 0 ? (
                <div className="col-span-full py-12 text-center text-slate-400 text-sm">
                  Скінів не знайдено
                </div>
              ) : (
                filteredUserInventory.map((item) => (
                  <button
                    key={`inv-picker-${item.instanceId}`}
                    onClick={() => handleSelectSourceFromInventory(item)}
                    className="group relative flex flex-col justify-between rounded-xl border border-white/10 bg-[#080a10] p-3 text-left transition hover:border-emerald-400 hover:bg-emerald-400/5 hover:-translate-y-0.5"
                  >
                    <SkinArt skin={item} className="h-24" />
                    <div className="mt-2">
                      <p className="text-[10px] font-bold text-slate-500 uppercase truncate">{item.weapon}</p>
                      <p className="text-xs font-bold text-white truncate">{item.name}</p>
                      <p className="font-mono text-xs font-black text-emerald-400 mt-1">
                        {formatCoins(item.price)} GC
                      </p>
                    </div>
                  </button>
                ))
              )}
            </div>
          </div>
        </div>
      )}

      {/* МОДАЛКА 2: ВИБІР БАЖАНОЇ ЦІЛІ З РИНКУ CS2 */}
      {isMarketPickerOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
          <div className="w-full max-w-5xl max-h-[90vh] flex flex-col rounded-3xl border border-white/10 bg-[#0e111a] p-6 shadow-2xl">
            <div className="flex items-center justify-between border-b border-white/[0.08] pb-4">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-emerald-400">
                  🎯 ОБЕРИ БАЖАНУ ЦІЛЬ ДЛЯ АПГРЕЙДУ
                </span>
                <h3 className="text-2xl font-black text-white">Каталог скінів CS2 (2 246 скінів)</h3>
              </div>
              <button
                onClick={() => setIsMarketPickerOpen(false)}
                className="size-9 rounded-full border border-white/10 bg-white/5 text-base font-bold text-slate-400 hover:text-white"
              >
                ✕
              </button>
            </div>

            <div className="my-4 space-y-3">
              <div className="flex flex-col sm:flex-row gap-3 items-center">
                <input
                  type="text"
                  value={pickerSearch}
                  onChange={(e) => setPickerSearch(e.target.value)}
                  placeholder="Швидкий пошук: Dragon Lore, Doppler, Fade, AK-47, Printstream..."
                  className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-2.5 text-sm text-white placeholder-slate-500 outline-none focus:border-emerald-400"
                />
                
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

                {sourceSkin && (
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

            <div className="overflow-y-auto flex-1 pr-1 grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3">
              {filteredMarketTargets.map((item, idx) => (
                <button
                  key={`picker-target-${item.id}-${idx}`}
                  onClick={() => handleSelectTargetFromMarket(item)}
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

      {/* МОДАЛЬНЕ ВІКНО РЕЗУЛЬТАТУ: ВИГРАШ АБО ПОРАЗКА */}
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
                {usedSourceSkinBackup && (
                  <p className="mt-1 text-xs text-slate-400">
                    Старий скін ({usedSourceSkinBackup.weapon} | {usedSourceSkinBackup.name}) успішно обміняно!
                  </p>
                )}
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
                
                {lostSkinBackup && (
                  <div className="relative my-4 overflow-hidden rounded-2xl border border-rose-500/30 bg-rose-950/20 p-2">
                    <div className="transition-all duration-1000 scale-90 opacity-20 blur-[1px] grayscale contrast-150">
                      <SkinArt skin={lostSkinBackup} className="h-28" />
                    </div>
                    <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                      <span className="text-2xl animate-bounce">🔥</span>
                      <span className="mt-1 rounded-full bg-rose-500/40 px-2.5 py-0.5 font-mono text-[11px] font-black text-rose-200 border border-rose-500/50">
                        −{formatCoins(lostSkinBackup.price)} GC (СПАЛЕНО)
                      </span>
                    </div>
                  </div>
                )}
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
                <Link
                  href="/inventory"
                  className="w-full rounded-xl border border-white/10 bg-white/5 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/10 transition"
                >
                  Переглянути в інвентарі →
                </Link>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
EOF

# 3. Перевірка білду та тестів
echo "⚡ Запускаємо npm run build та vitest..."
npm run build
npm test

echo "⚡ Зберігаємо зміни у Git..."
git add .
git commit -m "feat(upgrader): consume source skin on successful upgrade (trade-in logic)" || true
git push origin main || true

echo "=========================================================="
echo "🎉 v13 УСПІШНО ЗАВЕРШЕНО! Трейд-ін налагоджено: старий скін зникає, новий додається!"
echo "=========================================================="
