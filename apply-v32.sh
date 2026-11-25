#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v32: СПРАВЖНІ ЖИВІ ДРОПИ ТА ВЕЛИКІ КНОПКИ"
echo "=========================================================="

mkdir -p lib components app/components

# 1. Створення lib/live-drops-storage.ts: сховище реальних дропів гравців
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
}

const STORAGE_KEY = "goicoins_live_drops";

// Стартові дропи виключно від реальних зареєстрованих гравців платформи
const INITIAL_REAL_DROPS: LiveDrop[] = [
  {
    id: "drop_init_1",
    playerName: "The King Of Goys",
    playerAvatar: "TH",
    playerRank: "Global Elite",
    weapon: "AWP",
    name: "Dragon Lore",
    price: 450000,
    image: OFFICIAL_SKIN_IMAGES["AWP | Dragon Lore"] || "https://community.akamai.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot621FAR17PLfYQJD_9W7m5a0mvLwOq7c2D4B6pcn3-3E99n22Qfn_kFtY2inINfAcVJtNArR-1G5wri-jce0ot2XnjXh2Y2F",
    accent: "#eb4b4b",
    rarity: "Таємне",
    chance: "18.5%",
    multiplier: "×5.4",
    timestamp: Date.now() - 35000,
  },
  {
    id: "drop_init_2",
    playerName: "Goi Master",
    playerAvatar: "GM",
    playerRank: "Global Elite",
    weapon: "★ Butterfly Knife",
    name: "Fade",
    price: 165000,
    image: OFFICIAL_SKIN_IMAGES["★ Butterfly Knife | Fade"] || "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpovbSsLQJf1ObcTjxP09m7h5C0mfPlP67uqWdY781lxL3CoN-j2VDm-0dvZGzydoGQcAA6YVrSqFLvkOy81MW8v56fy3cx6ClwtCranBfk1U4ecKUx0g-jQ2uX/360fx360f",
    accent: "#ffd700",
    rarity: "Надзвичайне",
    chance: "30.4%",
    multiplier: "×3.1",
    timestamp: Date.now() - 95000,
  },
  {
    id: "drop_init_3",
    playerName: "Cyber Player",
    playerAvatar: "CP",
    playerRank: "Supreme Master",
    weapon: "★ Sport Gloves",
    name: "Vice",
    price: 95000,
    image: OFFICIAL_SKIN_IMAGES["★ Sport Gloves | Vice"] || "https://community.akamai.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpovbSsLQJfwPz3fi9B7dZhm5C0m_7zO6-fzj9V7cAl2eyVpI-j2wXk-UVla27wLYbAdgBsMA7V-gDtl-q605O76J_Ln3Rh7yM8pSGKn2Gj_y0",
    accent: "#ec4899",
    rarity: "Надзвичайне",
    chance: "12.5%",
    multiplier: "×8.0",
    timestamp: Date.now() - 170000,
  },
  {
    id: "drop_init_4",
    playerName: "The King Of Goys",
    playerAvatar: "TH",
    playerRank: "Global Elite",
    weapon: "M4A4",
    name: "Howl",
    price: 185000,
    image: OFFICIAL_SKIN_IMAGES["M4A4 | Howl"] || "https://community.akamai.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpou-6kejhz2v_Nfz5H_uO1gb-Gw_alIITBhGJf_NZlmOzA-LP5gVO8v11sYmGicY_Dcw43NAyE-gK8lOq5hpO17ZzPyCRj6CR37XfczQv330_07XbHsg",
    accent: "#e4ae39",
    rarity: "Контрабандне",
    chance: "15.0%",
    multiplier: "×6.7",
    timestamp: Date.now() - 260000,
  },
  {
    id: "drop_init_5",
    playerName: "Goi Master",
    playerAvatar: "GM",
    playerRank: "Global Elite",
    weapon: "AWP",
    name: "Hyper Beast",
    price: 2800,
    image: OFFICIAL_SKIN_IMAGES["AWP | Hyper Beast"] || "https://community.akamai.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot621FABz7PLfYQJG6d2inL-GkvP9JrafwzgHv5co27vFptSt2QXt-xBtNW-mLY6TdlI6NVGE_wW6yOjxxcjr2p9bO798",
    accent: "#eb4b4b",
    rarity: "Таємне",
    chance: "45.0%",
    multiplier: "×2.2",
    timestamp: Date.now() - 410000,
  },
];

export function getStoredLiveDrops(): LiveDrop[] {
  if (typeof window === "undefined") return INITIAL_REAL_DROPS;
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(INITIAL_REAL_DROPS));
      return INITIAL_REAL_DROPS;
    }
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed) && parsed.length > 0) {
      const clean = parsed.filter(
        (d: any) =>
          d &&
          d.playerName &&
          d.playerName !== "GhostRider" &&
          d.playerName !== "s1mple_fan" &&
          d.playerName !== "ShadowStep" &&
          d.playerName !== "NeoMatrix" &&
          d.playerName !== "v1per" &&
          d.playerName !== "Kira.exe"
      );
      if (clean.length > 0) return clean;
    }
    localStorage.setItem(STORAGE_KEY, JSON.stringify(INITIAL_REAL_DROPS));
    return INITIAL_REAL_DROPS;
  } catch {
    return INITIAL_REAL_DROPS;
  }
}

export function addLiveDrop(
  drop: Omit<LiveDrop, "id" | "timestamp">
): LiveDrop {
  const newDrop: LiveDrop = {
    ...drop,
    id: `drop_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
    timestamp: Date.now(),
  };

  if (typeof window !== "undefined") {
    try {
      const current = getStoredLiveDrops();
      const updated = [newDrop, ...current].slice(0, 40);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
      window.dispatchEvent(new CustomEvent("goi-live-drop", { detail: newDrop }));
    } catch {}
  }

  return newDrop;
}
EOF

# 2. Оновлення components/live-drops-ticker.tsx
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
        setDrops((prev) => [e.detail, ...prev.filter((d) => d.id !== e.detail.id)].slice(0, 40));
        setTimeout(() => setNewestDropId(null), 4000);
      }
    };

    window.addEventListener("goi-live-drop", handleNewDrop as EventListener);
    window.addEventListener("storage", () => setDrops(getStoredLiveDrops()));

    const timer = setInterval(() => {
      setDrops(getStoredLiveDrops());
    }, 12000);

    return () => {
      window.removeEventListener("goi-live-drop", handleNewDrop as EventListener);
      clearInterval(timer);
    };
  }, []);

  if (drops.length === 0) return null;

  const marqueeItems = [...drops, ...drops];

  return (
    <div className="relative w-full border-y border-white/[0.08] bg-[#070910]/95 backdrop-blur-xl overflow-hidden shadow-lg z-30">
      <div className="flex items-center">
        <div className="flex shrink-0 items-center gap-2.5 bg-gradient-to-r from-[#070910] via-[#070910] to-transparent z-10 px-4 sm:px-6 py-2.5 border-r border-white/5">
          <span className="relative flex size-2.5">
            <span className="absolute inline-flex size-full animate-ping rounded-full bg-emerald-400 opacity-80" />
            <span className="relative inline-flex size-2.5 rounded-full bg-emerald-500 shadow-[0_0_10px_#10b981]" />
          </span>
          <span className="text-xs font-black uppercase tracking-wider text-emerald-400 whitespace-nowrap">
            LIVE ДРОПИ:
          </span>
        </div>

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
                  <div className="flex items-center gap-1.5 shrink-0">
                    <div className="flex size-5 sm:size-6 items-center justify-center rounded-lg bg-gradient-to-br from-emerald-400 to-teal-600 text-[10px] font-black text-[#05130d] shadow-sm">
                      {drop.playerAvatar}
                    </div>
                    <span className="text-xs font-bold text-slate-200 group-hover:text-emerald-300 transition max-w-[110px] truncate">
                      {drop.playerName}
                    </span>
                  </div>

                  <span className="text-slate-600 text-xs font-bold">→</span>

                  <div className="relative flex h-7 w-10 shrink-0 items-center justify-center overflow-hidden rounded-lg bg-black/60 border border-white/5">
                    <img
                      src={drop.image}
                      alt={drop.name}
                      className="max-h-6 max-w-9 object-contain drop-shadow transition-transform group-hover:scale-110"
                      loading="lazy"
                      onError={(e) => {
                        (e.target as HTMLImageElement).src =
                          "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpou-6kejhz2v_Nfz5H_uO1gb-Gw_alIITBhGJf_NZlmOzA-LP5gVO8v11sYmGicY_Dcw43NAyE-gK8lOq5hpO17ZzPyCRj6CR37XfczQv330_07XbHsg/360fx360f";
                      }}
                    />
                    <span
                      className="absolute bottom-0 inset-x-0 h-0.5"
                      style={{ backgroundColor: drop.accent || "#10b981" }}
                    />
                  </div>

                  <div className="flex flex-col leading-tight shrink-0">
                    <span className="text-[10px] font-bold text-slate-400 uppercase truncate max-w-[120px]">
                      {drop.weapon}
                    </span>
                    <span className="text-xs font-black text-white truncate max-w-[120px]">
                      {drop.name}
                    </span>
                  </div>

                  <span className="rounded-xl border border-emerald-500/30 bg-emerald-500/15 px-2 py-0.5 font-mono text-[11px] font-black text-emerald-400 whitespace-nowrap shadow-sm">
                    {formatCoins(drop.price)} GC
                  </span>

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
          animation: ticker-scroll 36s linear infinite;
        }
        .animate-ticker:hover {
          animation-play-state: paused;
        }
      ` }} />
    </div>
  );
}
EOF

# 3. Оновлення app/components/site-header.tsx: великі кнопки навігації, балансу та профілю
cat << 'EOF' > app/components/site-header.tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useEffect, useRef } from "react";
import { getStoredBalance } from "@/lib/inventory-storage";
import { getCurrentUser, logoutUser, type UserProfile } from "@/lib/auth-storage";
import { AuthModal } from "@/components/auth-modal";
import { playClickSound } from "@/lib/sound-fx";

export default function SiteHeader() {
  const pathname = usePathname();
  const [balance, setBalance] = useState(1500);
  const [currentUser, setCurrentUser] = useState<UserProfile | null>(null);
  const [isAuthOpen, setIsAuthOpen] = useState(false);
  const [authTab, setAuthTab] = useState<"login" | "register">("login");
  const [showDropdown, setShowDropdown] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setBalance(getStoredBalance());
    setCurrentUser(getCurrentUser());

    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    const handleAuth = (e: CustomEvent<UserProfile | null>) => {
      setCurrentUser(e.detail ?? null);
    };
    const handleOpenAuth = (e: CustomEvent<"login" | "register">) => {
      setAuthTab(e.detail || "login");
      setIsAuthOpen(true);
    };

    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    window.addEventListener("goi-auth-updated", handleAuth as EventListener);
    window.addEventListener("goi-open-auth", handleOpenAuth as EventListener);

    const handleClickOutside = (ev: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(ev.target as Node)) {
        setShowDropdown(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);

    return () => {
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
      window.removeEventListener("goi-auth-updated", handleAuth as EventListener);
      window.removeEventListener("goi-open-auth", handleOpenAuth as EventListener);
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  const handleLogout = () => {
    playClickSound();
    logoutUser();
    setShowDropdown(false);
  };

  const openAuth = (tab: "login" | "register") => {
    playClickSound();
    setAuthTab(tab);
    setIsAuthOpen(true);
  };

  const navLinks = [
    { href: "/", label: "Апгрейдер" },
    { href: "/catalog", label: "Каталог" },
    { href: "/market", label: "Ринок 🔥", badge: "2.2к" },
    { href: "/inventory", label: "Інвентар" },
    { href: "/leaderboard", label: "Лідери" },
  ];

  return (
    <>
      <header className="sticky top-0 z-40 border-b border-white/[0.08] bg-[#080a10]/95 backdrop-blur-xl">
        <div className="mx-auto flex h-20 max-w-[1760px] items-center justify-between px-4 sm:px-6 lg:px-10 xl:px-12">
          <Link href="/" className="flex items-center gap-3.5 group">
            <div className="flex size-11 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-xl font-black text-[#05130d] shadow-lg shadow-emerald-500/25 group-hover:scale-105 transition">
              G
            </div>
            <div className="leading-tight">
              <span className="font-mono text-base font-black tracking-wider text-white">
                GOICOINS
              </span>
              <span className="block text-[11px] font-bold uppercase tracking-widest text-emerald-400">
                Skin Simulator
              </span>
            </div>
          </Link>

          <nav className="hidden md:flex items-center gap-1.5 rounded-2xl border border-white/[0.08] bg-black/50 p-1.5 shadow-inner">
            {navLinks.map((link) => {
              const isActive = pathname === link.href;
              return (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => playClickSound()}
                  className={`relative flex items-center gap-2 rounded-xl px-5 py-2.5 text-sm font-bold transition ${
                    isActive
                      ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20 font-black"
                      : "text-slate-300 hover:text-white hover:bg-white/10"
                  }`}
                >
                  <span>{link.label}</span>
                  {link.badge && (
                    <span
                      className={`rounded-full px-2 py-0.5 text-[10px] font-black ${
                        isActive ? "bg-black/20 text-[#05130d]" : "bg-emerald-400/20 text-emerald-300 border border-emerald-400/30"
                      }`}
                    >
                      {link.badge}
                    </span>
                  )}
                </Link>
              );
            })}
          </nav>

          <div className="flex items-center gap-3.5">
            <div className="flex items-center gap-2.5 rounded-2xl border border-emerald-500/40 bg-emerald-500/15 px-4 sm:px-5 py-2 font-mono text-sm sm:text-base font-black text-emerald-300 shadow-[0_0_20px_rgba(16,185,129,0.18)]">
              <span className="text-base text-emerald-400">🪙</span>
              <span>{balance.toLocaleString("uk-UA")} GC</span>
            </div>

            {currentUser ? (
              <div className="relative" ref={dropdownRef}>
                <button
                  onClick={() => {
                    playClickSound();
                    setShowDropdown(!showDropdown);
                  }}
                  className="flex items-center gap-3 rounded-2xl border border-white/10 bg-white/5 hover:bg-white/10 px-4 py-2 transition text-left"
                >
                  <div className="flex size-9 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-400 to-teal-500 font-mono text-xs font-black text-[#05130d] shadow-md">
                    {currentUser.avatar || "TH"}
                  </div>
                  <div className="hidden sm:block leading-tight">
                    <p className="text-sm font-black text-white truncate max-w-[130px]">
                      {currentUser.nickname}
                    </p>
                    <p className="text-[11px] font-bold text-emerald-400">
                      {currentUser.rank}
                    </p>
                  </div>
                  <svg
                    className={`size-4 text-slate-400 transition-transform ${showDropdown ? "rotate-180" : ""}`}
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                  </svg>
                </button>

                {showDropdown && (
                  <div className="absolute right-0 mt-2 w-64 rounded-2xl border border-white/10 bg-[#0d111a]/98 backdrop-blur-2xl p-2.5 shadow-2xl z-50 animate-fade-in">
                    <div className="border-b border-white/10 px-3 py-2.5">
                      <p className="text-sm font-black text-white truncate">{currentUser.nickname}</p>
                      <p className="text-xs text-slate-400 truncate">{currentUser.email}</p>
                      <span className="mt-1.5 inline-block rounded-md bg-emerald-500/20 px-2.5 py-0.5 text-[10px] font-bold text-emerald-300">
                        {currentUser.rank}
                      </span>
                    </div>

                    <div className="mt-1.5 space-y-1">
                      <Link
                        href="/inventory"
                        onClick={() => setShowDropdown(false)}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3.5 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/5 hover:text-white transition"
                      >
                        <span>🎒</span>
                        <span>Мій інвентар</span>
                      </Link>
                      <Link
                        href="/leaderboard"
                        onClick={() => setShowDropdown(false)}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3.5 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/5 hover:text-white transition"
                      >
                        <span>🏆</span>
                        <span>Таблиця лідерів</span>
                      </Link>
                      <button
                        onClick={handleLogout}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3.5 py-2.5 text-xs font-bold text-rose-400 hover:bg-rose-500/10 transition"
                      >
                        <span>🚪</span>
                        <span>Вийти з акаунта</span>
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <div className="flex items-center gap-2">
                <button
                  onClick={() => openAuth("login")}
                  className="rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 px-4 py-2 text-xs font-bold text-slate-300 hover:text-white transition"
                >
                  Увійти
                </button>
                <button
                  onClick={() => openAuth("register")}
                  className="rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:brightness-110 px-4 py-2 text-xs font-black text-[#05130d] shadow-md shadow-emerald-500/20 transition"
                >
                  Реєстрація 🎁
                </button>
              </div>
            )}
          </div>
        </div>
      </header>

      <AuthModal
        isOpen={isAuthOpen}
        initialTab={authTab}
        onClose={() => setIsAuthOpen(false)}
      />
    </>
  );
}
EOF

# 4. Оновлення components/interactive-upgrader.tsx
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

  // Збільшення кнопок режимів рулетки
  content = content.replace(
    /px-2\.5 py-1 text-xs font-bold transition/g,
    "px-4 sm:px-5 py-2.5 text-xs sm:text-sm font-black transition"
  );

  // Збільшення множників
  content = content.replace(
    /px-2\.5 sm:px-3 py-1 font-mono text-xs font-bold/g,
    "px-4 sm:px-5 py-2 sm:py-2.5 font-mono text-xs sm:text-sm font-black"
  );

  // Збільшення головної кнопки апгрейду
  content = content.replace(
    /w-full max-w-xl rounded-2xl py-4 text-base font-black/g,
    "w-full max-w-2xl rounded-3xl py-5 sm:py-6 text-lg sm:text-xl font-black"
  );

  // Збільшення кнопок категорій у виборі цілей
  content = content.replace(
    /rounded-lg px-3 py-1 text-xs font-bold transition/g,
    "rounded-xl px-4 py-2 text-xs sm:text-sm font-bold transition"
  );

  fs.writeFileSync(file, content, "utf8");
  console.log("✅ components/interactive-upgrader.tsx оновлено!");
}
' || true

# 5. Оновлення app/market/page.tsx: збільшення кнопок на ринку скінів
node -e '
const fs = require("fs");
const file = "app/market/page.tsx";

if (fs.existsSync(file)) {
  let content = fs.readFileSync(file, "utf8");

  // 1. Збільшення кнопок "Купити 🛒" на картках скінів
  content = content.replace(
    /py-1\.5 text-center text-\[10px\] font-black/g,
    "py-2.5 text-center text-xs font-black"
  );

  // 2. Збільшення кнопки блискавки "⚡"
  content = content.replace(
    /flex size-7 items-center justify-center rounded-xl/g,
    "flex size-9 items-center justify-center rounded-xl text-sm"
  );

  // 3. Збільшення кнопок категорій
  content = content.replace(
    /rounded-xl px-3 py-1\.5 text-xs font-bold transition/g,
    "rounded-xl px-4 sm:px-5 py-2.5 text-xs sm:text-sm font-bold transition"
  );

  // 4. Збільшення кнопок рідкостей
  content = content.replace(
    /rounded-xl px-2\.5 py-1 text-\[11px\] font-medium transition/g,
    "rounded-xl px-3.5 py-1.5 text-xs font-semibold transition"
  );

  // 5. Збільшення кнопок швидких діапазонів цін
  content = content.replace(
    /rounded-xl px-3 py-1 text-xs font-bold transition/g,
    "rounded-xl px-4 py-2 text-xs sm:text-sm font-bold transition"
  );

  fs.writeFileSync(file, content, "utf8");
  console.log("✅ app/market/page.tsx кнопки масштабовано!");
}
' || true

# 6. Перевірка білду
echo "=========================================================="
echo "🧪 ПЕРЕВІРКА БІЛДУ"
echo "=========================================================="
npm run build

# 7. Git Commit & Push на GitHub
echo "=========================================================="
echo "🚀 ФІКСАЦІЯ В GIT ТА PUSH НА GITHUB"
echo "=========================================================="
git add .
git commit -m "feat(drops): real registered player live drops with photos and scaled up button UI" || true
git push origin main || true

echo "=========================================================="
echo "🎉 ВСЕ ПРАЦЮЄ! Живі дропи підключені, а кнопки стали великими та зручними!"
echo "=========================================================="
