"use client";

import { useState, useRef, useEffect } from "react";
import type { Skin } from "@/app/data";
import { formatCoins, skins, inventorySkins } from "@/app/data";
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

  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const crawlIntervalRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    const inv = getStoredInventory();
    setUserInventory(inv);
    if (inv.length > 0) setSourceSkin(inv[0]);
    setMuted(isMuted());

    // Перевіряємо вибір джерела з інвентаря
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

    // Перевіряємо вибір цілі з Ринку
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

    const handleInvUpdate = (e: CustomEvent<InventoryItem[]>) => {
      if (e.detail) setUserInventory(e.detail);
    };
    window.addEventListener("goi-inventory-updated", handleInvUpdate as EventListener);

    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
      if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
      window.removeEventListener("goi-inventory-updated", handleInvUpdate as EventListener);
    };
  }, []);

  const rawChance = (sourceSkin.price / targetSkin.price) * 100 * 0.95;
  const chance = Math.min(95, Math.max(0.5, Math.round(rawChance * 10) / 10));
  const multiplier = Math.round((targetSkin.price / sourceSkin.price) * 100) / 100;
  
  const winAngle = (chance / 100) * 360;
  const circleCircumference = 270.2;
  const winStrokeDash = (winAngle / 360) * circleCircumference;
  const currentConfig = SPIN_CONFIGS[spinMode];

  const handleSoundToggle = () => {
    const next = toggleMute();
    setMuted(next);
  };

  const handleMultiplierSelect = (mult: number) => {
    playClickSound();
    const targetPrice = sourceSkin.price * mult;
    const bestMatch = skins.reduce((prev, curr) =>
      Math.abs(curr.price - targetPrice) < Math.abs(prev.price - targetPrice) ? curr : prev
    );
    setTargetSkin(bestMatch);
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
      const safeMax = Math.max(5, winAngle - 4);
      targetSectorAngle = 3 + Math.random() * (safeMax - 3);
    } else {
      const darkSpan = 360 - winAngle - 10;
      targetSectorAngle = winAngle + 6 + Math.random() * Math.max(1, darkSpan);
    }

    const currentBaseCycle = Math.floor(rotation / 360);

    if (spinMode === "suspense") {
      const crawlDegrees = 110;
      const finalDegree = (currentBaseCycle + 7) * 360 + targetSectorAngle;
      const intermediateDegree = finalDegree - crawlDegrees;

      setSpinTransition("transform 2400ms cubic-bezier(0.12, 0.85, 0.25, 1)");
      requestAnimationFrame(() => {
        setRotation(intermediateDegree);
      });

      let tickFastCount = 0;
      const fastInterval = setInterval(() => {
        tickFastCount++;
        playTickSound(550 + (tickFastCount % 5) * 40);
        if (tickFastCount >= 18) clearInterval(fastInterval);
      }, 125);

      setTimeout(() => {
        setSpinTransition("transform 3000ms linear");
        setRotation(finalDegree);

        let crawlTicks = 0;
        crawlIntervalRef.current = setInterval(() => {
          crawlTicks++;
          playTickSound(490 + (crawlTicks % 3) * 35);
          if (crawlTicks >= 12) {
            if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
          }
        }, 250);

        setTimeout(() => {
          finishSpin(isWin);
        }, 3100);
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

      const tickMs = spinMode === "fast" ? 75 : spinMode === "long" ? 170 : 130;
      const maxTicks = Math.floor(duration / tickMs) - 2;
      let tickCount = 0;
      const interval = setInterval(() => {
        tickCount++;
        playTickSound(520 + (tickCount % 6) * 35);
        if (tickCount >= maxTicks) clearInterval(interval);
      }, tickMs);

      if (timerRef.current) clearTimeout(timerRef.current);
      timerRef.current = setTimeout(() => {
        finishSpin(isWin);
      }, duration + 150);
    }
  };

  const finishSpin = (isWin: boolean) => {
    setIsSpinning(false);
    setOutcome(isWin ? "win" : "loss");
    setShowResultModal(true);

    if (isWin) {
      playWinSound();
      const updatedInv = addSkinToInventory(targetSkin);
      setUserInventory(updatedInv);
    } else {
      playLossSound();
    }
  };

  return (
    <div className="relative overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0d1018]/95 p-6 shadow-2xl shadow-black/80 backdrop-blur-xl sm:p-8">
      {/* Верхній статус бар */}
      <div className="flex flex-wrap items-center justify-between gap-4 border-b border-white/[0.06] pb-4">
        <div className="flex items-center gap-2.5">
          <span className="size-2.5 rounded-full bg-amber-400 shadow-[0_0_12px_#f59e0b]" />
          <h2 className="text-sm font-black uppercase tracking-wider text-white">
            CS2 UPGRADER ARENA · РУЛЕТКА
          </h2>
        </div>

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
                    ? "bg-gradient-to-r from-amber-400 to-orange-500 text-[#1a1104] shadow-md shadow-orange-500/20"
                    : "text-slate-400 hover:text-white hover:bg-white/5"
                }`}
              >
                <span>{cfg.icon}</span>
                <span>{cfg.label}</span>
              </button>
            );
          })}
        </div>

        <button
          onClick={handleSoundToggle}
          className="rounded-lg border border-white/10 bg-white/5 px-2.5 py-1 text-xs font-semibold text-slate-400 hover:text-white"
        >
          {muted ? "🔇 Без звуку" : "🔊 Звук увімкнено"}
        </button>
      </div>

      {/* 3-Колонкова арена */}
      <div className="mt-8 grid grid-cols-1 items-center gap-6 lg:grid-cols-[1fr_auto_1fr]">
        {/* ЛІВА КОЛОНКА (Твій скін) */}
        <div className="w-full max-w-[340px] justify-self-center lg:justify-self-end flex flex-col justify-between rounded-2xl border border-white/[0.06] bg-black/40 p-4">
          <div>
            <div className="flex items-center justify-between">
              <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                Твій скін (інвентар)
              </span>
              <span className="font-mono text-xs font-bold text-amber-300">
                {formatCoins(sourceSkin.price)} GC
              </span>
            </div>
            <div className="my-3">
              <SkinArt skin={sourceSkin} className="h-32" />
            </div>
            <p className="font-bold text-white truncate text-base">
              {sourceSkin.weapon} | {sourceSkin.name}
            </p>
            <p className="text-xs text-slate-400 mt-0.5">{sourceSkin.wear}</p>
          </div>

          <div className="mt-4 border-t border-white/[0.06] pt-3">
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-500 block mb-1.5">
              Обрати з інвентаря:
            </span>
            <div className="flex gap-1.5 overflow-x-auto pb-1 no-scrollbar">
              {userInventory.map((s) => (
                <button
                  key={`user-inv-item-${s.instanceId}`}
                  onClick={() => {
                    playClickSound();
                    setSourceSkin(s);
                  }}
                  className={`shrink-0 rounded-lg border px-2 py-1 text-[11px] font-semibold transition ${
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
        </div>

        {/* ЦЕНТРАЛЬНА КОЛОНКА: ЗБІЛЬШЕНЕ КОЛЕСО СУВОРО ПО ЦЕНТРУ */}
        <div className="flex flex-col items-center justify-center justify-self-center px-2">
          <div className="relative flex size-80 items-center justify-center sm:size-92">
            <svg className="size-full -rotate-90 transform" viewBox="0 0 100 100">
              <circle
                cx="50"
                cy="50"
                r="43"
                className="stroke-[#131826]"
                strokeWidth="6"
                fill="transparent"
              />
              <circle
                cx="50"
                cy="50"
                r="43"
                className="stroke-emerald-400 transition-all duration-300 drop-shadow-[0_0_12px_rgba(52,211,153,0.55)]"
                strokeWidth="6"
                strokeDasharray={`${winStrokeDash} ${circleCircumference}`}
                strokeLinecap="butt"
                fill="transparent"
              />
            </svg>

            {/* Стрілка: Золотий лазерний шеврон, що вказує прямо в доріжку */}
            <div
              className="pointer-events-none absolute inset-0 z-20 flex items-center justify-center will-change-transform"
              style={{
                transform: `rotate(${rotation}deg)`,
                transition: spinTransition,
              }}
            >
              <div className="absolute top-2.5 flex flex-col items-center">
                <div className="h-4 w-1 bg-gradient-to-t from-amber-400 to-transparent shadow-[0_0_8px_#f59e0b]" />
                <div className="size-0 border-x-[7px] border-t-[12px] border-x-transparent border-t-amber-400 drop-shadow-[0_0_10px_#f59e0b]" />
                <div className="size-1.5 -mt-1 rounded-full bg-white shadow-[0_0_6px_#fff]" />
              </div>
            </div>

            {/* Центр рулетки з показниками */}
            <div className="absolute flex flex-col items-center justify-center text-center">
              <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                ШАНС АПГРЕЙДУ
              </span>
              <span className="font-mono text-3xl font-black text-white sm:text-4xl">
                {chance}%
              </span>
              <span className="mt-1 rounded-full bg-white/5 px-2.5 py-0.5 font-mono text-xs font-bold text-amber-300 border border-white/5">
                ×{multiplier}
              </span>
              <span className="mt-1 text-[10px] text-slate-500 font-medium">
                Режим: {currentConfig.label}
              </span>
            </div>
          </div>

          {/* Швидкі множники */}
          <div className="mt-2 flex items-center gap-1.5 rounded-xl border border-white/[0.06] bg-black/40 p-1.5">
            {[1.5, 2, 3, 5, 10, 15].map((m) => (
              <button
                key={`mult-btn-${m}`}
                onClick={() => handleMultiplierSelect(m)}
                disabled={isSpinning}
                className="rounded-lg px-2.5 py-1 font-mono text-xs font-bold text-slate-400 transition hover:bg-white/10 hover:text-amber-300 disabled:opacity-40"
              >
                {m}×
              </button>
            ))}
          </div>
        </div>

        {/* ПРАВА КОЛОНКА (Ціль) */}
        <div className="w-full max-w-[340px] justify-self-center lg:justify-self-start flex flex-col justify-between rounded-2xl border border-white/[0.06] bg-black/40 p-4">
          <div>
            <div className="flex items-center justify-between">
              <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                Бажаний скін (ціль)
              </span>
              <span className="font-mono text-xs font-bold text-amber-300">
                {formatCoins(targetSkin.price)} GC
              </span>
            </div>
            <div className="my-3">
              <SkinArt skin={targetSkin} className="h-32" />
            </div>
            <p className="font-bold text-white truncate text-base">
              {targetSkin.weapon} | {targetSkin.name}
            </p>
            <p className="text-xs text-slate-400 mt-0.5">{targetSkin.wear}</p>
          </div>

          <div className="mt-4 border-t border-white/[0.06] pt-3">
            <div className="flex items-center justify-between mb-1.5">
              <span className="text-[10px] font-bold uppercase tracking-wider text-slate-500">
                Обрати бажану ціль:
              </span>
              <a
                href="/market"
                className="text-[10px] font-bold text-amber-400 hover:text-amber-300 underline"
              >
                Всі з Ринку →
              </a>
            </div>
            <div className="flex gap-1.5 overflow-x-auto pb-1 no-scrollbar">
              {skins.map((s, idx) => (
                <button
                  key={`target-select-btn-${s.finish}-${idx}`}
                  onClick={() => {
                    playClickSound();
                    setTargetSkin(s);
                  }}
                  className={`shrink-0 rounded-lg border px-2 py-1 text-[11px] font-semibold transition ${
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
      </div>

      {/* Кнопка запуску апгрейду */}
      <div className="mt-8 flex justify-center">
        <button
          onClick={handleUpgrade}
          disabled={isSpinning}
          className={`w-full max-w-lg rounded-2xl py-4 text-base font-black uppercase tracking-wider transition shadow-xl ${
            isSpinning
              ? "cursor-not-allowed bg-slate-700 text-slate-400"
              : "bg-gradient-to-r from-amber-400 via-orange-500 to-rose-500 text-[#1a1005] shadow-orange-500/25 hover:brightness-110 active:scale-[0.99]"
          }`}
        >
          {isSpinning ? "Крутимо рулетку..." : "АПГРЕЙДИТИ СКІН ⚡"}
        </button>
      </div>

      {/* Модальне вікно результату */}
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
                <div className="mx-auto flex size-16 items-center justify-center rounded-full bg-rose-500/20 text-3xl shadow-[0_0_20px_#ef4444]">
                  💥
                </div>
                <h3 className="mt-4 text-2xl font-black text-white">НЕ ВДАЛОСЯ!</h3>
                <p className="mt-1 text-sm text-rose-400">Стрілка зупинилася в червоній зоні.</p>
                <div className="my-4">
                  <SkinArt skin={sourceSkin} className="h-32 opacity-35 grayscale" />
                </div>
              </>
            )}
            <div className="mt-6 flex flex-col gap-2">
              <button
                onClick={() => {
                  playClickSound();
                  setShowResultModal(false);
                }}
                className="w-full rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 py-3 text-sm font-black text-[#1a1104] shadow-md hover:brightness-110 transition"
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
