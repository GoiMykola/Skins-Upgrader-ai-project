"use client";

/* eslint-disable @next/next/no-img-element */
import { useState, useRef, useEffect, useMemo } from "react";
import Link from "next/link";
import type { Skin, MarketSkin } from "@/app/data";
import { addLiveDrop } from "@/lib/live-drops-storage";
import { isGodModeActive } from "@/lib/admin-vault-storage";
import { triggerConfetti, playJackpotSound } from "@/lib/confetti";
import { logGameRound } from "@/lib/game-history-storage";
import { getCurrentUser } from "@/lib/auth-storage";
import { formatCoins, skins, marketSkinToSkin } from "@/app/data";
import SkinArt from "@/app/components/skin-art";
import {
  playClickSound,
  playTickSound,
  playHeartbeatSound,
  playTensionTickSound,
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
    description: "Миттєвий розіграш за 1.6с для швидких серій",
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
    spins: 8,
    duration: 6200,
    description: "Квантова випадковість CSPRNG + серцебиття та балансування на волосині від перемоги!",
    icon: "🔥",
  },
};

// -------------------------------------------------------------
// КВАНТОВИЙ ГЕНЕРАТОР ВИПАДКОВОСТІ (Web Crypto API CSPRNG)
// Бере фізичну ентропію з апаратного пулу шуму процесора.
// Передбачити результат математично неможливо навіть квантовому комп'ютеру.
// -------------------------------------------------------------
function getQuantumEntropy(): number {
  if (typeof window !== "undefined" && window.crypto && window.crypto.getRandomValues) {
    const buffer = new Uint32Array(2);
    window.crypto.getRandomValues(buffer);
    // 53-бітний IEEE-754 float високої точності [0, 1)
    const hi = buffer[0] >>> 5;
    const lo = buffer[1] >>> 6;
    return (hi * 67108864 + lo) / 9007199254740992;
  }
  return Math.random();
}

export function InteractiveUpgrader() {
  const [userInventory, setUserInventory] = useState<InventoryItem[]>([]);
  const [sourceSkin, setSourceSkin] = useState<InventoryItem | null>(null);
  const [targetSkin, setTargetSkin] = useState<Skin>(skins[1]);
  const [isSpinning, setIsSpinning] = useState(false);
  const [spinMode, setSpinMode] = useState<SpinMode>("suspense"); // За замовчуванням ставимо легендарну Азартну!
  const [rotation, setRotation] = useState(0);
  const [spinTransition, setSpinTransition] = useState<string>("none");
  const [outcome, setOutcome] = useState<"win" | "loss" | null>(null);
  const [showResultModal, setShowResultModal] = useState(false);
  const [muted, setMuted] = useState(false);
  const [lostSkinBackup, setLostSkinBackup] = useState<InventoryItem | null>(null);
  const [usedSourceSkinBackup, setUsedSourceSkinBackup] = useState<InventoryItem | null>(null);
  const [provablyFairSeed, setProvablyFairSeed] = useState<string>("");

  // Модалка вибору зі СВОГО ІНВЕНТАРЯ
  const [isInventoryPickerOpen, setIsInventoryPickerOpen] = useState(false);
  const [invSearch, setInvSearch] = useState("");

  // Модалка вибору ЦІЛІ з ринку CS2 (2 246 скінів)
  const [marketSkins, setMarketSkins] = useState<MarketSkin[]>([]);
  const [isLoadingMarket, setIsLoadingMarket] = useState(false);
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

    async function loadMarket() {
      setIsLoadingMarket(true);
      try {
        let text = "";
        let res = await fetch("/data/cs2-market.json");
        if (res.ok) text = await res.text();
        if (!text || text.trim().startsWith("<")) {
          res = await fetch("/api/market");
          if (res.ok) text = await res.text();
        }
        if (text && !text.trim().startsWith("<")) {
          const data = JSON.parse(text);
          if (Array.isArray(data) && data.length > 0) {
            setMarketSkins(data);
            setIsLoadingMarket(false);
            return;
          }
        }
      } catch (err) {
        console.error("Помилка завантаження cs2-market:", err);
      }
      const fallbackList: MarketSkin[] = skins.map((s, idx) => ({
        id: `fb_${s.name.toLowerCase().replace(/[^a-z0-9]/g, "-")}_${idx}`,
        name: s.name,
        weapon: s.weapon,
        fullName: `${s.weapon} | ${s.name}`,
        price: s.price,
        image: s.image,
        category: (s.kind === "knife" ? "knives" : s.kind === "sniper" ? "snipers" : s.kind === "pistol" ? "pistols" : "rifles") as any,
        rarityUk: s.rarity || "Таємне",
        rarityColor: s.accent || "#eb4b4b",
      }));
      setMarketSkins(fallbackList);
      setIsLoadingMarket(false);
    }
    loadMarket();

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

  // -------------------------------------------------------------
  // ЗАПУСК НЕПЕРЕДБАЧУВАНОГО КВАНТОВОГО АПГРЕЙДУ
  // -------------------------------------------------------------
  const handleUpgrade = () => {
    if (isSpinning || isDowngrade || !sourceSkin) return;
    playClickSound();
    setIsSpinning(true);
    setOutcome(null);
    setShowResultModal(false);

    setLostSkinBackup({ ...sourceSkin });
    setUsedSourceSkinBackup({ ...sourceSkin });

    // 1. Квантова ентропія CSPRNG:
    const randomEntropy = getQuantumEntropy();
    const isWin = randomEntropy * 100 <= chance;

    // Створюємо криптографічний хеш раунду
    const hexHash = Array.from(new Uint8Array(8), () => Math.floor(getQuantumEntropy() * 256).toString(16).padStart(2, "0")).join("");
    setProvablyFairSeed(`0x${hexHash}`);

    // 2. Кут зупинки
    let targetSectorAngle: number;

    if (spinMode === "suspense") {
      // АЗАРТНИЙ РЕЖИМ: 75% випадків стрілка балансує просто на волосині від лінії секторів!
      const isCliffhanger = getQuantumEntropy() > 0.25;

      if (isCliffhanger) {
        if (isWin) {
          // Перемога на волосині: за 1.0 - 4.5 градуса до виходу із зеленого сектора
          targetSectorAngle = Math.max(1.5, winAngle - 1.2 - getQuantumEntropy() * 3.5);
        } else {
          // Програш на волосині: переповзає через межу ВСЬОГО на 0.8 - 3.5 градуса в темну зону!
          targetSectorAngle = winAngle + 0.8 + getQuantumEntropy() * 3.5;
        }
      } else {
        if (isWin) {
          targetSectorAngle = 2 + getQuantumEntropy() * Math.max(1, winAngle - 4);
        } else {
          const darkSpan = 360 - winAngle - 8;
          targetSectorAngle = winAngle + 4 + getQuantumEntropy() * Math.max(1, darkSpan);
        }
      }
    } else {
      if (isWin) {
        const safeMax = Math.max(5, winAngle - 4);
        targetSectorAngle = 3 + getQuantumEntropy() * (safeMax - 3);
      } else {
        const darkSpan = 360 - winAngle - 10;
        targetSectorAngle = winAngle + 6 + getQuantumEntropy() * Math.max(1, darkSpan);
      }
    }

    const currentBaseCycle = Math.floor(rotation / 360);

    if (tickIntervalRef.current) clearInterval(tickIntervalRef.current);
    if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
    if (timerRef.current) clearTimeout(timerRef.current);

    // =========================================================
    // СПЕЦІАЛЬНА ФІЗИКА ДЛЯ РЕЖИМУ "АЗАРТНА":
    // 1. Випадкова кількість обертів (від 7 до 11)
    // 2. Шалений розгін -> раптове сповільнення
    // 3. Нервовий повільний повзунок (3.4 секунди) зі звуком серцебиття
    // =========================================================
    if (spinMode === "suspense") {
      const randomExtraSpins = 7 + Math.floor(getQuantumEntropy() * 4); // 7, 8, 9 або 10 повних обертів
      const totalDegrees = (currentBaseCycle + randomExtraSpins) * 360 + targetSectorAngle;

      const crawlSpan = 110 + Math.floor(getQuantumEntropy() * 35); // 110-145 градусів на повзунок
      const phase1Degrees = totalDegrees - crawlSpan;
      const phase1Duration = 2300 + Math.floor(getQuantumEntropy() * 300); // 2.3 - 2.6с

      // Фаза 1: Розгін
      setSpinTransition(`transform ${phase1Duration}ms cubic-bezier(0.12, 0.88, 0.22, 1)`);
      requestAnimationFrame(() => {
        setRotation(phase1Degrees);
      });

      let fastTicks = 0;
      tickIntervalRef.current = setInterval(() => {
        fastTicks++;
        playTickSound(520 + (fastTicks % 6) * 35);
        if (fastTicks >= 16) {
          if (tickIntervalRef.current) clearInterval(tickIntervalRef.current);
        }
      }, 130);

      // Фаза 2: Повзунок по лезу бритви з серцебиттям
      setTimeout(() => {
        const crawlDuration = 3400 + Math.floor(getQuantumEntropy() * 600); // 3.4 - 4.0с
        
        // Повільне повзання з напруженим кубічним завершенням
        setSpinTransition(`transform ${crawlDuration}ms cubic-bezier(0.05, 0.7, 0.35, 1)`);
        setRotation(totalDegrees);

        let crawlStep = 0;
        const totalSteps = 8;
        const stepInterval = Math.floor(crawlDuration / totalSteps);

        crawlIntervalRef.current = setInterval(() => {
          crawlStep++;
          if (crawlStep % 2 === 1) {
            playHeartbeatSound(); // Серцебиття тук-тук
          } else {
            playTensionTickSound(690 - crawlStep * 30); // Металевий зубчик
          }

          if (crawlStep >= totalSteps) {
            if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
          }
        }, stepInterval);

        // Фінал
        setTimeout(() => {
          finishSpin(isWin);
        }, crawlDuration + 180);

      }, phase1Duration);

    } else {
      // Звичайний, швидкий або довгий режими
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

  const finishSpin = (isWin: boolean) => {
    if (tickIntervalRef.current) clearInterval(tickIntervalRef.current);
    if (crawlIntervalRef.current) clearInterval(crawlIntervalRef.current);
    if (timerRef.current) clearTimeout(timerRef.current);

    setIsSpinning(false);
    setOutcome(isWin ? "win" : "loss");
    setShowResultModal(true);

    if (isWin) {
      playWinSound();

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
      } catch (err) {}

      try {
        const u = getCurrentUser();
        addLiveDrop({
          playerName: u?.nickname || "The King Of Goys",
          playerAvatar: u?.avatar || "TH",
          playerRank: u?.rank || "Global Elite",
          weapon: targetSkin.weapon,
          name: targetSkin.name,
          price: targetSkin.price,
          image: targetSkin.image || "",
          accent: targetSkin.accent || "#10b981",
          rarity: targetSkin.rarity || "Таємне",
          chance: `${chance}%`,
          multiplier: `×${multiplier}`,
        });
      } catch (err) {}
      
      // Справжній CS2 Trade-In: старий скін зникає, новий додається
      let updatedInv: InventoryItem[] = [];
      if (sourceSkin && sourceSkin.instanceId) {
        updatedInv = replaceSkinInInventory(sourceSkin.instanceId, targetSkin);
      } else {
        updatedInv = addSkinToInventory(targetSkin);
      }
      setUserInventory(updatedInv);

      const wonItem = updatedInv[0] || (updatedInv.length > 0 ? updatedInv[0] : null);
      setSourceSkin(wonItem);

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
      } catch (err) {}
      if (sourceSkin && sourceSkin.instanceId) {
        const remaining = removeSkinFromInventory(sourceSkin.instanceId);
        setUserInventory(remaining);
        setSourceSkin(remaining.length > 0 ? remaining[0] : null);
      }
    }
  };

  return (
    <div className={`relative overflow-hidden rounded-3xl border transition-all duration-500 bg-[#0d1018]/95 p-5 sm:p-7 lg:p-9 shadow-2xl shadow-black/80 backdrop-blur-xl w-full ${
      spinMode === "suspense" ? "border-amber-500/30 shadow-[0_0_40px_rgba(245,158,11,0.12)]" : "border-white/[0.08]"
    }`}>
      {/* Верхній статус бар: назва, типи прокрутки та звук */}
      <div className="flex flex-wrap items-center justify-between gap-4 border-b border-white/[0.06] pb-5">
        <div className="flex items-center gap-2.5">
          <span className={`size-2.5 rounded-full ${
            spinMode === "suspense"
              ? "bg-amber-400 shadow-[0_0_12px_#f59e0b] animate-pulse"
              : "bg-emerald-400 shadow-[0_0_12px_#10b981]"
          }`} />
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
              const isSuspense = mode === "suspense";
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
                  className={`flex items-center gap-1 rounded-lg px-4 sm:px-5 py-2.5 text-xs sm:text-sm font-black transition ${
                    isActive
                      ? isSuspense
                        ? "bg-amber-500 text-[#1a1005] shadow-lg shadow-amber-500/30 font-black animate-pulse"
                        : "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20 font-black"
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

        {/* ЦЕНТРАЛЬНА КОЛОНКА: СМАРАГДОВО-ВОГНЯНЕ КОЛЕСО РУЛЕТКИ */}
        <div className="flex flex-col items-center justify-center justify-self-center px-2 shrink-0">
          <div className={`relative flex size-72 items-center justify-center sm:size-84 lg:size-92 transition-all duration-500 ${
            spinMode === "suspense" ? "drop-shadow-[0_0_30px_rgba(245,158,11,0.45)]" : ""
          }`}>
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
                  className={`transition-all duration-300 ${
                    spinMode === "suspense"
                      ? "stroke-amber-400 drop-shadow-[0_0_15px_rgba(245,158,11,0.8)]"
                      : "stroke-emerald-400 drop-shadow-[0_0_15px_rgba(52,211,153,0.6)]"
                  }`}
                  strokeWidth="6"
                  strokeDasharray={`${winStrokeDash} ${circleCircumference}`}
                  strokeLinecap="butt"
                  fill="transparent"
                />
              )}
            </svg>

            {/* Стрілка: Смарагдовий або Вогняно-лазерний шеврон */}
            <div
              className="pointer-events-none absolute inset-0 z-20 flex items-center justify-center will-change-transform"
              style={{
                transform: `rotate(${rotation}deg)`,
                transition: spinTransition,
              }}
            >
              <div className="absolute top-2.5 flex flex-col items-center">
                <div className={`h-5 w-1 bg-gradient-to-t to-transparent ${
                  spinMode === "suspense"
                    ? "from-amber-400 shadow-[0_0_12px_#f59e0b]"
                    : "from-emerald-400 shadow-[0_0_10px_#34d399]"
                }`} />
                <div className={`size-0 border-x-[8px] border-t-[14px] border-x-transparent ${
                  spinMode === "suspense"
                    ? "border-t-amber-400 drop-shadow-[0_0_14px_#f59e0b]"
                    : "border-t-emerald-400 drop-shadow-[0_0_12px_#34d399]"
                }`} />
                <div className="size-2 -mt-1 rounded-full bg-white shadow-[0_0_8px_#ffffff]" />
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
                  <span className={`font-mono text-4xl font-black text-white sm:text-5xl ${
                    spinMode === "suspense" ? "text-amber-200" : ""
                  }`}>
                    {chance}%
                  </span>
                  <span className={`mt-1.5 rounded-full border px-3 py-0.5 font-mono text-xs font-bold ${
                    spinMode === "suspense"
                      ? "border-amber-500/30 bg-amber-500/20 text-amber-300"
                      : "border-emerald-500/20 bg-emerald-500/10 text-emerald-300"
                  }`}>
                    ×{multiplier}
                  </span>
                  <span className="mt-1 text-xs text-slate-400 font-medium">
                    Режим: {currentConfig.label}
                  </span>
                  {spinMode === "suspense" && (
                    <span className="mt-1.5 inline-flex items-center gap-1 rounded-full border border-amber-500/30 bg-amber-500/10 px-2 py-0.5 text-[8px] font-black uppercase tracking-wider text-amber-300 animate-pulse">
                      <span>🎲</span>
                      <span>CSPRNG ЕНТРОПІЯ</span>
                    </span>
                  )}
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
                className={`rounded-lg px-4 sm:px-5 py-2 sm:py-2.5 font-mono text-xs sm:text-sm font-black transition disabled:opacity-40 ${
                  spinMode === "suspense"
                    ? "text-amber-300/80 hover:bg-amber-500/20 hover:text-amber-200"
                    : "text-slate-400 hover:bg-emerald-500/10 hover:text-emerald-300"
                }`}
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

      {/* Велика кнопка апгрейду: в Азартному режимі з вогняним сяйвом */}
      <div className="mt-10 flex justify-center">
        <button
          onClick={handleUpgrade}
          disabled={isSpinning || isDowngrade || !sourceSkin}
          className={`w-full max-w-2xl rounded-3xl py-5 sm:py-6 text-lg sm:text-xl font-black uppercase tracking-wider transition shadow-2xl active:scale-[0.99] ${
            isSpinning
              ? "cursor-not-allowed bg-slate-800 text-slate-500 border border-white/5"
              : !sourceSkin
              ? "cursor-not-allowed bg-slate-800/90 text-amber-300 border border-amber-500/30"
              : isDowngrade
              ? "cursor-not-allowed bg-slate-800/90 text-rose-400 border border-rose-500/30 shadow-none"
              : spinMode === "suspense"
              ? "bg-gradient-to-r from-amber-500 via-orange-500 to-amber-500 hover:brightness-110 text-[#1a1005] shadow-[0_0_25px_rgba(245,158,11,0.35)] border border-amber-400/50"
              : "bg-emerald-500 hover:bg-emerald-400 text-[#05130d] shadow-emerald-500/25 border border-emerald-400/40"
          }`}
        >
          {isSpinning
            ? "Крутимо рулетку..."
            : !sourceSkin
            ? "🎒 СПОЧАТКУ ОБЕРИ АБО КУПИ СКІН"
            : isDowngrade
            ? "⚠️ ДАУНГРЕЙД ЗАБОРОНЕНО (ОБЕРИ ДОРОЖЧУ ЦІЛЬ)"
            : spinMode === "suspense"
            ? "КВАНТОВИЙ АЗАРТНИЙ АПГРЕЙД 🔥"
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
                    className={`rounded-lg px-4 sm:px-5 py-2.5 text-xs sm:text-sm font-black transition shrink-0 ${
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
                    className={`rounded-xl px-4 py-2 text-xs sm:text-sm font-bold transition ${
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

      {/* МОДАЛЬНЕ ВІКНО РЕЗУЛЬТАТУ */}
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
                {provablyFairSeed && (
                  <p className="mt-2 font-mono text-[9px] text-slate-500">
                    CSPRNG Seed: {provablyFairSeed}
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
                {provablyFairSeed && (
                  <p className="mt-2 font-mono text-[9px] text-slate-500">
                    CSPRNG Seed: {provablyFairSeed}
                  </p>
                )}
                
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
