"use client";

import { useState, useEffect } from "react";
import { registerUser, loginUser, type UserProfile } from "@/lib/auth-storage";
import { playClickSound, playWinSound, playLossSound } from "@/lib/sound-fx";

interface AuthModalProps {
  isOpen: boolean;
  initialTab?: "login" | "register";
  onClose: () => void;
  onSuccess?: (user: UserProfile) => void;
}

export function AuthModal({
  isOpen,
  initialTab = "login",
  onClose,
  onSuccess,
}: AuthModalProps) {
  const [tab, setTab] = useState<"login" | "register">(initialTab);
  const [email, setEmail] = useState("");
  const [nickname, setNickname] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  useEffect(() => {
    setTab(initialTab);
    setError(null);
    setSuccessMsg(null);
  }, [initialTab, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccessMsg(null);

    if (tab === "login") {
      const res = loginUser(email, password);
      if (res.success && res.user) {
        playWinSound();
        setSuccessMsg(res.message || "Успішний вхід!");
        setTimeout(() => {
          onSuccess?.(res.user!);
          onClose();
        }, 800);
      } else {
        playLossSound();
        setError(res.message || "Помилка входу");
      }
    } else {
      const res = registerUser(email, nickname, password);
      if (res.success && res.user) {
        playWinSound();
        setSuccessMsg(res.message || "Успішна реєстрація!");
        setTimeout(() => {
          onSuccess?.(res.user!);
          onClose();
        }, 1200);
      } else {
        playLossSound();
        setError(res.message || "Помилка реєстрації");
      }
    }
  };

  const handleQuickSupabaseDemo = (account: "a" | "b") => {
    playClickSound();
    if (account === "a") {
      setEmail("nikoly2305+a@gmail.com");
      setNickname("Goi Master");
      setPassword("password123");
    } else {
      setEmail("nikoly2305+b@gmail.com");
      setNickname("Cyber Player");
      setPassword("password123");
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
      <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-white/10 bg-[#0d1018]/95 p-6 sm:p-8 shadow-[0_0_50px_rgba(16,185,129,0.15)]">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-4 top-4 rounded-xl p-2 text-slate-400 hover:bg-white/5 hover:text-white transition"
          aria-label="Закрити"
        >
          ✕
        </button>

        <div className="flex items-center gap-3 mb-6">
          <div className="flex size-11 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 text-xl font-black text-[#05130d] shadow-lg shadow-emerald-500/20">
            G
          </div>
          <div>
            <h2 className="text-xl font-black text-white">GoiCoins Simulator</h2>
            <p className="text-xs text-slate-400">Система акаунтів та хмарний інвентар</p>
          </div>
        </div>

        <div className="flex rounded-xl bg-black/40 p-1 mb-6 border border-white/5">
          <button
            onClick={() => {
              playClickSound();
              setTab("login");
              setError(null);
            }}
            className={`flex-1 rounded-lg py-2 text-xs font-bold transition ${
              tab === "login"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            Увійти
          </button>
          <button
            onClick={() => {
              playClickSound();
              setTab("register");
              setError(null);
            }}
            className={`flex-1 rounded-lg py-2 text-xs font-bold transition ${
              tab === "register"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            Реєстрація (+2.5k GC) 🎁
          </button>
        </div>

        {error && (
          <div className="mb-4 rounded-xl border border-rose-500/30 bg-rose-500/10 p-3 text-xs font-medium text-rose-400 animate-fade-in">
            ⚠️ {error}
          </div>
        )}

        {successMsg && (
          <div className="mb-4 rounded-xl border border-emerald-500/30 bg-emerald-500/10 p-3 text-xs font-medium text-emerald-400 animate-fade-in">
            🎉 {successMsg}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-[11px] font-bold text-slate-300 mb-1">
              Електронна пошта
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="player@cs2goi.ua"
              className="w-full rounded-xl border border-white/10 bg-black/40 px-3.5 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
            />
          </div>

          {tab === "register" && (
            <div className="animate-fade-in">
              <label className="block text-[11px] font-bold text-slate-300 mb-1">
                Ігровий нікнейм (позивний)
              </label>
              <input
                type="text"
                required
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                placeholder="Goi Master"
                className="w-full rounded-xl border border-white/10 bg-black/40 px-3.5 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
            </div>
          )}

          <div>
            <label className="block text-[11px] font-bold text-slate-300 mb-1">
              Пароль {tab === "register" && "(мінімум 6 символів)"}
            </label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Введіть пароль"
                className="w-full rounded-xl border border-white/10 bg-black/40 px-3.5 py-2 pr-10 text-xs text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-slate-400 hover:text-white"
              >
                {showPassword ? "🙈" : "👁️"}
              </button>
            </div>
          </div>

          <button
            type="submit"
            className="w-full rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 py-2.5 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/25 hover:brightness-110 active:scale-[0.99] transition mt-2"
          >
            {tab === "login" ? "Увійти в акаунт ⚡" : "Зареєструватися (+2 500 GC) 🎁"}
          </button>
        </form>

        <div className="mt-5 border-t border-white/5 pt-4">
          <p className="text-[10px] font-bold uppercase tracking-wider text-slate-500 text-center mb-2.5">
            Швидкий вхід акаунтами з Supabase (ПР 5):
          </p>
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => handleQuickSupabaseDemo("a")}
              className="flex-1 rounded-lg border border-emerald-500/30 bg-emerald-500/10 py-1.5 text-[11px] font-medium text-emerald-300 hover:bg-emerald-500/20 transition"
            >
              👑 Акаунт А (Goi Master)
            </button>
            <button
              type="button"
              onClick={() => handleQuickSupabaseDemo("b")}
              className="flex-1 rounded-lg border border-white/10 bg-white/5 py-1.5 text-[11px] font-medium text-slate-300 hover:bg-white/10 hover:text-white transition"
            >
              👤 Акаунт Б (Cyber Player)
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
