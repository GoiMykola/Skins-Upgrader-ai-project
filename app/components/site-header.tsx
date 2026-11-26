"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState, useEffect, useRef } from "react";
import { getStoredBalance } from "@/lib/inventory-storage";
import { getCurrentUser, logoutUser, type UserProfile } from "@/lib/auth-storage";
import { AuthModal } from "@/components/auth-modal";
import { DailyWheelModal } from "@/components/daily-wheel-modal";
import { GameStatsModal } from "@/components/game-stats-modal";
import { AdminVaultModal } from "@/components/admin-vault-modal";
import { playClickSound } from "@/lib/sound-fx";

export default function SiteHeader() {
  const pathname = usePathname();
  const [balance, setBalance] = useState(1500);
  const [currentUser, setCurrentUser] = useState<UserProfile | null>(null);
  const [isAuthOpen, setIsAuthOpen] = useState(false);
  const [authTab, setAuthTab] = useState<"login" | "register">("login");
  const [isWheelOpen, setIsWheelOpen] = useState(false);
  const [isStatsOpen, setIsStatsOpen] = useState(false);
  const [isAdminOpen, setIsAdminOpen] = useState(false);
  const [showDropdown, setShowDropdown] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    let active = true;
    queueMicrotask(() => {
      if (!active) return;
      setBalance(getStoredBalance());
      setCurrentUser(getCurrentUser());
    });

    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    const handleAuth = (e: CustomEvent<UserProfile | null>) => {
      setCurrentUser(e.detail ?? null);
    };

    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    window.addEventListener("goi-auth-updated", handleAuth as EventListener);

    // Секретний виклик ВИКЛЮЧНО через комбінацію: Ctrl + Shift + A (або Cmd + Shift + A на Mac)
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.shiftKey && (e.key === "A" || e.key === "a" || e.code === "KeyA")) {
        e.preventDefault();
        playClickSound();
        setIsAdminOpen(true);
      }
    };
    window.addEventListener("keydown", handleKeyDown);

    const handleClickOutside = (ev: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(ev.target as Node)) {
        setShowDropdown(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);

    return () => {
      active = false;
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
      window.removeEventListener("goi-auth-updated", handleAuth as EventListener);
      window.removeEventListener("keydown", handleKeyDown);
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

  const handleLogout = () => {
    playClickSound();
    logoutUser();
    setShowDropdown(false);
  };

  const navLinks = [
    { href: "/", label: "Апгрейдер" },
    { href: "/contracts", label: "Контракти 📜" },
    { href: "/duel", label: "Дуелі ⚔️" },
    { href: "/catalog", label: "Каталог" },
    { href: "/market", label: "Ринок 🔥", badge: "2.2к" },
    { href: "/inventory", label: "Інвентар" },
    { href: "/leaderboard", label: "Лідери" },
  ];

  return (
    <>
      <header className="sticky top-0 z-40 border-b border-white/[0.08] bg-[#080a10]/95 backdrop-blur-xl select-none">
        <div className="mx-auto flex h-20 max-w-[1760px] items-center justify-between px-4 sm:px-6 lg:px-10 xl:px-12">
          {/* Логотип 'G' тепер знову повноцінне посилання на головну (Апгрейдер) */}
          <Link
            href="/"
            onClick={() => playClickSound()}
            className="flex items-center gap-3.5 group cursor-pointer"
            title="На головну сторінку (Апгрейдер CS2)"
          >
            <div className="flex size-11 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-xl font-black text-[#05130d] shadow-lg shadow-emerald-500/25 group-hover:scale-105 active:scale-90 transition">
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

          <nav className="hidden lg:flex items-center gap-1 rounded-2xl border border-white/[0.08] bg-black/50 p-1.5 shadow-inner">
            {navLinks.map((link) => {
              const isActive = pathname === link.href;
              return (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => playClickSound()}
                  className={`relative flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-bold transition ${
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

          <div className="flex items-center gap-3">
            <button
              onClick={() => {
                playClickSound();
                setIsWheelOpen(true);
              }}
              className="hidden sm:flex items-center gap-2 rounded-2xl border border-amber-500/40 bg-amber-500/15 hover:bg-amber-500/25 px-3.5 py-2 text-xs font-black text-amber-300 shadow-[0_0_15px_rgba(245,158,11,0.2)] transition animate-pulse"
            >
              <span>🎡</span>
              <span>Колесо</span>
            </button>

            <div className="flex items-center gap-2 rounded-2xl border border-emerald-500/40 bg-emerald-500/15 px-4 py-2 font-mono text-sm sm:text-base font-black text-emerald-300 shadow-[0_0_20px_rgba(16,185,129,0.18)]">
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
                  className="flex items-center gap-2.5 rounded-2xl border border-white/10 bg-white/5 hover:bg-white/10 px-3.5 py-2 transition"
                >
                  <div className="flex size-8 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-400 to-teal-500 font-mono text-xs font-black text-[#05130d]">
                    {currentUser.avatar || "TH"}
                  </div>
                  <span className="hidden md:block text-xs font-black text-white truncate max-w-[100px]">
                    {currentUser.nickname}
                  </span>
                </button>

                {showDropdown && (
                  <div className="absolute right-0 mt-2 w-64 rounded-2xl border border-white/10 bg-[#0d111a]/98 backdrop-blur-2xl p-2.5 shadow-2xl z-50 animate-fade-in">
                    <div className="border-b border-white/10 px-3 py-2">
                      <p className="text-sm font-black text-white truncate">{currentUser.nickname}</p>
                      <p className="text-xs text-slate-400 truncate">{currentUser.email}</p>
                    </div>

                    <div className="mt-1.5 space-y-1">
                      <button
                        onClick={() => {
                          setShowDropdown(false);
                          setIsStatsOpen(true);
                        }}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3.5 py-2 text-xs font-bold text-slate-300 hover:bg-white/5 hover:text-white transition"
                      >
                        <span>📊</span>
                        <span>Моя статистика та історія</span>
                      </button>
                      <Link
                        href="/inventory"
                        onClick={() => setShowDropdown(false)}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3.5 py-2 text-xs font-bold text-slate-300 hover:bg-white/5 hover:text-white transition"
                      >
                        <span>🎒</span>
                        <span>Мій інвентар</span>
                      </Link>
                      <button
                        onClick={handleLogout}
                        className="flex w-full items-center gap-2.5 rounded-xl px-3.5 py-2 text-xs font-bold text-rose-400 hover:bg-rose-500/10 transition"
                      >
                        <span>🚪</span>
                        <span>Вийти з акаунта</span>
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <button
                onClick={() => {
                  playClickSound();
                  setAuthTab("login");
                  setIsAuthOpen(true);
                }}
                className="rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 px-4 py-2 text-xs font-bold text-slate-300 hover:text-white transition"
              >
                Увійти
              </button>
            )}
          </div>
        </div>
      </header>

      <AuthModal isOpen={isAuthOpen} initialTab={authTab} onClose={() => setIsAuthOpen(false)} />
      <DailyWheelModal isOpen={isWheelOpen} onClose={() => setIsWheelOpen(false)} />
      <GameStatsModal isOpen={isStatsOpen} onClose={() => setIsStatsOpen(false)} />
      <AdminVaultModal isOpen={isAdminOpen} onClose={() => setIsAdminOpen(false)} />
    </>
  );
}
