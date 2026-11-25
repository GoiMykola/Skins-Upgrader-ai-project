#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v30: ЗБІЛЬШЕННЯ МАСШТАБУ ВІКНА АВТОРИЗАЦІЇ/РЕЄСТРАЦІЇ"
echo "   1. Збільшено ширину модалки з 448px (max-w-md) до 672px (max-w-2xl)"
echo "   2. Збільшено внутрішні відступи (padding) до p-10 / p-12"
echo "   3. Великі зручні поля вводу (py-4, text-base, rounded-2xl)"
echo "   4. Великі контрастні кнопки, чіткі шрифти та велика іконка 'G'"
echo "   5. Повний білд і деплой на GitHub"
echo "=========================================================="

mkdir -p components

# 1. Оновлення components/auth-modal.tsx: просторе, велике та комфортне вікно
cat << 'EOF' > components/auth-modal.tsx
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
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 md:p-8 bg-black/85 backdrop-blur-lg animate-fade-in overflow-y-auto">
      {/* Збільшений контейнер: max-w-xl sm:max-w-2xl замість max-w-md */}
      <div className="relative w-full max-w-xl sm:max-w-2xl overflow-hidden rounded-[32px] border border-emerald-500/40 bg-[#0a0d14]/98 p-8 sm:p-10 md:p-12 shadow-[0_0_80px_rgba(16,185,129,0.22)] my-auto">
        {/* Кнопка закриття */}
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-5 top-5 sm:right-6 sm:top-6 flex size-10 sm:size-11 items-center justify-center rounded-2xl border border-white/10 bg-white/5 text-slate-400 hover:bg-white/15 hover:text-white transition text-base sm:text-lg font-bold"
          aria-label="Закрити"
        >
          ✕
        </button>

        {/* Шапка модалки */}
        <div className="text-center">
          <div className="mx-auto flex size-16 sm:size-20 items-center justify-center rounded-3xl bg-gradient-to-br from-emerald-400 via-teal-500 to-emerald-600 font-mono text-3xl sm:text-4xl font-black text-[#05130d] shadow-xl shadow-emerald-500/30">
            G
          </div>
          <h2 className="mt-4 text-2xl sm:text-3xl font-black text-white tracking-tight">
            GoiCoins Simulator
          </h2>
          <p className="text-sm sm:text-base text-slate-300 mt-1.5 max-w-md mx-auto">
            {tab === "login"
              ? "Авторизуйтесь для збереження скінів та балансу"
              : "Створіть свій ігровий профіль та отримайте бонусний баланс"}
          </p>
        </div>

        {/* Перемикач вкладок */}
        <div className="my-6 sm:my-8 grid grid-cols-2 gap-2 rounded-2xl border border-white/10 bg-black/50 p-1.5">
          <button
            type="button"
            onClick={() => handleTabSwitch("login")}
            className={`rounded-xl py-3 sm:py-3.5 px-4 text-sm sm:text-base font-black transition ${
              tab === "login"
                ? "bg-emerald-500 text-[#05130d] shadow-lg shadow-emerald-500/25"
                : "text-slate-400 hover:text-white hover:bg-white/5"
            }`}
          >
            Увійти
          </button>
          <button
            type="button"
            onClick={() => handleTabSwitch("register")}
            className={`rounded-xl py-3 sm:py-3.5 px-4 text-sm sm:text-base font-black transition ${
              tab === "register"
                ? "bg-emerald-500 text-[#05130d] shadow-lg shadow-emerald-500/25"
                : "text-slate-400 hover:text-white hover:bg-white/5"
            }`}
          >
            Реєстрація (+2.5k GC) 🎁
          </button>
        </div>

        {/* Повідомлення про помилку */}
        {error && (
          <div className="mb-5 rounded-2xl border border-rose-500/30 bg-rose-500/15 p-4 text-xs sm:text-sm font-bold text-rose-300 animate-fade-in flex items-center gap-2">
            <span className="text-lg">⚠️</span>
            <span>{error}</span>
          </div>
        )}

        {/* Повідомлення про успіх */}
        {successMsg && (
          <div className="mb-5 rounded-2xl border border-emerald-500/40 bg-emerald-500/15 p-4 text-xs sm:text-sm font-bold text-emerald-300 animate-fade-in flex items-center gap-2">
            <span className="text-lg">🎉</span>
            <span>{successMsg}</span>
          </div>
        )}

        {/* Форма */}
        <form onSubmit={handleSubmit} className="space-y-4 sm:space-y-5">
          <div>
            <label className="block text-xs sm:text-sm font-bold uppercase tracking-wider text-slate-300 mb-2">
              Електронна пошта
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="player@cs2goi.ua"
              className="w-full rounded-2xl border border-white/10 bg-black/60 px-5 py-3.5 sm:py-4 text-sm sm:text-base text-white placeholder-slate-500 focus:border-emerald-400 focus:ring-2 focus:ring-emerald-500/30 focus:outline-none transition"
            />
          </div>

          {tab === "register" && (
            <div className="animate-fade-in">
              <label className="block text-xs sm:text-sm font-bold uppercase tracking-wider text-slate-300 mb-2">
                Ігровий нікнейм
              </label>
              <input
                type="text"
                required
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                placeholder="Введіть свій нікнейм (наприклад: CyberKing)"
                className="w-full rounded-2xl border border-white/10 bg-black/60 px-5 py-3.5 sm:py-4 text-sm sm:text-base text-white placeholder-slate-500 focus:border-emerald-400 focus:ring-2 focus:ring-emerald-500/30 focus:outline-none transition"
              />
            </div>
          )}

          <div>
            <label className="block text-xs sm:text-sm font-bold uppercase tracking-wider text-slate-300 mb-2">
              Пароль {tab === "register" && "(мінімум 6 символів)"}
            </label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Введіть пароль"
                className="w-full rounded-2xl border border-white/10 bg-black/60 px-5 py-3.5 sm:py-4 pr-12 text-sm sm:text-base text-white placeholder-slate-500 focus:border-emerald-400 focus:ring-2 focus:ring-emerald-500/30 focus:outline-none transition"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3.5 top-1/2 -translate-y-1/2 flex size-9 items-center justify-center rounded-xl text-base sm:text-lg text-slate-400 hover:text-white transition"
              >
                {showPassword ? "🙈" : "👁️"}
              </button>
            </div>
          </div>

          {tab === "register" && (
            <div className="animate-fade-in">
              <label className="block text-xs sm:text-sm font-bold uppercase tracking-wider text-slate-300 mb-2">
                Підтвердження пароля
              </label>
              <input
                type={showPassword ? "text" : "password"}
                required
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Повторіть пароль ще раз"
                className="w-full rounded-2xl border border-white/10 bg-black/60 px-5 py-3.5 sm:py-4 text-sm sm:text-base text-white placeholder-slate-500 focus:border-emerald-400 focus:ring-2 focus:ring-emerald-500/30 focus:outline-none transition"
              />
            </div>
          )}

          {/* Велика помітна кнопка відправки */}
          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-2xl bg-gradient-to-r from-emerald-400 via-emerald-500 to-teal-500 py-4 sm:py-4.5 text-base sm:text-lg font-black text-[#05130d] shadow-xl shadow-emerald-500/30 hover:brightness-110 active:scale-[0.99] transition disabled:opacity-50 mt-4 cursor-pointer"
          >
            {loading
              ? "Обробка запиту..."
              : tab === "login"
              ? "Увійти в акаунт ⚡"
              : "Зареєструватися (+2 500 GC) 🎁"}
          </button>
        </form>

        <p className="mt-5 text-center text-xs text-slate-500 font-medium">
          🔒 Безпечне збереження інвентаря та балансу GoiCoins
        </p>
      </div>
    </div>
  );
}
EOF

# 2. Перевірка білду
echo "=========================================================="
echo "🧪 ПЕРЕВІРКА БІЛДУ"
echo "=========================================================="
npm run build

# 3. Git Commit & Push
echo "=========================================================="
echo "🚀 ФІКСАЦІЯ В GIT ТА PUSH"
echo "=========================================================="
git add components/auth-modal.tsx || true
git commit -m "style(auth): scale up auth modal size, typography, inputs and buttons" || true
git push origin main || true

echo "=========================================================="
echo "🎉 ВСЕ ПРАЦЮЄ! Вікно авторизації стало великим, стильним та зручним!"
echo "=========================================================="
