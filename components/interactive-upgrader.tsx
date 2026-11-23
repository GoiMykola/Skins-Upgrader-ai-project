"use client";

import { useState, useRef } from "react";
import type { Skin } from "@/app/data";
import { formatCoins, skins, inventorySkins } from "@/app/data";
import SkinArt from "@/app/components/skin-art";
import {
  playClickSound,
  playTickSound,
  playWinSound,
  playLossSound,
  toggleMute,
} from "@/lib/sound-fx";

export function InteractiveUpgrader() {
  const [sourceSkin, setSourceSkin] = useState<Skin>(inventorySkins[0] || skins[0]);
  const [targetSkin, setTargetSkin] = useState<Skin>(skins[2] || skins[1]);
  const [isSpinning, setIsSpinning] = useState(false);
  const [rotation, setRotation] = useState(0);
  const [outcome, setOutcome] = useState<"win" | "loss" | null>(null);
  const [showResultModal, setShowResultModal] = useState(false);
  const [muted, setMuted] = useState(false);
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  const rawChance = (sourceSkin.price / targetSkin.price) * 100 * 0.95;
  const chance = Math.min(95, Math.max(1, Math.round(rawChance * 10) / 10));
  const multiplier = Math.round((targetSkin.price / sourceSkin.price) * 100) / 100;
  const winAngle = (chance / 100) * 360;

  const handleSoundToggle = () => {
    const next = toggleMute();
    setMuted(next);
  };

  const handleUpgrade = () => {
    if (isSpinning) return;
    playClickSound();
    setIsSpinning(true);
    setOutcome(null);
    setShowResultModal(false);

    const isWin = Math.random() * 100 <= chance;
    let targetSectorAngle: number;
    if (isWin) {
      targetSectorAngle = Math.random() * (winAngle - 6) + 3;
    } else {
      targetSectorAngle = winAngle + Math.random() * (360 - winAngle - 6) + 3;
    }

    const fullRotations = 360 * 5;
    const finalDegree = rotation + fullRotations + targetSectorAngle;
    setRotation(finalDegree);

    let tickCount = 0;
    const interval = setInterval(() => {
      tickCount++;
      playTickSound(500 + (tickCount % 5) * 40);
      if (tickCount > 28) clearInterval(interval);
    }, 140);

    if (timerRef.current) clearTimeout(timerRef.current);
    timerRef.current = setTimeout(() => {
      setIsSpinning(false);
      setOutcome(isWin ? "win" : "loss");
      setShowResultModal(true);
      if (isWin) playWinSound();
      else playLossSound();
    }, 4200);
  };

  return (
    <div className="relative overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0d1018]/90 p-5 shadow-2xl shadow-black/80 backdrop-blur-xl sm:p-7">
      <div className="flex items-center justify-between border-b border-white/[0.06] pb-4">
        <div className="flex items-center gap-2">
          <span className="size-2 rounded-full bg-amber-400 shadow-[0_0_10px_#f59e0b]" />
          <h2 className="text-base font-extrabold uppercase tracking-wider text-white">
            Кібер-Модуль Апгрейду
          </h2>
        </div>
        <button
          onClick={handleSoundToggle}
          className="rounded-lg border border-white/10 bg-white/5 px-2.5 py-1 text-xs font-semibold text-slate-400 hover:text-white"
        >
          {muted ? "🔇 Без звуку" : "🔊 Звук увімкнено"}
        </button>
      </div>

      <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-5">
        <div className="rounded-2xl border border-white/[0.06] bg-black/30 p-4">
          <div className="flex justify-between items-center mb-2">
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
              Твій скін (інвентар)
            </span>
            <span className="font-mono text-xs font-bold text-amber-300">
              {formatCoins(sourceSkin.price)} GC
            </span>
          </div>
          <SkinArt skin={sourceSkin} className="h-28" />
          <p className="mt-2 text-sm font-bold text-white truncate">
            {sourceSkin.weapon} · {sourceSkin.name}
          </p>
          <div className="mt-3 flex gap-1.5 overflow-x-auto pb-1 no-scrollbar">
            {inventorySkins.map((s) => (
              <button
                key={s.finish}
                onClick={() => {
                  playClickSound();
                  setSourceSkin(s);
                }}
                className={`shrink-0 rounded-lg border px-2.5 py-1 text-[11px] font-semibold transition ${
                  sourceSkin.finish === s.finish
                    ? "border-amber-400 bg-amber-400/20 text-amber-200"
                    : "border-white/5 bg-white/5 text-slate-400 hover:bg-white/10"
                }`}
              >
                {s.weapon}
              </button>
            ))}
          </div>
        </div>

        <div className="rounded-2xl border border-white/[0.06] bg-black/30 p-4">
          <div className="flex justify-between items-center mb-2">
            <span className="text-[10px] font-bold uppercase tracking-wider text-violet-400">
              Бажаний скін (ціль)
            </span>
            <span className="font-mono text-xs font-bold text-amber-300">
              {formatCoins(targetSkin.price)} GC
            </span>
          </div>
          <SkinArt skin={targetSkin} className="h-28" />
          <p className="mt-2 text-sm font-bold text-white truncate">
            {targetSkin.weapon} · {targetSkin.name}
          </p>
          <div className="mt-3 flex gap-1.5 overflow-x-auto pb-1 no-scrollbar">
            {skins.slice(1, 6).map((s) => (
              <button
                key={s.finish}
                onClick={() => {
                  playClickSound();
                  setTargetSkin(s);
                }}
                className={`shrink-0 rounded-lg border px-2.5 py-1 text-[11px] font-semibold transition ${
                  targetSkin.finish === s.finish
                    ? "border-violet-400 bg-violet-400/20 text-violet-200"
                    : "border-white/5 bg-white/5 text-slate-400 hover:bg-white/10"
                }`}
              >
                {s.weapon}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Колесо рулетки */}
      <div className="relative mt-8 flex flex-col items-center justify-center">
        <div className="relative flex size-64 items-center justify-center sm:size-72">
          <div className="absolute -top-3 z-20 flex flex-col items-center">
            <div className="size-0 border-x-8 border-x-transparent border-t-[14px] border-t-amber-400 drop-shadow-[0_0_8px_#f59e0b]" />
          </div>

          <svg className="size-full -rotate-90 transform" viewBox="0 0 100 100">
            <circle cx="50" cy="50" r="40" fill="transparent" stroke="#1c202e" strokeWidth="10" />
            <circle
              cx="50"
              cy="50"
              r="40"
              fill="transparent"
              stroke="url(#winGradient)"
              strokeWidth="10"
              strokeDasharray={`${(winAngle / 360) * 251.2} 251.2`}
              strokeLinecap="round"
            />
            <defs>
              <linearGradient id="winGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#10b981" />
                <stop offset="100%" stopColor="#34d399" />
              </linearGradient>
            </defs>
          </svg>

          <div
            className="absolute inset-0 flex items-center justify-center pointer-events-none"
            style={{
              transform: `rotate(${rotation}deg)`,
              transition: isSpinning ? "transform 4.2s cubic-bezier(0.15, 0.85, 0.25, 1)" : "none",
            }}
          >
            <div className="h-28 w-1 rounded-full bg-gradient-to-t from-transparent via-amber-300 to-amber-400 shadow-[0_0_12px_#f59e0b]" />
          </div>

          <div className="absolute flex size-36 flex-col items-center justify-center rounded-full border border-white/10 bg-[#0b0d14] shadow-inner text-center">
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Шанс</span>
            <span className="text-3xl font-black text-white">{chance}%</span>
            <span className="mt-0.5 rounded-full bg-violet-500/20 px-2 py-0.5 font-mono text-[11px] font-bold text-violet-300">
              ×{multiplier}
            </span>
          </div>
        </div>
      </div>

      <div className="mt-8 flex justify-center">
        <button
          onClick={handleUpgrade}
          disabled={isSpinning}
          className={`w-full max-w-md rounded-2xl py-4 text-base font-black uppercase tracking-wider transition shadow-lg ${
            isSpinning
              ? "cursor-not-allowed bg-slate-700 text-slate-400"
              : "bg-gradient-to-r from-amber-400 via-orange-500 to-rose-500 text-[#1a1005] shadow-orange-500/25 hover:brightness-110 active:scale-[0.99]"
          }`}
        >
          {isSpinning ? "Крутимо рулетку..." : "АПГРЕЙДИТИ СКІН ⚡"}
        </button>
      </div>

      {showResultModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md">
          <div className="w-full max-w-sm rounded-3xl border border-white/10 bg-[#0e111a] p-6 text-center shadow-2xl">
            {outcome === "win" ? (
              <>
                <div className="mx-auto flex size-16 items-center justify-center rounded-full bg-emerald-500/20 text-3xl shadow-[0_0_20px_#10b981]">
                  🎉
                </div>
                <h3 className="mt-4 text-2xl font-black text-white">УСПІШНИЙ АПГРЕЙД!</h3>
                <p className="mt-1 text-sm text-emerald-400">
                  Ти виграв {targetSkin.weapon} · {targetSkin.name}!
                </p>
                <div className="my-4">
                  <SkinArt skin={targetSkin} className="h-28" />
                </div>
              </>
            ) : (
              <>
                <div className="mx-auto flex size-16 items-center justify-center rounded-full bg-rose-500/20 text-3xl shadow-[0_0_20px_#ef4444]">
                  💥
                </div>
                <h3 className="mt-4 text-2xl font-black text-white">НЕ ВДАЛОСЯ!</h3>
                <p className="mt-1 text-sm text-rose-400">Стрілка зупинилася в червоній зоні.</p>
                <div className="my-4">
                  <SkinArt skin={sourceSkin} className="h-28 opacity-40 grayscale" />
                </div>
              </>
            )}
            <button
              onClick={() => {
                playClickSound();
                setShowResultModal(false);
              }}
              className="mt-6 w-full rounded-xl bg-white/10 py-3 text-sm font-bold text-white hover:bg-white/20"
            >
              Продовжити гру
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
