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
    let active = true;
    if (isOpen) {
      queueMicrotask(() => {
        if (active) update();
      });
    }
    const handleUpdate = () => update();
    window.addEventListener("goi-history-updated", handleUpdate);
    return () => {
      active = false;
      window.removeEventListener("goi-history-updated", handleUpdate);
    };
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
