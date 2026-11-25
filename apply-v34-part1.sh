#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v34 [ЧАСТИНА 1]: БОНУСИ, СТАТИСТИКА, КОНФЕТІ"
echo "=========================================================="

mkdir -p lib components

# 1. lib/confetti.ts: святкове конфеті без сторонніх npm бібліотек
cat << 'EOF' > lib/confetti.ts
"use client";

export function triggerConfetti() {
  if (typeof window === "undefined") return;

  const canvas = document.createElement("canvas");
  canvas.style.position = "fixed";
  canvas.style.top = "0";
  canvas.style.left = "0";
  canvas.style.width = "100vw";
  canvas.style.height = "100vh";
  canvas.style.pointerEvents = "none";
  canvas.style.zIndex = "99999";
  document.body.appendChild(canvas);

  const ctx = canvas.getContext("2d");
  if (!ctx) return;

  const width = (canvas.width = window.innerWidth);
  const height = (canvas.height = window.innerHeight);

  const colors = [
    "#10b981", "#34d399", "#fbbf24", "#f59e0b",
    "#ec4899", "#8b5cf6", "#3b82f6", "#06b6d4", "#ffffff"
  ];

  const particles: Array<{
    x: number;
    y: number;
    size: number;
    color: string;
    vx: number;
    vy: number;
    rotation: number;
    vRot: number;
    life: number;
  }> = [];

  for (let i = 0; i < 120; i++) {
    particles.push({
      x: width / 2 + (Math.random() - 0.5) * 200,
      y: height / 3 + (Math.random() - 0.5) * 100,
      size: Math.random() * 8 + 4,
      color: colors[Math.floor(Math.random() * colors.length)],
      vx: (Math.random() - 0.5) * 18,
      vy: Math.random() * -14 - 4,
      rotation: Math.random() * 360,
      vRot: (Math.random() - 0.5) * 12,
      life: 1,
    });
  }

  let animationFrame: number;
  const start = performance.now();

  function animate(now: number) {
    if (!ctx) return;
    const elapsed = now - start;
    ctx.clearRect(0, 0, width, height);

    let active = false;
    for (const p of particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.35;
      p.vx *= 0.98;
      p.rotation += p.vRot;
      p.life -= 0.007;

      if (p.life > 0 && p.y < height + 50) {
        active = true;
        ctx.save();
        ctx.translate(p.x, p.y);
        ctx.rotate((p.rotation * Math.PI) / 180);
        ctx.fillStyle = p.color;
        ctx.globalAlpha = Math.max(0, p.life);
        ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size * 0.7);
        ctx.restore();
      }
    }

    if (active && elapsed < 4000) {
      animationFrame = requestAnimationFrame(animate);
    } else {
      cancelAnimationFrame(animationFrame);
      if (canvas.parentNode) canvas.parentNode.removeChild(canvas);
    }
  }

  animationFrame = requestAnimationFrame(animate);
}

export function playJackpotSound() {
  if (typeof window === "undefined") return;
  try {
    const AudioContextClass = window.AudioContext || (window as any).webkitAudioContext;
    if (!AudioContextClass) return;
    const ctx = new AudioContextClass();
    const now = ctx.currentTime;
    [523.25, 659.25, 783.99, 1046.5, 1318.5].forEach((freq, idx) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = "triangle";
      osc.frequency.setValueAtTime(freq, now + idx * 0.1);
      gain.gain.setValueAtTime(0.15, now + idx * 0.1);
      gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.1 + 0.4);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now + idx * 0.1);
      osc.stop(now + idx * 0.1 + 0.45);
    });
  } catch {}
}
EOF

# 2. lib/daily-wheel-storage.ts: сховище та логіка Колеса Фортуни
cat << 'EOF' > lib/daily-wheel-storage.ts
"use client";

import { updateStoredBalance, getStoredBalance, addSkinToInventory } from "./inventory-storage";

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
    const current = getStoredBalance();
    updateStoredBalance(current + prize.value);
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
EOF

# 3. components/daily-wheel-modal.tsx: інтерактивне колесо фортуни
cat << 'EOF' > components/daily-wheel-modal.tsx
"use client";

import { useState, useEffect } from "react";
import { WHEEL_PRIZES, canSpinWheel, claimWheelReward, resetWheelCooldownForTest, type WheelPrize } from "@/lib/daily-wheel-storage";
import { triggerConfetti, playJackpotSound } from "@/lib/confetti";
import { playClickSound, playTickSound } from "@/lib/sound-fx";

interface DailyWheelModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function DailyWheelModal({ isOpen, onClose }: DailyWheelModalProps) {
  const [canSpin, setCanSpin] = useState(true);
  const [timeLeft, setTimeLeft] = useState(0);
  const [isSpinning, setIsSpinning] = useState(false);
  const [rotation, setRotation] = useState(0);
  const [wonPrize, setWonPrize] = useState<WheelPrize | null>(null);

  useEffect(() => {
    if (isOpen) {
      const status = canSpinWheel();
      setCanSpin(status.allowed);
      setTimeLeft(status.remainingSec);
      setWonPrize(null);
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleSpin = () => {
    if (isSpinning || !canSpin) return;
    playClickSound();
    setIsSpinning(true);
    setWonPrize(null);

    const prizeIndex = Math.floor(Math.random() * WHEEL_PRIZES.length);
    const selectedPrize = WHEEL_PRIZES[prizeIndex];

    const sliceAngle = 360 / WHEEL_PRIZES.length;
    const extraSpins = 5 * 360;
    const targetAngle = extraSpins + (360 - (prizeIndex * sliceAngle + sliceAngle / 2));

    setRotation(targetAngle);

    let tickCount = 0;
    const interval = setInterval(() => {
      tickCount++;
      if (tickCount % 4 === 0) playTickSound();
      if (tickCount > 35) clearInterval(interval);
    }, 100);

    setTimeout(() => {
      setIsSpinning(false);
      setWonPrize(selectedPrize);
      claimWheelReward(selectedPrize);
      setCanSpin(false);
      setTimeLeft(24 * 3600);
      playJackpotSound();
      triggerConfetti();
    }, 4000);
  };

  const handleTestReset = () => {
    playClickSound();
    resetWheelCooldownForTest();
    setCanSpin(true);
    setTimeLeft(0);
    setWonPrize(null);
  };

  const formatCooldown = (seconds: number) => {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    return `${h}год ${m}хв ${s}с`;
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fade-in">
      <div className="relative w-full max-w-lg overflow-hidden rounded-3xl border border-emerald-500/30 bg-[#0a0d16] p-6 sm:p-8 shadow-[0_0_80px_rgba(16,185,129,0.25)] text-center">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          disabled={isSpinning}
          className="absolute right-4 top-4 flex size-9 items-center justify-center rounded-xl bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white transition"
        >
          ✕
        </button>

        <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-400/10 px-4 py-1.5 text-xs font-black uppercase tracking-wider text-emerald-400 mb-3">
          🎡 ЩОДЕННИЙ БОНУС
        </div>
        <h2 className="text-2xl sm:text-3xl font-black text-white">Колесо Фортуни CS2</h2>
        <p className="text-xs text-slate-400 mt-1 max-w-sm mx-auto">
          Крути щодня та забирай гарантовані GoiCoins або секретний скін!
        </p>

        <div className="relative mx-auto my-6 flex size-64 sm:size-72 items-center justify-center">
          <div className="absolute -top-3 z-20 flex flex-col items-center">
            <div className="size-0 border-x-8 border-x-transparent border-t-[18px] border-t-emerald-400 filter drop-shadow-[0_0_10px_#10b981]" />
          </div>

          <div
            className="size-full rounded-full border-4 border-emerald-500/50 shadow-2xl relative overflow-hidden transition-transform duration-[4000ms] ease-[cubic-bezier(0.15,0.9,0.2,1)]"
            style={{ transform: `rotate(${rotation}deg)` }}
          >
            <svg viewBox="0 0 100 100" className="size-full -rotate-90">
              {WHEEL_PRIZES.map((prize, idx) => {
                const angle = 360 / WHEEL_PRIZES.length;
                const startAngle = idx * angle;
                const endAngle = startAngle + angle;
                const x1 = 50 + 50 * Math.cos((Math.PI * startAngle) / 180);
                const y1 = 50 + 50 * Math.sin((Math.PI * startAngle) / 180);
                const x2 = 50 + 50 * Math.cos((Math.PI * endAngle) / 180);
                const y2 = 50 + 50 * Math.sin((Math.PI * endAngle) / 180);
                return (
                  <path
                    key={prize.id}
                    d={`M50,50 L${x1},${y1} A50,50 0 0,1 ${x2},${y2} Z`}
                    fill={prize.color}
                    opacity={idx % 2 === 0 ? 0.9 : 0.75}
                    stroke="#0a0d16"
                    strokeWidth="0.8"
                  />
                );
              })}
            </svg>

            {WHEEL_PRIZES.map((prize, idx) => {
              const angle = 360 / WHEEL_PRIZES.length;
              const rot = idx * angle + angle / 2;
              return (
                <div
                  key={`label-${prize.id}`}
                  className="absolute inset-0 flex items-start justify-center pt-3 text-[9px] sm:text-[10px] font-black text-[#05130d] pointer-events-none"
                  style={{
                    transform: `rotate(${rot}deg)`,
                    transformOrigin: "center center",
                  }}
                >
                  <span className="bg-black/20 px-1 rounded backdrop-blur-[1px]">{prize.label}</span>
                </div>
              );
            })}
          </div>

          <div className="absolute z-10 flex size-14 items-center justify-center rounded-full border-2 border-emerald-400 bg-[#080a10] shadow-[0_0_20px_#10b981]">
            <span className="text-xl">🎁</span>
          </div>
        </div>

        {wonPrize && (
          <div className="mb-4 rounded-2xl border border-emerald-400 bg-emerald-500/20 p-3 animate-bounce">
            <p className="text-xs font-bold text-emerald-300">🎉 Твій виграш:</p>
            <p className="text-lg font-black text-white">{wonPrize.label}</p>
            <p className="text-[11px] text-slate-300">
              {wonPrize.type === "coins" ? "Нараховано на твій баланс!" : "Додано у твій інвентар!"}
            </p>
          </div>
        )}

        <button
          onClick={handleSpin}
          disabled={isSpinning || !canSpin}
          className="w-full rounded-2xl bg-gradient-to-r from-emerald-500 via-teal-400 to-emerald-500 hover:brightness-110 py-4 text-base font-black text-[#05130d] shadow-lg shadow-emerald-500/30 transition disabled:opacity-40 disabled:hover:brightness-100"
        >
          {isSpinning ? "Колесо обертається... ⚡" : canSpin ? "Крутити колесо безкоштовно 🎁" : `Доступно через: ${formatCooldown(timeLeft)}`}
        </button>

        {!canSpin && !isSpinning && (
          <div className="mt-3">
            <button
              onClick={handleTestReset}
              className="text-xs text-emerald-400 hover:text-emerald-300 underline font-semibold transition"
            >
              ⚡ Скинути таймер (тестовий режим для розробки)
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
EOF

# 4. lib/game-history-storage.ts: історія ігор та статистика
cat << 'EOF' > lib/game-history-storage.ts
"use client";

export interface GameHistoryEntry {
  id: string;
  timestamp: number;
  sourceSkinName: string;
  sourceSkinPrice: number;
  targetSkinName: string;
  targetSkinPrice: number;
  targetSkinImage: string;
  chance: number;
  multiplier: number;
  outcome: "win" | "loss";
  profit: number;
}

const HISTORY_KEY = "goicoins_game_history";

export function getGameHistory(): GameHistoryEntry[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem(HISTORY_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

export function logGameRound(entry: Omit<GameHistoryEntry, "id" | "timestamp">) {
  if (typeof window === "undefined") return;
  try {
    const current = getGameHistory();
    const newEntry: GameHistoryEntry = {
      ...entry,
      id: `game_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`,
      timestamp: Date.now(),
    };
    const updated = [newEntry, ...current].slice(0, 50);
    localStorage.setItem(HISTORY_KEY, JSON.stringify(updated));
    window.dispatchEvent(new CustomEvent("goi-history-updated"));
  } catch {}
}

export function getGameStats() {
  const history = getGameHistory();
  const totalSpins = history.length;
  const wins = history.filter((h) => h.outcome === "win");
  const winrate = totalSpins > 0 ? Math.round((wins.length / totalSpins) * 100) : 0;
  const totalProfit = history.reduce((acc, h) => acc + h.profit, 0);
  const bestMultiplier = wins.length > 0 ? Math.max(...wins.map((w) => w.multiplier)) : 0;
  const hasSniper = wins.some((w) => w.chance <= 10);
  const hasHighroller = history.some((h) => h.targetSkinPrice >= 50000);

  return {
    totalSpins,
    totalWins: wins.length,
    totalLosses: totalSpins - wins.length,
    winrate,
    totalProfit,
    bestMultiplier,
    hasSniper,
    hasHighroller,
  };
}
EOF

# 5. components/game-stats-modal.tsx: статистика та ачівки
cat << 'EOF' > components/game-stats-modal.tsx
"use client";

import { useState, useEffect } from "react";
import { getGameHistory, getGameStats, type GameHistoryEntry } from "@/lib/game-history-storage";
import { formatCoins } from "@/app/data";
import { playClickSound } from "@/lib/sound-fx";

interface GameStatsModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function GameStatsModal({ isOpen, onClose }: GameStatsModalProps) {
  const [history, setHistory] = useState<GameHistoryEntry[]>([]);
  const [stats, setStats] = useState(getGameStats());

  useEffect(() => {
    if (isOpen) {
      setHistory(getGameHistory());
      setStats(getGameStats());
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fade-in">
      <div className="relative w-full max-w-3xl max-h-[90vh] overflow-y-auto rounded-3xl border border-white/10 bg-[#0a0d16] p-6 sm:p-8 shadow-2xl">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-4 top-4 flex size-9 items-center justify-center rounded-xl bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white transition"
        >
          ✕
        </button>

        <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-400/10 px-4 py-1.5 text-xs font-black uppercase tracking-wider text-emerald-400 mb-2">
          📊 ОСОБИСТА СТАТИСТИКА
        </div>
        <h2 className="text-2xl sm:text-3xl font-black text-white">Історія ігор та досягнення</h2>

        <div className="mt-6 grid grid-cols-2 sm:grid-cols-4 gap-3">
          <div className="rounded-2xl border border-white/5 bg-white/[0.03] p-4 text-center">
            <p className="text-xs text-slate-400 font-bold">Усього ігор</p>
            <p className="text-2xl font-black text-white mt-1">{stats.totalSpins}</p>
          </div>
          <div className="rounded-2xl border border-white/5 bg-white/[0.03] p-4 text-center">
            <p className="text-xs text-slate-400 font-bold">Вінрейт</p>
            <p className="text-2xl font-black text-emerald-400 mt-1">{stats.winrate}%</p>
          </div>
          <div className="rounded-2xl border border-white/5 bg-white/[0.03] p-4 text-center">
            <p className="text-xs text-slate-400 font-bold">Найкращий множник</p>
            <p className="text-2xl font-black text-amber-400 mt-1">×{stats.bestMultiplier || 0}</p>
          </div>
          <div className="rounded-2xl border border-white/5 bg-white/[0.03] p-4 text-center">
            <p className="text-xs text-slate-400 font-bold">Чистий баланс</p>
            <p className={`text-2xl font-black mt-1 ${stats.totalProfit >= 0 ? "text-emerald-400" : "text-rose-400"}`}>
              {stats.totalProfit >= 0 ? `+${formatCoins(stats.totalProfit)}` : formatCoins(stats.totalProfit)} GC
            </p>
          </div>
        </div>

        <div className="mt-6">
          <h3 className="text-sm font-black text-white uppercase tracking-wider mb-3">🏆 Досягнення</h3>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div className={`rounded-2xl border p-3 flex items-center gap-3 ${stats.hasSniper ? "border-emerald-500/40 bg-emerald-500/10" : "border-white/5 bg-white/[0.02] opacity-40"}`}>
              <div className="text-2xl">🎯</div>
              <div>
                <p className="text-xs font-black text-white">Снайпер</p>
                <p className="text-[10px] text-slate-400">Виграш із шансом &le; 10%</p>
              </div>
            </div>
            <div className={`rounded-2xl border p-3 flex items-center gap-3 ${stats.hasHighroller ? "border-amber-500/40 bg-amber-500/10" : "border-white/5 bg-white/[0.02] opacity-40"}`}>
              <div className="text-2xl">👑</div>
              <div>
                <p className="text-xs font-black text-white">Хайролер</p>
                <p className="text-[10px] text-slate-400">Апгрейд скіна &gt; 50k GC</p>
              </div>
            </div>
            <div className={`rounded-2xl border p-3 flex items-center gap-3 ${stats.totalWins >= 5 ? "border-cyan-500/40 bg-cyan-500/10" : "border-white/5 bg-white/[0.02] opacity-40"}`}>
              <div className="text-2xl">⚡</div>
              <div>
                <p className="text-xs font-black text-white">Серійний апгрейдер</p>
                <p className="text-[10px] text-slate-400">5+ виграшів на платформі</p>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-6">
          <h3 className="text-sm font-black text-white uppercase tracking-wider mb-3">📜 Останні ігри</h3>
          {history.length === 0 ? (
            <p className="text-xs text-slate-500 text-center py-6">Ігор ще не зафіксовано. Зроби свій перший апгрейд!</p>
          ) : (
            <div className="space-y-2 max-h-60 overflow-y-auto pr-1">
              {history.map((h) => (
                <div key={h.id} className="flex items-center justify-between rounded-xl border border-white/5 bg-white/[0.02] p-3 text-xs">
                  <div className="flex items-center gap-2">
                    <span className={`px-2 py-0.5 rounded-md font-bold text-[10px] ${h.outcome === "win" ? "bg-emerald-500/20 text-emerald-400" : "bg-rose-500/20 text-rose-400"}`}>
                      {h.outcome === "win" ? "ВИГРАШ" : "ПРОГРАШ"}
                    </span>
                    <span className="font-semibold text-white">{h.sourceSkinName}</span>
                    <span className="text-slate-500">→</span>
                    <span className="font-bold text-emerald-300">{h.targetSkinName}</span>
                  </div>
                  <div className="flex items-center gap-3 font-mono">
                    <span className="text-slate-400">{h.chance}% (×{h.multiplier})</span>
                    <span className={`font-black ${h.profit >= 0 ? "text-emerald-400" : "text-rose-400"}`}>
                      {h.profit >= 0 ? `+${formatCoins(h.profit)}` : formatCoins(h.profit)} GC
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
EOF

# 6. components/share-win-modal.tsx: шеринг картки
cat << 'EOF' > components/share-win-modal.tsx
"use client";

import { useState } from "react";
import { formatCoins } from "@/app/data";
import { playClickSound } from "@/lib/sound-fx";

interface ShareWinModalProps {
  isOpen: boolean;
  onClose: () => void;
  skin: {
    weapon: string;
    name: string;
    price: number;
    image: string;
    rarity?: string;
  };
  chance: number | string;
  multiplier: number | string;
  playerName: string;
}

export function ShareWinModal({ isOpen, onClose, skin, chance, multiplier, playerName }: ShareWinModalProps) {
  const [copied, setCopied] = useState(false);

  if (!isOpen) return null;

  const handleCopyLink = () => {
    playClickSound();
    if (typeof navigator !== "undefined") {
      navigator.clipboard.writeText(
        `🔥 Я щойно виграв ${skin.weapon} | ${skin.name} (${formatCoins(skin.price)} GC) на Goicoins Simulator з шансом ${chance}% (×${multiplier})!`
      );
      setCopied(true);
      setTimeout(() => setCopied(false), 2500);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fade-in">
      <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-emerald-500/40 bg-[#0a0d16] p-6 shadow-2xl text-center">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-4 top-4 flex size-8 items-center justify-center rounded-xl bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white transition"
        >
          ✕
        </button>

        <h3 className="text-xl font-black text-white mb-4">📸 Поділитися виграшем</h3>

        <div className="rounded-2xl border-2 border-emerald-500/50 bg-gradient-to-br from-[#0c101c] via-[#080b12] to-[#051a12] p-5 shadow-inner text-center relative overflow-hidden">
          <div className="flex items-center justify-between text-[11px] font-black text-emerald-400 uppercase">
            <span>GOICOINS SIMULATOR</span>
            <span className="bg-emerald-500/20 px-2 py-0.5 rounded-full border border-emerald-500/30">Шанс: {chance}%</span>
          </div>

          <div className="my-3 flex h-32 items-center justify-center">
            <img src={skin.image} alt={skin.name} className="max-h-28 max-w-full object-contain filter drop-shadow-[0_0_20px_rgba(16,185,129,0.3)]" />
          </div>

          <p className="text-xs text-slate-400 font-bold uppercase">{skin.weapon}</p>
          <p className="text-lg font-black text-white">{skin.name}</p>

          <div className="mt-3 flex items-center justify-between border-t border-white/10 pt-2.5 text-xs font-mono">
            <span className="text-slate-400">Гравець: <strong className="text-white">{playerName}</strong></span>
            <span className="font-black text-emerald-400 text-sm">{formatCoins(skin.price)} GC</span>
          </div>
        </div>

        <button
          onClick={handleCopyLink}
          className="w-full mt-5 rounded-2xl bg-emerald-500 hover:bg-emerald-400 py-3 text-sm font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition flex items-center justify-center gap-2"
        >
          {copied ? "✅ Текст скопійовано для Telegram/Discord!" : "📋 Скопіювати для друзів"}
        </button>
      </div>
    </div>
  );
}
EOF

# 7. Підключення конфеті та історії в components/interactive-upgrader.tsx
node -e '
const fs = require("fs");
const file = "components/interactive-upgrader.tsx";

if (fs.existsSync(file)) {
  let content = fs.readFileSync(file, "utf8");

  if (!content.includes("triggerConfetti")) {
    content = content.replace(
      /from ["\x27]@\/lib\/live-drops-storage["\x27];/,
      "from \"@/lib/live-drops-storage\";\nimport { triggerConfetti, playJackpotSound } from \"@/lib/confetti\";\nimport { logGameRound } from \"@/lib/game-history-storage\";"
    );
  }

  if (!content.includes("logGameRound({")) {
    content = content.replace(
      "playWinSound();",
      `playWinSound();

      if (chance <= 20 || targetSkin.price >= 30000) {
        triggerConfetti();
        playJackpotSound();
      }

      try {
        logGameRound({
          sourceSkinName: sourceSkin ? sourceSkin.name : "GC",
          sourceSkinPrice: sourceSkin ? sourceSkin.price : 0,
          targetSkinName: targetSkin.name,
          targetSkinPrice: targetSkin.price,
          targetSkinImage: targetSkin.image || "",
          chance: Number(chance),
          multiplier: Number(multiplier),
          outcome: "win",
          profit: targetSkin.price - (sourceSkin ? sourceSkin.price : 0),
        });
      } catch (err) {}`
    );
  }

  fs.writeFileSync(file, content, "utf8");
  console.log("✅ components/interactive-upgrader.tsx конфеті та історію підключено!");
}
' || true

echo "=========================================================="
echo "🎉 ЧАСТИНА 1 УСПІШНО ЗАСТОСОВАНА! Переходьте до ЧАСТИНИ 2."
echo "=========================================================="
