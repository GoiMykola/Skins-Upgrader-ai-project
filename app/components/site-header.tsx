"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { playClickSound, playCoinSound } from "@/lib/sound-fx";

const navigation = [
  { href: "/", label: "Апгрейдер" },
  { href: "/catalog", label: "Каталог" },
  { href: "/inventory", label: "Інвентар" },
  { href: "/leaderboard", label: "Лідери" },
];

export default function SiteHeader() {
  const pathname = usePathname();
  const [balance, setBalance] = useState(1000);
  const [coinAnim, setCoinAnim] = useState(false);

  const handleClaimBonus = () => {
    playCoinSound();
    setBalance((prev) => prev + 100);
    setCoinAnim(true);
    setTimeout(() => setCoinAnim(false), 800);
  };

  return (
    <header className="sticky top-0 z-40 border-b border-white/[0.08] bg-[#090b10]/95 backdrop-blur-xl">
      <div className="mx-auto flex max-w-7xl items-center justify-between gap-4 px-4 py-3.5 sm:px-6 lg:px-8">
        <Link
          href="/"
          onClick={() => playClickSound()}
          className="flex shrink-0 items-center gap-3 group"
          aria-label="GoiCoins Skin Simulator — головна"
        >
          <span className="flex size-10 items-center justify-center rounded-xl bg-gradient-to-br from-amber-300 via-orange-400 to-rose-500 text-lg font-black text-[#1a1006] shadow-lg shadow-orange-500/20 transition group-hover:scale-105">
            G
          </span>
          <span className="hidden sm:block leading-tight">
            <span className="block text-sm font-black tracking-wide text-white">GOICOINS</span>
            <span className="block text-[9px] font-bold uppercase tracking-[0.2em] text-slate-400">
              Skin simulator
            </span>
          </span>
        </Link>

        <nav className="flex items-center gap-1 rounded-xl border border-white/[0.06] bg-white/[0.03] p-1">
          {navigation.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => playClickSound()}
                className={`rounded-lg px-3 py-1.5 text-xs font-bold transition sm:px-4 sm:text-sm ${
                  isActive
                    ? "bg-gradient-to-r from-amber-400/20 to-orange-400/20 text-amber-300 border border-amber-400/30"
                    : "text-slate-400 hover:bg-white/[0.06] hover:text-white"
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>

        <div className="flex items-center gap-2">
          <button
            onClick={handleClaimBonus}
            className="hidden sm:flex items-center gap-1.5 rounded-xl border border-emerald-400/30 bg-emerald-400/10 px-3 py-1.5 text-xs font-bold text-emerald-300 hover:bg-emerald-400/20 transition"
            title="Отримати щоденний бонус +100 GC"
          >
            +100 GC
          </button>

          <Link
            href="/inventory"
            onClick={() => playClickSound()}
            className="relative flex items-center gap-2 rounded-xl border border-amber-300/25 bg-amber-400/10 px-3.5 py-1.5 text-sm font-black text-amber-300 transition hover:bg-amber-400/20"
          >
            <span>◆</span>
            <span>{balance.toLocaleString("uk-UA")} GC</span>
            {coinAnim && (
              <span className="absolute -top-3 right-0 animate-bounce text-xs font-bold text-emerald-400">
                +100!
              </span>
            )}
          </Link>
        </div>
      </div>
    </header>
  );
}
