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
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setTab(initialTab);
    setError(null);
    setSuccessMsg(null);
  }, [initialTab, isOpen]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && isOpen) onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const handleTabSwitch = (newTab: "login" | "register") => {
    playClickSound();
    setTab(newTab);
    setError(null);
    setSuccessMsg(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    playClickSound();
    setError(null);
    setSuccessMsg(null);

    if (tab === "register") {
      if (password !== confirmPassword) {
        playLossSound();
        setError("Введені паролі не співпадають!");
        return;
      }
      if (password.length < 6) {
        playLossSound();
        setError("Пароль повинен містити щонайменше 6 символів!");
        return;
      }
      setLoading(true);
      const res = registerUser(email, nickname, password);
      setLoading(false);

      if (!res.success) {
        playLossSound();
        setError(res.message || "Помилка реєстрації");
      } else {
        playWinSound();
        setSuccessMsg(res.message || "Успішна реєстрація! +2 500 GC нараховано!");
        setTimeout(() => {
          onClose();
          if (onSuccess && res.user) onSuccess(res.user);
        }, 1200);
      }
    } else {
      setLoading(true);
      const res = loginUser(email, password);
      setLoading(false);

      if (!res.success) {
        playLossSound();
        setError(res.message || "Помилка входу");
      } else {
        playWinSound();
        setSuccessMsg(res.message || "Успішний вхід!");
        setTimeout(() => {
          onClose();
          if (onSuccess && res.user) onSuccess(res.user);
        }, 1000);
      }
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
      <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-emerald-500/30 bg-[#0a0d14]/95 p-6 sm:p-8 shadow-[0_0_60px_rgba(16,185,129,0.18)]">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-4 top-4 flex size-8 items-center justify-center rounded-xl bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white transition"
          aria-label="Закрити"
        >
          ✕
        </button>

        <div className="text-center">
          <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-xl font-black text-[#05130d] shadow-lg shadow-emerald-500/25">
            G
          </div>
          <h2 className="mt-3 text-xl font-black text-white">GoiCoins Simulator</h2>
          <p className="text-xs text-slate-400 mt-0.5">
            {tab === "login"
              ? "Авторизуйтесь для збереження скінів та балансу"
              : "Створіть свій ігровий профіль та отримайте бонус"}
          </p>
        </div>

        <div className="my-5 grid grid-cols-2 gap-1 rounded-2xl border border-white/10 bg-black/40 p-1">
          <button
            type="button"
            onClick={() => handleTabSwitch("login")}
            className={`rounded-xl py-2 text-xs font-bold transition ${
              tab === "login"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            Увійти
          </button>
          <button
            type="button"
            onClick={() => handleTabSwitch("register")}
            className={`rounded-xl py-2 text-xs font-bold transition ${
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
                Ігровий нікнейм
              </label>
              <input
                type="text"
                required
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                placeholder="Введіть свій нікнейм"
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

          {tab === "register" && (
            <div className="animate-fade-in">
              <label className="block text-[11px] font-bold text-slate-300 mb-1">
                Підтвердження пароля
              </label>
              <input
                type={showPassword ? "text" : "password"}
                required
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Повторіть пароль"
                className="w-full rounded-xl border border-white/10 bg-black/40 px-3.5 py-2 text-xs text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 py-2.5 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/25 hover:brightness-110 active:scale-[0.99] transition disabled:opacity-50 mt-2"
          >
            {loading
              ? "Обробка..."
              : tab === "login"
              ? "Увійти в акаунт ⚡"
              : "Зареєструватися (+2 500 GC) 🎁"}
          </button>
        </form>
      </div>
    </div>
  );
}
