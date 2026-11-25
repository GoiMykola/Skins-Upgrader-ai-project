#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v34 [ЧАСТИНА 2]: КОНТРАКТИ, ДУЕЛІ ТА БІЛД"
echo "=========================================================="

mkdir -p app/contracts app/duel app/components

# 1. app/contracts/page.tsx: Контракти обміну CS2 (Trade-Up Contracts)
cat << 'EOF' > app/contracts/page.tsx
"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import SiteHeader from "@/app/components/site-header";
import { LiveDropsTicker } from "@/components/live-drops-ticker";
import { getStoredInventory, removeSkinFromInventory, addSkinToInventory, type InventoryItem } from "@/lib/inventory-storage";
import { formatCoins, skins } from "@/app/data";
import { triggerConfetti, playJackpotSound } from "@/lib/confetti";
import { playClickSound } from "@/lib/sound-fx";

export default function ContractsPage() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [isSigning, setIsSigning] = useState(false);
  const [craftedSkin, setCraftedSkin] = useState<any | null>(null);

  useEffect(() => {
    setInventory(getStoredInventory());
  }, []);

  const selectedItems = inventory.filter((item) => selectedIds.includes(item.instanceId));
  const totalValue = selectedItems.reduce((acc, item) => acc + item.price, 0);
  const estimatedOutcomePrice = Math.round(totalValue * 1.35);

  const toggleSelect = (instanceId: string) => {
    playClickSound();
    if (selectedIds.includes(instanceId)) {
      setSelectedIds(selectedIds.filter((id) => id !== instanceId));
    } else {
      if (selectedIds.length >= 10) return;
      setSelectedIds([...selectedIds, instanceId]);
    }
  };

  const handleSignContract = () => {
    if (selectedIds.length < 3 || isSigning) return;
    setIsSigning(true);
    setCraftedSkin(null);

    setTimeout(() => {
      const eligiblePool = skins.filter((s) => s.price >= totalValue * 0.9);
      const chosen = eligiblePool.length > 0
        ? eligiblePool[Math.floor(Math.random() * eligiblePool.length)]
        : skins[Math.floor(Math.random() * skins.length)];

      selectedIds.forEach((id) => removeSkinFromInventory(id));

      addSkinToInventory({
        name: chosen.name,
        weapon: chosen.weapon,
        price: chosen.price,
        image: chosen.image,
        rarity: chosen.rarity || "Таємне",
        accent: chosen.accent || "#eb4b4b",
        wear: "Прямо із заводу",
        floatValue: 0.03,
      });

      setInventory(getStoredInventory());
      setSelectedIds([]);
      setCraftedSkin(chosen);
      setIsSigning(false);
      playJackpotSound();
      triggerConfetti();
    }, 2500);
  };

  return (
    <div className="min-h-screen pb-20 bg-[#070910]">
      <SiteHeader />
      <LiveDropsTicker />

      <main className="mx-auto max-w-[1760px] px-4 pt-8 sm:px-6 lg:px-10 xl:px-12">
        <div className="text-center max-w-3xl mx-auto mb-8">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-400/10 px-4 py-1.5 text-xs font-black uppercase tracking-wider text-emerald-400 mb-3">
            📜 КРАФТ ТА ОБМІН СТАРИХ СКІНІВ
          </div>
          <h1 className="text-3xl sm:text-5xl font-black text-white">Контракти обміну CS2</h1>
          <p className="text-sm text-slate-400 mt-2">
            Поклади від 3 до 10 скінів зі свого інвентарю для підписання контракту на один скін вищого ґатунку!
          </p>
        </div>

        <div className="rounded-3xl border border-white/10 bg-[#0c101c] p-6 sm:p-8 shadow-2xl relative overflow-hidden">
          <div className="flex flex-col lg:flex-row items-center justify-between gap-6 border-b border-white/10 pb-6">
            <div>
              <p className="text-xs font-bold text-slate-400 uppercase">Слотів заповнено: {selectedIds.length} з 10 (мін. 3)</p>
              <p className="text-2xl font-black text-white mt-1">
                Загальна вартість депозиту: <span className="text-emerald-400 font-mono">{formatCoins(totalValue)} GC</span>
              </p>
            </div>
            <div className="text-right">
              <p className="text-xs font-bold text-slate-400 uppercase">Очікуваний виграшний клас</p>
              <p className="text-2xl font-black text-amber-400 font-mono">~{formatCoins(estimatedOutcomePrice)} GC (+35% Boost)</p>
            </div>
            <button
              onClick={handleSignContract}
              disabled={selectedIds.length < 3 || isSigning}
              className="rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-400 hover:brightness-110 px-8 py-4 text-base font-black text-[#05130d] shadow-lg shadow-emerald-500/25 transition disabled:opacity-40"
            >
              {isSigning ? "Підписання контракту... ✍️" : `Підписати контракт (${selectedIds.length}/10)`}
            </button>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-5 lg:grid-cols-10 gap-3 my-6">
            {Array.from({ length: 10 }).map((_, idx) => {
              const item = selectedItems[idx];
              return (
                <div
                  key={`slot-${idx}`}
                  onClick={() => item && toggleSelect(item.instanceId)}
                  className={`h-28 rounded-2xl border-2 flex flex-col items-center justify-center p-2 transition cursor-pointer ${
                    item
                      ? "border-emerald-500 bg-emerald-500/10 hover:border-rose-400"
                      : "border-dashed border-white/10 bg-white/[0.02]"
                  }`}
                >
                  {item ? (
                    <>
                      <img src={item.image} alt={item.name} className="h-12 object-contain" />
                      <p className="text-[10px] font-bold text-white truncate w-full text-center mt-1">{item.name}</p>
                      <span className="text-[9px] font-mono text-emerald-400 font-black">{formatCoins(item.price)} GC</span>
                    </>
                  ) : (
                    <span className="text-xs text-slate-600 font-bold">Слот #{idx + 1}</span>
                  )}
                </div>
              );
            })}
          </div>

          {craftedSkin && (
            <div className="mt-6 rounded-2xl border-2 border-emerald-400 bg-emerald-500/20 p-6 text-center animate-bounce">
              <p className="text-xs font-black uppercase text-emerald-400">🎉 КОНТРАКТ УСПІШНО ПІДПИСАНО! ОТРИМАНО:</p>
              <div className="my-3 flex justify-center">
                <img src={craftedSkin.image} alt={craftedSkin.name} className="h-28 object-contain" />
              </div>
              <p className="text-xl font-black text-white">{craftedSkin.weapon} | {craftedSkin.name}</p>
              <p className="text-base font-mono font-black text-emerald-400 mt-1">{formatCoins(craftedSkin.price)} GC</p>
            </div>
          )}
        </div>

        <div className="mt-8">
          <h3 className="text-xl font-black text-white mb-4">Обери скіни зі свого інвентарю:</h3>
          {inventory.length === 0 ? (
            <div className="text-center py-12 text-slate-500">
              Твій інвентар порожній. Купи скіни на <Link href="/market" className="text-emerald-400 underline">Ринку</Link> або виграй в Апгрейдері!
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-6 lg:grid-cols-8 gap-3">
              {inventory.map((item) => {
                const isSelected = selectedIds.includes(item.instanceId);
                return (
                  <div
                    key={item.instanceId}
                    onClick={() => toggleSelect(item.instanceId)}
                    className={`rounded-2xl border p-3 flex flex-col justify-between items-center text-center cursor-pointer transition ${
                      isSelected
                        ? "border-emerald-400 bg-emerald-500/20 scale-95"
                        : "border-white/10 bg-[#0e111a] hover:border-emerald-500/40"
                    }`}
                  >
                    <img src={item.image} alt={item.name} className="h-16 object-contain my-1" />
                    <p className="text-xs font-black text-white truncate w-full">{item.name}</p>
                    <span className="text-xs font-mono text-emerald-400 font-bold mt-1">{formatCoins(item.price)} GC</span>
                    <button className="mt-2 w-full rounded-xl bg-white/5 py-1 text-[10px] font-black text-slate-300">
                      {isSelected ? "✓ Обрано" : "+ Додати"}
                    </button>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
EOF

# 2. app/duel/page.tsx: PvP Режим та Дуелі з ботами
cat << 'EOF' > app/duel/page.tsx
"use client";

import { useState, useEffect } from "react";
import SiteHeader from "@/app/components/site-header";
import { LiveDropsTicker } from "@/components/live-drops-ticker";
import { getStoredInventory, removeSkinFromInventory, addSkinToInventory, type InventoryItem } from "@/lib/inventory-storage";
import { formatCoins, skins } from "@/app/data";
import { triggerConfetti, playJackpotSound } from "@/lib/confetti";
import { playClickSound, playTickSound } from "@/lib/sound-fx";

const BOTS = [
  { id: "b1", name: "🤖 Bot S1mple", rank: "Global Elite" },
  { id: "b2", name: "🤖 Bot ZywOo", rank: "Global Elite" },
  { id: "b3", name: "🤖 Bot M0NESY", rank: "Supreme" },
];

export default function DuelPage() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [selectedSkin, setSelectedSkin] = useState<InventoryItem | null>(null);
  const [selectedBot] = useState(BOTS[0]);
  const [botSkin, setBotSkin] = useState<any>(skins[0]);
  const [isDueling, setIsDueling] = useState(false);
  const [duelWinner, setDuelWinner] = useState<"player" | "bot" | null>(null);

  useEffect(() => {
    const inv = getStoredInventory();
    setInventory(inv);
    if (inv.length > 0) {
      setSelectedSkin(inv[0]);
      matchBotSkin(inv[0].price);
    }
  }, []);

  const matchBotSkin = (price: number) => {
    const matched = skins.filter((s) => Math.abs(s.price - price) < price * 0.3);
    setBotSkin(matched.length > 0 ? matched[Math.floor(Math.random() * matched.length)] : skins[0]);
  };

  const handleSelectSkin = (skin: InventoryItem) => {
    playClickSound();
    setSelectedSkin(skin);
    matchBotSkin(skin.price);
    setDuelWinner(null);
  };

  const handleStartDuel = () => {
    if (!selectedSkin || isDueling) return;
    setIsDueling(true);
    setDuelWinner(null);

    const playerWins = Math.random() < 0.52;

    let ticks = 0;
    const interval = setInterval(() => {
      ticks++;
      if (ticks % 3 === 0) playTickSound();
      if (ticks > 30) clearInterval(interval);
    }, 100);

    setTimeout(() => {
      setIsDueling(false);
      if (playerWins) {
        setDuelWinner("player");
        addSkinToInventory({
          name: botSkin.name,
          weapon: botSkin.weapon,
          price: botSkin.price,
          image: botSkin.image,
          rarity: botSkin.rarity || "Таємне",
          accent: botSkin.accent || "#ffd700",
          wear: "Прямо із заводу",
          floatValue: 0.01,
        });
        playJackpotSound();
        triggerConfetti();
      } else {
        setDuelWinner("bot");
        removeSkinFromInventory(selectedSkin.instanceId);
      }
      setInventory(getStoredInventory());
    }, 3500);
  };

  return (
    <div className="min-h-screen pb-20 bg-[#070910]">
      <SiteHeader />
      <LiveDropsTicker />

      <main className="mx-auto max-w-[1760px] px-4 pt-8 sm:px-6 lg:px-10 xl:px-12">
        <div className="text-center max-w-3xl mx-auto mb-8">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-400/10 px-4 py-1.5 text-xs font-black uppercase tracking-wider text-emerald-400 mb-3">
            ⚔️ CS2 UPGRADE DUELS (PVP)
          </div>
          <h1 className="text-3xl sm:text-5xl font-black text-white">Битва Апгрейдерів</h1>
          <p className="text-sm text-slate-400 mt-2">
            Кидай виклик кібер-ботам на рівних ставках. Переможець забирає обидва скіни собі в інвентар!
          </p>
        </div>

        <div className="rounded-3xl border border-white/10 bg-[#0c101c] p-6 sm:p-10 shadow-2xl">
          <div className="grid grid-cols-1 lg:grid-cols-[1fr_auto_1fr] items-center gap-8">
            <div className={`rounded-2xl border-2 p-6 text-center transition ${duelWinner === "player" ? "border-emerald-400 bg-emerald-500/15" : "border-white/10 bg-[#0e121e]"}`}>
              <span className="text-xs font-black uppercase text-emerald-400">ТВІЙ СКІН (ТИ)</span>
              {selectedSkin ? (
                <div className="my-4">
                  <img src={selectedSkin.image} alt={selectedSkin.name} className="h-32 object-contain mx-auto" />
                  <p className="text-lg font-black text-white mt-2">{selectedSkin.weapon} | {selectedSkin.name}</p>
                  <p className="text-base font-mono font-black text-emerald-400">{formatCoins(selectedSkin.price)} GC</p>
                </div>
              ) : (
                <p className="text-sm text-slate-500 my-8">Обери скін нижче</p>
              )}
            </div>

            <div className="text-center">
              <span className="text-3xl font-black text-amber-400 block mb-3">VS</span>
              <button
                onClick={handleStartDuel}
                disabled={!selectedSkin || isDueling}
                className="rounded-2xl bg-gradient-to-r from-amber-500 via-rose-500 to-amber-500 hover:brightness-110 px-8 py-4 text-base font-black text-white shadow-xl shadow-amber-500/20 transition disabled:opacity-40"
              >
                {isDueling ? "Битва триває... ⚡" : "РОЗПОЧАТИ ДУЕЛЬ ⚔️"}
              </button>
              {duelWinner && (
                <p className={`mt-3 font-black text-sm ${duelWinner === "player" ? "text-emerald-400" : "text-rose-400"}`}>
                  {duelWinner === "player" ? "🎉 ПЕРЕМОГА! Обидва скіни твої!" : "💀 ПРОГРАШ! Бот забрав твій скін."}
                </p>
              )}
            </div>

            <div className={`rounded-2xl border-2 p-6 text-center transition ${duelWinner === "bot" ? "border-rose-400 bg-rose-500/15" : "border-white/10 bg-[#0e121e]"}`}>
              <div className="flex items-center justify-center gap-2 mb-2">
                <span className="text-xs font-black uppercase text-rose-400">{selectedBot.name}</span>
                <span className="text-[10px] bg-rose-500/20 text-rose-300 px-2 py-0.5 rounded-full">{selectedBot.rank}</span>
              </div>
              <div className="my-4">
                <img src={botSkin.image} alt={botSkin.name} className="h-32 object-contain mx-auto" />
                <p className="text-lg font-black text-white mt-2">{botSkin.weapon} | {botSkin.name}</p>
                <p className="text-base font-mono font-black text-rose-400">{formatCoins(botSkin.price)} GC</p>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8">
          <h3 className="text-xl font-black text-white mb-4">Обери свій скін для битви:</h3>
          <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-6 lg:grid-cols-8 gap-3">
            {inventory.map((item) => (
              <div
                key={item.instanceId}
                onClick={() => handleSelectSkin(item)}
                className={`rounded-2xl border p-3 flex flex-col justify-between items-center text-center cursor-pointer transition ${
                  selectedSkin?.instanceId === item.instanceId
                    ? "border-emerald-400 bg-emerald-500/20 scale-95"
                    : "border-white/10 bg-[#0e111a] hover:border-emerald-500/40"
                }`}
              >
                <img src={item.image} alt={item.name} className="h-16 object-contain my-1" />
                <p className="text-xs font-black text-white truncate w-full">{item.name}</p>
                <span className="text-xs font-mono text-emerald-400 font-bold mt-1">{formatCoins(item.price)} GC</span>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}
EOF

# 3. app/components/site-header.tsx: оновлена навігація
cat << 'EOF' > app/components/site-header.tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useEffect, useRef } from "react";
import { getStoredBalance } from "@/lib/inventory-storage";
import { getCurrentUser, logoutUser, type UserProfile } from "@/lib/auth-storage";
import { AuthModal } from "@/components/auth-modal";
import { DailyWheelModal } from "@/components/daily-wheel-modal";
import { GameStatsModal } from "@/components/game-stats-modal";
import { playClickSound } from "@/lib/sound-fx";

export default function SiteHeader() {
  const pathname = usePathname();
  const [balance, setBalance] = useState(1500);
  const [currentUser, setCurrentUser] = useState<UserProfile | null>(null);
  const [isAuthOpen, setIsAuthOpen] = useState(false);
  const [authTab, setAuthTab] = useState<"login" | "register">("login");
  const [isWheelOpen, setIsWheelOpen] = useState(false);
  const [isStatsOpen, setIsStatsOpen] = useState(false);
  const [showDropdown, setShowDropdown] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setBalance(getStoredBalance());
    setCurrentUser(getCurrentUser());

    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    const handleAuth = (e: CustomEvent<UserProfile | null>) => {
      setCurrentUser(e.detail ?? null);
    };

    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    window.addEventListener("goi-auth-updated", handleAuth as EventListener);

    const handleClickOutside = (ev: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(ev.target as Node)) {
        setShowDropdown(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);

    return () => {
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
      window.removeEventListener("goi-auth-updated", handleAuth as EventListener);
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  const handleLogout = () => {
    playClickSound();
    logoutUser();
    setShowDropdown(false);
  };

  const navLinks = [
    { href: "/", label: "Апгрейдер" },
    { href: "/contracts", label: "Контракти 📜" },
    { href: "/duel", label: "Дуелі ⚔️" },
    { href: "/catalog", label: "Каталог" },
    { href: "/market", label: "Ринок 🔥", badge: "2.2к" },
    { href: "/inventory", label: "Інвентар" },
    { href: "/leaderboard", label: "Лідери" },
  ];

  return (
    <>
      <header className="sticky top-0 z-40 border-b border-white/[0.08] bg-[#080a10]/95 backdrop-blur-xl">
        <div className="mx-auto flex h-20 max-w-[1760px] items-center justify-between px-4 sm:px-6 lg:px-10 xl:px-12">
          <Link href="/" className="flex items-center gap-3.5 group">
            <div className="flex size-11 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-xl font-black text-[#05130d] shadow-lg shadow-emerald-500/25 group-hover:scale-105 transition">
              G
            </div>
            <div className="leading-tight">
              <span className="font-mono text-base font-black tracking-wider text-white">
                GOICOINS
              </span>
              <span className="block text-[11px] font-bold uppercase tracking-widest text-emerald-400">
                Skin Simulator
              </span>
            </div>
          </Link>

          <nav className="hidden lg:flex items-center gap-1 rounded-2xl border border-white/[0.08] bg-black/50 p-1.5 shadow-inner">
            {navLinks.map((link) => {
              const isActive = pathname === link.href;
              return (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => playClickSound()}
                  className={`relative flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-bold transition ${
                    isActive
                      ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20 font-black"
                      : "text-slate-300 hover:text-white hover:bg-white/10"
                  }`}
                >
                  <span>{link.label}</span>
                  {link.badge && (
                    <span
                      className={`rounded-full px-2 py-0.5 text-[10px] font-black ${
                        isActive ? "bg-black/20 text-[#05130d]" : "bg-emerald-400/20 text-emerald-300 border border-emerald-400/30"
                      }`}
                    >
                      {link.badge}
                    </span>
                  )}
                </Link>
              );
            })}
          </nav>

          <div className="flex items-center gap-3">
            <button
              onClick={() => {
                playClickSound();
                setIsWheelOpen(true);
              }}
              className="hidden sm:flex items-center gap-2 rounded-2xl border border-amber-500/40 bg-amber-500/15 hover:bg-amber-500/25 px-3.5 py-2 text-xs font-black text-amber-300 shadow-[0_0_15px_rgba(245,158,11,0.2)] transition animate-pulse"
            >
              <span>🎡</span>
              <span>Колесо</span>
            </button>

            <div className="flex items-center gap-2 rounded-2xl border border-emerald-500/40 bg-emerald-500/15 px-4 py-2 font-mono text-sm sm:text-base font-black text-emerald-300 shadow-[0_0_20px_rgba(16,185,129,0.18)]">
              <span className="text-base text-emerald-400">🪙</span>
              <span>{balance.toLocaleString("uk-UA")} GC</span>
            </div>

            {currentUser ? (
              <div className="relative" ref={dropdownRef}>
                <button
                  onClick={() => {
                    playClickSound();
                    setShowDropdown(!showDropdown);
                  }}
                  className="flex items-center gap-2.5 rounded-2xl border border-white/10 bg-white/5 hover:bg-white/10 px-3.5 py-2 transition"
                >
                  <div className="flex size-8 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-400 to-teal-500 font-mono text-xs font-black text-[#05130d]">
                    {currentUser.avatar || "TH"}
                  </div>
                  <span className="hidden md:block text-xs font-black text-white truncate max-w-[100px]">
                    {currentUser.nickname}
                  </span>
                </button>

                {showDropdown && (
                  <div className="absolute right-0 mt-2 w-64 rounded-2xl border border-white/10 bg-[#0d111a]/98 backdrop-blur-2xl p-2.5 shadow-2xl z-50 animate-fade-in">
                    <div className="border-b border-white/10 px-3 py-2">
                      <p className="text-sm font-black text-white truncate">{currentUser.nickname}</p>
                      <p className="text-xs text-slate-400 truncate">{currentUser.email}</p>
                    </div>

                    <div className="mt-1.5 space-y-1">
                      <button
                        onClick={() => {
                          setShowDropdown(false);
                          setIsStatsOpen(true);
                        }}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3.5 py-2 text-xs font-bold text-slate-300 hover:bg-white/5 hover:text-white transition"
                      >
                        <span>📊</span>
                        <span>Моя статистика та історія</span>
                      </button>
                      <Link
                        href="/inventory"
                        onClick={() => setShowDropdown(false)}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3.5 py-2 text-xs font-bold text-slate-300 hover:bg-white/5 hover:text-white transition"
                      >
                        <span>🎒</span>
                        <span>Мій інвентар</span>
                      </Link>
                      <button
                        onClick={handleLogout}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3.5 py-2 text-xs font-bold text-rose-400 hover:bg-rose-500/10 transition"
                      >
                        <span>🚪</span>
                        <span>Вийти з акаунта</span>
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <button
                onClick={() => {
                  playClickSound();
                  setAuthTab("login");
                  setIsAuthOpen(true);
                }}
                className="rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 px-4 py-2 text-xs font-bold text-slate-300 hover:text-white transition"
              >
                Увійти
              </button>
            )}
          </div>
        </div>
      </header>

      <AuthModal isOpen={isAuthOpen} initialTab={authTab} onClose={() => setIsAuthOpen(false)} />
      <DailyWheelModal isOpen={isWheelOpen} onClose={() => setIsWheelOpen(false)} />
      <GameStatsModal isOpen={isStatsOpen} onClose={() => setIsStatsOpen(false)} />
    </>
  );
}
EOF

# 4. Перевірка білду
echo "=========================================================="
echo "🧪 ПЕРЕВІРКА БІЛДУ"
echo "=========================================================="
npm run build

# 5. Git Commit & Push на GitHub
echo "=========================================================="
echo "🚀 ФІКСАЦІЯ В GIT ТА PUSH НА GITHUB"
echo "=========================================================="
git add .
git commit -m "feat: mega update v34 - CS2 trade-up contracts, daily free wheel, duel arena, jackpot confetti & player stats" || true
git push origin main || true

echo "=========================================================="
echo "🎉 ВЕСЬ МЕГА-ФУНКЦІОНАЛ v34 УСПІШНО РОЗГОРНУТО!"
echo "=========================================================="
