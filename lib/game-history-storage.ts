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
