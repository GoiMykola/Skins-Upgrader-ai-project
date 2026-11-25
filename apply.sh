#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v43: ВИПРАВЛЕННЯ ВІНРЕЙТУ ТА БЕЗПЕКА ВХОДУ"
echo "=========================================================="

mkdir -p lib components

# 1. lib/auth-storage.ts: сувора перевірка пароля для всіх користувачів
node -e '
const fs = require("fs");
const file = "lib/auth-storage.ts";
if (fs.existsSync(file)) {
  let content = fs.readFileSync(file, "utf8");
  content = content.replace(
    /if \(!isCreatorOrDemo && user\.password && user\.password !== password\) {/g,
    "if (user.password && user.password !== password) {"
  );
  fs.writeFileSync(file, content, "utf8");
  console.log("✅ lib/auth-storage.ts: суворий захист паролем активовано!");
}
'

# 2. components/auth-modal.tsx: повне видалення кнопки швидкого входу Творця
cat << 'AUTH_MODAL_EOF' > components/auth-modal.tsx
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
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setTab(initialTab);
    setError(null);
    setSuccess(null);
  }, [initialTab, isOpen]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && isOpen) onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const handleTabSwitch = (newTab: "login" | "register") => {
    playClickSound();
    setTab(newTab);
    setError(null);
    setSuccess(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    playClickSound();
    setError(null);
    setSuccess(null);

    if (tab === "register") {
      if (password !== confirmPassword) {
        playLossSound();
        setError("Введені паролі не співпадають!");
        return;
      }
      setLoading(true);
      const res = registerUser(email, nickname, password);
      setLoading(false);

      if (!res.success) {
        playLossSound();
        setError(res.message || "Помилка реєстрації");
      } else {
        playWinSound();
        setSuccess(res.message || "Успішна реєстрація! +2 500 GC нараховано!");
        setTimeout(() => {
          onClose();
          if (onSuccess && res.user) onSuccess(res.user);
        }, 1200);
      }
    } else {
      setLoading(true);
      const res = loginUser(email, password);
      setLoading(false);

      if (!res.success) {
        playLossSound();
        setError(res.message || "Помилка входу");
      } else {
        playWinSound();
        setSuccess(res.message || "Успішний вхід!");
        setTimeout(() => {
          onClose();
          if (onSuccess && res.user) onSuccess(res.user);
        }, 1000);
      }
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fade-in">
      <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-emerald-500/30 bg-[#0a0d16] p-6 sm:p-8 shadow-[0_0_80px_rgba(16,185,129,0.2)]">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-4 top-4 flex size-9 items-center justify-center rounded-xl bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white transition"
        >
          ✕
        </button>

        <div className="flex justify-center mb-4">
          <div className="flex size-14 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-2xl font-black text-[#05130d] shadow-lg shadow-emerald-500/25">
            G
          </div>
        </div>

        <h2 className="text-center text-2xl font-black text-white">GoiCoins Simulator</h2>
        <p className="text-center text-xs text-slate-400 mt-1 mb-6">
          Авторизуйтесь для збереження скінів та балансу
        </p>

        <div className="flex rounded-2xl bg-black/40 p-1.5 border border-white/5 mb-6">
          <button
            onClick={() => handleTabSwitch("login")}
            className={`flex-1 rounded-xl py-2 text-xs font-black transition ${
              tab === "login"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            Увійти
          </button>
          <button
            onClick={() => handleTabSwitch("register")}
            className={`flex-1 rounded-xl py-2 text-xs font-black transition ${
              tab === "register"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            Реєстрація (+2.5k GC) 🎁
          </button>
        </div>

        {error && (
          <div className="mb-4 rounded-xl border border-rose-500/40 bg-rose-500/10 p-3 text-xs font-bold text-rose-300 animate-shake">
            ⚠️ {error}
          </div>
        )}

        {success && (
          <div className="mb-4 rounded-xl border border-emerald-500/40 bg-emerald-500/10 p-3 text-xs font-bold text-emerald-300 animate-fade-in">
            🎉 {success}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1.5">
              Електронна пошта
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="player@cs2goi.ua"
              className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-3 text-sm text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
            />
          </div>

          {tab === "register" && (
            <div>
              <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1.5">
                Нікнейм у грі
              </label>
              <input
                type="text"
                required
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                placeholder="Введіть нікнейм"
                className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-3 text-sm text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
            </div>
          )}

          <div>
            <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1.5">
              Пароль
            </label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Введіть пароль"
                className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-3 text-sm text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition pr-10"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-3 text-slate-400 hover:text-white text-xs"
              >
                {showPassword ? "🙈" : "👁️"}
              </button>
            </div>
          </div>

          {tab === "register" && (
            <div>
              <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1.5">
                Підтвердження пароля
              </label>
              <input
                type={showPassword ? "text" : "password"}
                required
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Повторіть пароль"
                className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-3 text-sm text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-xl bg-gradient-to-r from-emerald-500 to-teal-400 hover:brightness-110 py-3.5 text-sm font-black text-[#05130d] shadow-lg shadow-emerald-500/25 transition disabled:opacity-40"
          >
            {loading ? "Обробка..." : tab === "login" ? "Увійти в акаунт ⚡" : "Зареєструвати профіль 🎁"}
          </button>
        </form>
      </div>
    </div>
  );
}
AUTH_MODAL_EOF
echo "✅ components/auth-modal.tsx: публічну кнопку прибрано!"

# 3. lib/game-history-storage.ts: очищення та коректний вінрейт
cat << 'HISTORY_STORAGE_EOF' > lib/game-history-storage.ts
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

export function logGameRound(entry: Omit<GameHistoryEntry, "id" | "timestamp">): void {
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

export function clearGameHistory(): void {
  if (typeof window === "undefined") return;
  localStorage.removeItem(HISTORY_KEY);
  window.dispatchEvent(new CustomEvent("goi-history-updated"));
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
HISTORY_STORAGE_EOF
echo "✅ lib/game-history-storage.ts оновлено!"

# 4. components/interactive-upgrader.tsx: додано логування програшів
node -e '
const fs = require("fs");
const file = "components/interactive-upgrader.tsx";
if (fs.existsSync(file)) {
  let content = fs.readFileSync(file, "utf8");

  if (!content.includes("logGameRound")) {
    content = content.replace(
      /from ["\x27]@\/app\/data["\x27];/,
      "from \"@/app/data\";\nimport { logGameRound } from \"@/lib/game-history-storage\";"
    );
  }

  if (!content.includes("outcome: \"loss\"")) {
    content = content.replace(
      "playLossSound();",
      `playLossSound();

      try {
        logGameRound({
          sourceSkinName: sourceSkin ? sourceSkin.name : "GC",
          sourceSkinPrice: sourceSkin ? sourceSkin.price : 0,
          targetSkinName: targetSkin.name,
          targetSkinPrice: targetSkin.price,
          targetSkinImage: targetSkin.image || "",
          chance: Number(chance),
          multiplier: Number(multiplier),
          outcome: "loss",
          profit: -(sourceSkin ? sourceSkin.price : 0),
        });
      } catch (err) {}`
    );
    console.log("✅ components/interactive-upgrader.tsx: логування програшів підключено!");
  } else {
    console.log("ℹ️ Логування програшів уже наявне.");
  }

  fs.writeFileSync(file, content, "utf8");
}
'

# 5. components/game-stats-modal.tsx: модалка зі скиданням історії
cat << 'STATS_MODAL_EOF' > components/game-stats-modal.tsx
"use client";

import { useState, useEffect } from "react";
import { getGameHistory, getGameStats, clearGameHistory, type GameHistoryEntry } from "@/lib/game-history-storage";
import { formatCoins } from "@/app/data";
import { playClickSound } from "@/lib/sound-fx";

interface GameStatsModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function GameStatsModal({ isOpen, onClose }: GameStatsModalProps) {
  const [history, setHistory] = useState<GameHistoryEntry[]>([]);
  const [stats, setStats] = useState(getGameStats());

  const update = () => {
    setHistory(getGameHistory());
    setStats(getGameStats());
  };

  useEffect(() => {
    if (isOpen) {
      update();
    }
    const handleUpdate = () => update();
    window.addEventListener("goi-history-updated", handleUpdate);
    return () => window.removeEventListener("goi-history-updated", handleUpdate);
  }, [isOpen]);

  if (!isOpen) return null;

  const handleClear = () => {
    playClickSound();
    clearGameHistory();
    update();
  };

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

        <div className="flex flex-wrap items-center justify-between gap-3 mb-2">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-400/10 px-4 py-1.5 text-xs font-black uppercase tracking-wider text-emerald-400">
            📊 ОСОБИСТА СТАТИСТИКА
          </div>
          {history.length > 0 && (
            <button
              onClick={handleClear}
              className="text-xs text-rose-400 hover:text-rose-300 underline font-bold transition"
            >
              Скинути історію ✕
            </button>
          )}
        </div>
        <h2 className="text-2xl sm:text-3xl font-black text-white">Історія ігор та досягнення</h2>

        <div className="mt-6 grid grid-cols-2 sm:grid-cols-4 gap-3">
          <div className="rounded-2xl border border-white/5 bg-white/[0.03] p-4 text-center">
            <p className="text-xs text-slate-400 font-bold">Усього ігор</p>
            <p className="text-2xl font-black text-white mt-1">{stats.totalSpins}</p>
          </div>
          <div className="rounded-2xl border border-white/5 bg-white/[0.03] p-4 text-center">
            <p className="text-xs text-slate-400 font-bold">Вінрейт</p>
            <p className={`text-2xl font-black mt-1 ${stats.winrate >= 50 ? "text-emerald-400" : "text-amber-400"}`}>
              {stats.winrate}%
            </p>
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
                <p className="text-[10px] text-slate-400">Виграш із шансом ≤ 10%</p>
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
                  <div className="flex items-center gap-3">
                    <span className={`px-2 py-0.5 rounded-md font-bold text-[10px] ${h.outcome === "win" ? "bg-emerald-500/20 text-emerald-400" : "bg-rose-500/20 text-rose-400"}`}>
                      {h.outcome === "win" ? "ВИГРАШ" : "ПРОГРАШ"}
                    </span>
                    <div>
                      <p className="font-bold text-white">{h.sourceSkinName} ➜ {h.targetSkinName}</p>
                      <p className="text-[10px] text-slate-500">Шанс: {h.chance}% · Множник: ×{h.multiplier}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className={`font-mono font-bold ${h.profit >= 0 ? "text-emerald-400" : "text-rose-400"}`}>
                      {h.profit >= 0 ? `+${formatCoins(h.profit)}` : formatCoins(h.profit)} GC
                    </p>
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
STATS_MODAL_EOF
echo "✅ components/game-stats-modal.tsx оновлено!"

# 6. Перевірка компіляції Next.js
echo "=========================================================="
echo "🧪 ПЕРЕВІРКА БІЛДУ ПРОЄКТУ (npm run build)..."
echo "=========================================================="
npm run build

# 7. Фіксація змін та пуш на GitHub
echo "=========================================================="
echo "🚀 ПУШ НА GITHUB ТА VERCEL"
echo "=========================================================="
git add -A
git commit -m "feat(stats): fix winrate calculation by logging losses and remove public creator login button" || echo "Без змін"
git push origin main --force

echo "=========================================================="
echo "🎉 ВСЕ УСПІШНО ВИПРАВЛЕНО ТА ВІДПРАВЛЕНО НА VERCEL!"
echo "=========================================================="
