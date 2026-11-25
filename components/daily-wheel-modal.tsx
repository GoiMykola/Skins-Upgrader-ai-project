"use client";

import { useState, useEffect } from "react";
import {
  WHEEL_PRIZES,
  canSpinWheel,
  claimWheelReward,
  type WheelPrize,
} from "@/lib/daily-wheel-storage";
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

        {/* Колесо з секторами */}
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
              {wonPrize.type === "coins" ? `Нараховано +${wonPrize.value} GC на твій баланс!` : "Додано у твій інвентар!"}
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
      </div>
    </div>
  );
}
