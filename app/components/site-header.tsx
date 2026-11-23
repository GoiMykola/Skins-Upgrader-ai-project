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
      <header className="sticky top-0 z-40 border-b border-white/[0.08] bg-[#080a10]/90 backdrop-blur-xl">
        <div className="mx-auto flex h-16 max-w-[1760px] items-center justify-between px-4 sm:px-6 lg:px-10 xl:px-12">
          <Link href="/" className="flex items-center gap-3">
            <div className="flex size-9 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-base font-black text-[#05130d] shadow-lg shadow-emerald-500/20">
              G
            </div>
            <div className="leading-tight">
              <span className="font-mono text-sm font-black tracking-wider text-white">
                GOICOINS
              </span>
              <span className="block text-[10px] font-semibold uppercase tracking-widest text-emerald-400">
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
                  className={`relative flex items-center gap-1.5 rounded-xl px-4 py-1.5 text-xs font-bold transition ${
                    isActive
                      ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20 font-black"
                      : "text-slate-400 hover:text-white hover:bg-white/5"
                  }`}
                >
                  <span>{link.label}</span>
                  {link.badge && (
                    <span
                      className={`rounded-full px-1.5 py-0.2 text-[9px] font-black ${
                        isActive ? "bg-black/20 text-[#05130d]" : "bg-emerald-400/20 text-emerald-300"
                      }`}
                    >
                      {link.badge}
                    </span>
                  )}
                </Link>
              );
            })}
          </nav>

          <div className="flex items-center gap-3">
            <div className="flex items-center rounded-xl border border-emerald-500/30 bg-emerald-500/10 p-1 font-mono text-xs font-black text-emerald-300 shadow-[0_0_15px_rgba(16,185,129,0.15)]">
              <div className="flex items-center gap-1.5 px-2.5 py-0.5">
                <span className="text-emerald-400">🪙</span>
                <span>{balance.toLocaleString("uk-UA")} GC</span>
              </div>
              <Link
                href="/topup"
                title="Поповнити баланс (+)"
                className="flex size-6 items-center justify-center rounded-lg bg-emerald-500 hover:bg-emerald-400 text-[#05130d] font-black text-sm shadow shadow-emerald-500/30 hover:scale-105 active:scale-95 transition ml-1"
              >
                +
              </Link>
            </div>

            {currentUser ? (
              <div className="relative" ref={dropdownRef}>
                <button
                  onClick={() => setShowDropdown(!showDropdown)}
                  className="flex items-center gap-2.5 rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 px-3 py-1.5 transition text-left"
                >
                  <div className="flex size-7 items-center justify-center rounded-lg bg-gradient-to-br from-emerald-400 to-teal-500 font-mono text-xs font-black text-[#05130d]">
                    {currentUser.avatar || "GM"}
                  </div>
                  <div className="hidden sm:block leading-tight">
                    <p className="text-xs font-black text-white truncate max-w-[120px]">
                      {currentUser.nickname}
                    </p>
                    <p className="text-[10px] font-semibold text-emerald-400">
                      {currentUser.rank}
                    </p>
                  </div>
                  <span className="text-slate-400 text-xs">▼</span>
                </button>

                {showDropdown && (
                  <div className="absolute right-0 mt-2 w-56 rounded-2xl border border-white/10 bg-[#0d111a]/95 backdrop-blur-2xl p-2 shadow-2xl z-50 animate-fade-in">
                    <div className="border-b border-white/10 px-3 py-2">
                      <p className="text-xs font-black text-white truncate">{currentUser.nickname}</p>
                      <p className="text-[11px] text-slate-400 truncate">{currentUser.email}</p>
                      <span className="mt-1 inline-block rounded-md bg-emerald-500/20 px-2 py-0.5 text-[9px] font-bold text-emerald-300">
                        {currentUser.rank}
                      </span>
                    </div>

                    <div className="mt-1 space-y-0.5">
                      <Link
                        href="/topup"
                        onClick={() => setShowDropdown(false)}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-xs font-semibold text-emerald-300 hover:bg-white/5 transition"
                      >
                        <span>🪙</span>
                        <span>Поповнити баланс (+)</span>
                      </Link>
                      <Link
                        href="/inventory"
                        onClick={() => setShowDropdown(false)}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-xs font-semibold text-slate-300 hover:bg-white/5 hover:text-white transition"
                      >
                        <span>🎒</span>
                        <span>Мій інвентар</span>
                      </Link>
                      <Link
                        href="/market"
                        onClick={() => setShowDropdown(false)}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-xs font-semibold text-slate-300 hover:bg-white/5 hover:text-white transition"
                      >
                        <span>🛒</span>
                        <span>Ринок скінів</span>
                      </Link>
                      <button
                        onClick={handleLogout}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3 py-2 text-xs font-semibold text-rose-400 hover:bg-rose-500/10 transition text-left"
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
                  className="rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 px-3.5 py-1.5 text-xs font-bold text-slate-200 hover:text-white transition"
                >
                  Увійти
                </button>
                <button
                  onClick={() => openAuth("register")}
                  className="relative flex items-center gap-1.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 px-3.5 py-1.5 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition"
                >
                  <span>Реєстрація</span>
                  <span className="hidden sm:inline-block rounded-full bg-black/25 px-1.5 py-0.2 text-[9px] font-black text-emerald-200">
                    +2.5k GC
                  </span>
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
