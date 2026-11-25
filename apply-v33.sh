#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v33: 100% ПРАВДИВІ ДРОПИ ТА ОЧИЩЕННЯ ВІД ФЕЙКІВ"
echo "=========================================================="

mkdir -p lib components

# 1. lib/live-drops-storage.ts: суворо тільки 100% реальні виграші гравця
cat << 'EOF' > lib/live-drops-storage.ts
"use client";

import { OFFICIAL_SKIN_IMAGES } from "./inventory-storage";

export interface LiveDrop {
  id: string;
  playerName: string;
  playerAvatar: string;
  playerRank?: string;
  weapon: string;
  name: string;
  price: number;
  image: string;
  accent: string;
  rarity: string;
  chance: string;
  multiplier: string;
  timestamp: number;
  isRealWin: boolean;
}

const STORAGE_KEY = "goicoins_live_drops_v2";

/**
 * 100% ПРАВДИВІ ДРОПИ:
 * Ніяких вигаданих чи стартових сідів (порожній масив за замовчуванням).
 * Якщо гравець ще нічого не виграв — стрічка порожня і не відображається.
 */
export function getStoredLiveDrops(): LiveDrop[] {
  if (typeof window === "undefined") return [];
  try {
    // Одноразово очищаємо старий ключ з v32, який містив стартові сіди
    if (localStorage.getItem("goicoins_live_drops")) {
      localStorage.removeItem("goicoins_live_drops");
    }

    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];

    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];

    // Суворо відфільтровуємо лише реальні виграші
    const realOnly = parsed.filter(
      (d: any) =>
        d &&
        typeof d === "object" &&
        (d.isRealWin === true || (typeof d.id === "string" && d.id.startsWith("real_win_"))) &&
        d.weapon &&
        d.name &&
        typeof d.price === "number"
    );

    if (realOnly.length !== parsed.length) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(realOnly));
    }

    return realOnly;
  } catch {
    return [];
  }
}

export function addLiveDrop(
  drop: Omit<LiveDrop, "id" | "timestamp" | "isRealWin">
): LiveDrop {
  let skinImage = drop.image;
  if (!skinImage || skinImage.trim() === "") {
    const fullName = `${drop.weapon} | ${drop.name}`;
    skinImage =
      OFFICIAL_SKIN_IMAGES[fullName] ||
      OFFICIAL_SKIN_IMAGES[drop.name] ||
      "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot621FAR17PLfYQJD_9W7m5a0mvLwOq7c2D4B6pcn3-3E99n22Qfn_kFtY2inINfAcVJtNArR-1G5wri-jce0ot2XnjXh2Y2F";
  }

  const newDrop: LiveDrop = {
    ...drop,
    image: skinImage,
    id: `real_win_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
    timestamp: Date.now(),
    isRealWin: true,
  };

  if (typeof window !== "undefined") {
    try {
      const current = getStoredLiveDrops();
      const updated = [newDrop, ...current].slice(0, 50);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
      window.dispatchEvent(new CustomEvent("goi-live-drop", { detail: newDrop }));
    } catch {}
  }

  return newDrop;
}

export function clearLiveDrops(): void {
  if (typeof window !== "undefined") {
    try {
      localStorage.removeItem(STORAGE_KEY);
      localStorage.removeItem("goicoins_live_drops");
      window.dispatchEvent(new CustomEvent("goi-live-drop-cleared"));
    } catch {}
  }
}
EOF

# 2. components/live-drops-ticker.tsx: показує тільки реальні дропи, при 0 дропах не показується взагалі
cat << 'EOF' > components/live-drops-ticker.tsx
"use client";

/* eslint-disable @next/next/no-img-element */
import { useState, useEffect } from "react";
import Link from "next/link";
import { formatCoins } from "@/app/data";
import { getStoredLiveDrops, type LiveDrop } from "@/lib/live-drops-storage";
import { playClickSound } from "@/lib/sound-fx";

function formatTimeAgo(timestamp: number): string {
  const diffSec = Math.max(1, Math.floor((Date.now() - timestamp) / 1000));
  if (diffSec < 10) return "щойно ⚡";
  if (diffSec < 60) return `${diffSec}с тому`;
  const diffMin = Math.floor(diffSec / 60);
  if (diffMin < 60) return `${diffMin}хв тому`;
  const diffHours = Math.floor(diffMin / 60);
  return `${diffHours}год тому`;
}

export function LiveDropsTicker() {
  const [drops, setDrops] = useState<LiveDrop[]>([]);
  const [newestDropId, setNewestDropId] = useState<string | null>(null);

  useEffect(() => {
    setDrops(getStoredLiveDrops());

    const handleNewDrop = (e: CustomEvent<LiveDrop>) => {
      if (e.detail) {
        setNewestDropId(e.detail.id);
        setDrops((prev) => [e.detail, ...prev.filter((d) => d.id !== e.detail.id)].slice(0, 50));
        setTimeout(() => setNewestDropId(null), 4000);
      }
    };

    const handleCleared = () => {
      setDrops([]);
    };

    window.addEventListener("goi-live-drop", handleNewDrop as EventListener);
    window.addEventListener("goi-live-drop-cleared", handleCleared as EventListener);
    window.addEventListener("storage", () => setDrops(getStoredLiveDrops()));

    const timer = setInterval(() => {
      setDrops(getStoredLiveDrops());
    }, 10000);

    return () => {
      window.removeEventListener("goi-live-drop", handleNewDrop as EventListener);
      window.removeEventListener("goi-live-drop-cleared", handleCleared as EventListener);
      clearInterval(timer);
    };
  }, []);

  // Якщо користувач ще нічого не виграв — стрічка не показується взагалі (100% чесно)
  if (drops.length === 0) return null;

  // Повторюємо елементи, щоб біжуча лінія плавно крутилася на будь-якій ширині екрана
  const repeatMultiplier = Math.max(2, Math.ceil(12 / drops.length));
  const marqueeItems = Array(repeatMultiplier).fill(drops).flat();

  return (
    <div className="relative w-full border-y border-white/[0.08] bg-[#070910]/95 backdrop-blur-xl overflow-hidden shadow-lg z-30 animate-fade-in">
      <div className="flex items-center">
        {/* Фіксований неоновий бейдж LIVE ДРОПИ зліва */}
        <div className="flex shrink-0 items-center gap-2.5 bg-gradient-to-r from-[#070910] via-[#070910] to-transparent z-10 px-4 sm:px-6 py-2.5 border-r border-white/5">
          <span className="relative flex size-2.5">
            <span className="absolute inline-flex size-full animate-ping rounded-full bg-emerald-400 opacity-80" />
            <span className="relative inline-flex size-2.5 rounded-full bg-emerald-500 shadow-[0_0_10px_#10b981]" />
          </span>
          <span className="text-xs font-black uppercase tracking-wider text-emerald-400 whitespace-nowrap">
            LIVE ДРОПИ ({drops.length}):
          </span>
        </div>

        {/* Анімована нескінченна стрічка з реальними виграшами */}
        <div className="relative flex-1 overflow-hidden py-1.5">
          <div className="animate-ticker flex items-center gap-3 w-max">
            {marqueeItems.map((drop, idx) => {
              const isNew = drop.id === newestDropId;
              return (
                <Link
                  key={`drop-${drop.id}-${idx}`}
                  href="/"
                  onClick={() => playClickSound()}
                  title={`Гравець ${drop.playerName} виграв ${drop.weapon} | ${drop.name} (${drop.chance}, ${drop.multiplier})`}
                  className={`group relative flex shrink-0 items-center gap-2.5 rounded-2xl border px-3 py-1.5 transition-all duration-300 hover:scale-[1.03] hover:z-20 ${
                    isNew
                      ? "border-emerald-400 bg-emerald-500/20 shadow-[0_0_20px_rgba(16,185,129,0.4)] animate-pulse"
                      : "border-white/[0.08] bg-white/[0.025] hover:border-emerald-400/50 hover:bg-emerald-500/10"
                  }`}
                >
                  {/* Гравець: аватар + нікнейм */}
                  <div className="flex items-center gap-1.5 shrink-0">
                    <div className="flex size-5 sm:size-6 items-center justify-center rounded-lg bg-gradient-to-br from-emerald-400 to-teal-600 text-[10px] font-black text-[#05130d] shadow-sm">
                      {drop.playerAvatar || "TH"}
                    </div>
                    <span className="text-xs font-bold text-slate-200 group-hover:text-emerald-300 transition max-w-[120px] truncate">
                      {drop.playerName}
                    </span>
                  </div>

                  <span className="text-slate-600 text-xs font-bold">→</span>

                  {/* Офіційне фото скіна CS2 */}
                  <div className="relative flex h-7 w-10 shrink-0 items-center justify-center overflow-hidden rounded-lg bg-black/60 border border-white/5">
                    <img
                      src={drop.image}
                      alt={drop.name}
                      className="max-h-6 max-w-9 object-contain drop-shadow transition-transform group-hover:scale-110"
                      loading="lazy"
                      onError={(e) => {
                        const target = e.currentTarget;
                        if (!target.dataset.fallback) {
                          target.dataset.fallback = "1";
                          target.src = "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpou-6kejhz2v_Nfz5H_uO1gb-Gw_alIITBhGJf_NZlmOzA-LP5gVO8v11sYmGicY_Dcw43NAyE-gK8lOq5hpO17ZzPyCRj6CR37XfczQv330_07XbHsg/360fx360f";
                        }
                      }}
                    />
                    <span
                      className="absolute bottom-0 inset-x-0 h-0.5"
                      style={{ backgroundColor: drop.accent || "#10b981" }}
                    />
                  </div>

                  {/* Назва скіна */}
                  <div className="flex flex-col leading-tight shrink-0">
                    <span className="text-[10px] font-bold text-slate-400 uppercase truncate max-w-[120px]">
                      {drop.weapon}
                    </span>
                    <span className="text-xs font-black text-white truncate max-w-[130px]">
                      {drop.name}
                    </span>
                  </div>

                  {/* Ціна скіна */}
                  <span className="rounded-xl border border-emerald-500/30 bg-emerald-500/15 px-2 py-0.5 font-mono text-[11px] font-black text-emerald-400 whitespace-nowrap shadow-sm">
                    {formatCoins(drop.price)} GC
                  </span>

                  {/* Множник та час */}
                  <span className="text-[10px] font-bold text-slate-400 whitespace-nowrap">
                    {drop.multiplier} · {formatTimeAgo(drop.timestamp)}
                  </span>
                </Link>
              );
            })}
          </div>
        </div>
      </div>

      <style dangerouslySetInnerHTML={{ __html: `
        @keyframes ticker-scroll {
          0% {
            transform: translateX(0);
          }
          100% {
            transform: translateX(-50%);
          }
        }
        .animate-ticker {
          display: flex;
          animation: ticker-scroll 32s linear infinite;
        }
        .animate-ticker:hover {
          animation-play-state: paused;
        }
      ` }} />
    </div>
  );
}
EOF

# 3. Перевірка та оновлення components/interactive-upgrader.tsx
node -e '
const fs = require("fs");
const file = "components/interactive-upgrader.tsx";

if (fs.existsSync(file)) {
  let content = fs.readFileSync(file, "utf8");

  if (!content.includes("addLiveDrop")) {
    content = content.replace(
      /from ["\x27]@\/app\/data["\x27];/,
      "from \"@/app/data\";\nimport { addLiveDrop } from \"@/lib/live-drops-storage\";\nimport { getCurrentUser } from \"@/lib/auth-storage\";"
    );
  }

  if (!content.includes("addLiveDrop({")) {
    content = content.replace(
      "playWinSound();",
      `playWinSound();

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
          chance: \x60\${chance}%\x60,
          multiplier: \x60×\${multiplier}\x60,
        });
      } catch (err) {}`
    );
  }

  fs.writeFileSync(file, content, "utf8");
  console.log("✅ components/interactive-upgrader.tsx перевірено!");
}
' || true

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
git commit -m "fix(drops): strictly 100% real player upgrade drops with auto-hide when empty" || true
git push origin main || true

echo "=========================================================="
echo "🎉 ГОТОВО! Жодних вигаданих предметів — стрічка на 100% правдива!"
echo "=========================================================="
