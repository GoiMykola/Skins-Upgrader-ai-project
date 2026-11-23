"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { getStoredBalance, updateStoredBalance } from "@/lib/inventory-storage";
import { playWinSound } from "@/lib/sound-fx";

export default function SiteHeader() {
  const pathname = usePathname();
  const [balance, setBalance] = useState(1500);

  useEffect(() => {
    setBalance(getStoredBalance());
    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    return () => {
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
    };
  }, []);

  const handleFaucet = () => {
    playWinSound();
    const updated = updateStoredBalance(100);
    setBalance(updated);
  };

  const navLinks = [
    { href: "/", label: "Апгрейдер" },
    { href: "/catalog", label: "Каталог" },
    { href: "/market", label: "Ринок 🔥", badge: "2.2к" },
    { href: "/inventory", label: "Інвентар" },
    { href: "/leaderboard", label: "Лідери" },
  ];

  return (
    <header className="sticky top-0 z-40 border-b border-white/[0.08] bg-[#080a10]/85 backdrop-blur-xl">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        <Link href="/" className="flex items-center gap-3">
          <div className="flex size-9 items-center justify-center rounded-xl bg-gradient-to-br from-amber-400 via-orange-500 to-rose-500 font-mono text-base font-black text-[#1a1005] shadow-lg shadow-orange-500/20">
            G
          </div>
          <div className="leading-tight">
            <span className="font-mono text-sm font-black tracking-wider text-white">
              GOICOINS
            </span>
            <span className="block text-[10px] font-semibold uppercase tracking-widest text-amber-400/80">
              Skin Simulator
            </span>
          </div>
        </Link>

        <nav className="hidden md:flex items-center gap-1 rounded-2xl border border-white/[0.06] bg-black/40 p-1">
          {navLinks.map((link) => {
            const isActive = pathname === link.href;
            return (
              <Link
                key={link.href}
                href={link.href}
                className={`relative flex items-center gap-1.5 rounded-xl px-3.5 py-1.5 text-xs font-bold transition ${
                  isActive
                    ? "bg-gradient-to-r from-amber-400 to-orange-500 text-[#1a1005] shadow-md shadow-orange-500/20"
                    : "text-slate-400 hover:text-white hover:bg-white/5"
                }`}
              >
                <span>{link.label}</span>
                {link.badge && (
                  <span className={`rounded-full px-1.5 py-0.2 text-[9px] font-black ${
                    isActive ? "bg-black/20 text-[#1a1005]" : "bg-amber-400/20 text-amber-300"
                  }`}>
                    {link.badge}
                  </span>
                )}
              </Link>
            );
          })}
        </nav>

        <div className="flex items-center gap-2">
          <button
            onClick={handleFaucet}
            title="Отримати +100 безкоштовних GC"
            className="rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-2.5 py-1.5 font-mono text-xs font-black text-emerald-400 hover:bg-emerald-500/20 transition"
          >
            +100 GC
          </button>
          <div className="flex items-center gap-2 rounded-xl border border-amber-500/30 bg-amber-500/10 px-3 py-1.5">
            <span className="text-xs text-amber-400">♦</span>
            <span className="font-mono text-xs font-black text-amber-300">
              {balance.toLocaleString("uk-UA")} GC
            </span>
          </div>
        </div>
      </div>
    </header>
  );
}
