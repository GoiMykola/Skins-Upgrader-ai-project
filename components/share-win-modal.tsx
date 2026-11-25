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
