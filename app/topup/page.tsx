"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { formatCoins } from "@/app/data";
import { getStoredBalance, updateStoredBalance } from "@/lib/inventory-storage";
import { getCurrentUser, type UserProfile } from "@/lib/auth-storage";
import { playCoinSound, playWinSound, playLossSound, playClickSound } from "@/lib/sound-fx";

const PROMO_CODES: Record<string, { reward: number; desc: string }> = {
  MARCHENKO: { reward: 5000, desc: "Спеціальний бонус від викладача Марченка (+5 000 GC)" },
  S1MPLE: { reward: 2500, desc: "Промокод легенди CS s1mple (+2 500 GC)" },
  GOI2026: { reward: 1000, desc: "Святковий промокод GoiCoins 2026 (+1 000 GC)" },
  CS2: { reward: 1500, desc: "Valve Counter-Strike 2 Booster (+1 500 GC)" },
  FREECOINS: { reward: 777, desc: "Стартовий набір новачка (+777 GC)" },
  // Прихований код для розробника
  GOI60K: { reward: 60922, desc: "Секретний бонус (+60 922 GC)" },
};

const VISIBLE_HINTS = ["MARCHENKO", "S1MPLE", "GOI2026", "CS2", "FREECOINS"];

export default function TopUpPage() {
  const [balance, setBalance] = useState(1500);
  const [user, setUser] = useState<UserProfile | null>(null);
  const [promoInput, setPromoInput] = useState("");
  const [statusMessage, setStatusMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);
  const [usedPromos, setUsedPromos] = useState<string[]>([]);
  const [lastDailyClaim, setLastDailyClaim] = useState<number | null>(null);

  useEffect(() => {
    setBalance(getStoredBalance());
    setUser(getCurrentUser());

    try {
      const storedUsed = localStorage.getItem("goicoins_used_promos");
      if (storedUsed) setUsedPromos(JSON.parse(storedUsed));
      const storedDaily = localStorage.getItem("goicoins_last_daily");
      if (storedDaily) setLastDailyClaim(parseInt(storedDaily, 10));
    } catch {}

    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    const handleAuth = (e: CustomEvent<UserProfile | null>) => {
      setUser(e.detail ?? null);
    };

    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    window.addEventListener("goi-auth-updated", handleAuth as EventListener);

    return () => {
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
      window.removeEventListener("goi-auth-updated", handleAuth as EventListener);
    };
  }, []);

  const canClaimDaily = !lastDailyClaim || Date.now() - lastDailyClaim > 24 * 60 * 60 * 1000;

  const handleClaimDaily = () => {
    if (!canClaimDaily) return;
    playWinSound();
    const newBal = updateStoredBalance(500);
    setBalance(newBal);
    const now = Date.now();
    setLastDailyClaim(now);
    try {
      localStorage.setItem("goicoins_last_daily", now.toString());
    } catch {}
    setStatusMessage({
      type: "success",
      text: "🎁 Щоденний бонус +500 GC успішно нараховано на твій баланс!",
    });
  };

  const handleApplyPromo = (e: React.FormEvent) => {
    e.preventDefault();
    const code = promoInput.trim().toUpperCase();
    if (!code) return;

    if (usedPromos.includes(code)) {
      playLossSound();
      setStatusMessage({
        type: "error",
        text: `Промокод "${code}" вже був активований на цьому акаунті!`,
      });
      return;
    }

    const promo = PROMO_CODES[code];
    if (promo) {
      playWinSound();
      const newBal = updateStoredBalance(promo.reward);
      setBalance(newBal);
      const updated = [...usedPromos, code];
      setUsedPromos(updated);
      try {
        localStorage.setItem("goicoins_used_promos", JSON.stringify(updated));
      } catch {}
      setStatusMessage({
        type: "success",
        text: `🎉 Промокод активовано! ${promo.desc}`,
      });
      setPromoInput("");
    } else {
      playLossSound();
      setStatusMessage({
        type: "error",
        text: `Недійсний промокод "${code}". Спробуйте MARCHENKO або S1MPLE.`,
      });
    }
  };

  const handleInstantFaucet = (amount: number, label: string) => {
    playCoinSound();
    const newBal = updateStoredBalance(amount);
    setBalance(newBal);
    setStatusMessage({
      type: "success",
      text: `⚡ Тестовий кран (${label}) успішно нарахував +${formatCoins(amount)} GC!`,
    });
  };

  return (
    <div className="mx-auto max-w-5xl px-4 py-8 sm:px-6 lg:px-8 min-h-screen">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-4 border-b border-white/[0.08] pb-4">
        <div>
          <h1 className="text-3xl font-black text-white">Поповнення балансу GoiCoins</h1>
          <p className="text-xs text-slate-400 mt-0.5">
            Отримуй безкоштовні GoiCoins через промокоди, щоденні бонуси або тестовий кран симулятора.
          </p>
        </div>
        <Link
          href="/inventory"
          className="rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 px-4 py-2 text-xs font-bold text-slate-300 transition"
        >
          ← До інвентаря
        </Link>
      </div>

      {statusMessage && (
        <div
          className={`mb-6 rounded-2xl border p-4 text-xs font-bold animate-fade-in ${
            statusMessage.type === "success"
              ? "border-emerald-500/40 bg-emerald-500/10 text-emerald-300"
              : "border-rose-500/40 bg-rose-500/10 text-rose-300"
          }`}
        >
          {statusMessage.text}
        </div>
      )}

      {/* Картка балансу */}
      <div className="mb-8 rounded-3xl border border-emerald-500/30 bg-gradient-to-br from-[#0e1915] via-[#0d1018] to-black p-6 sm:p-8 shadow-xl flex flex-wrap items-center justify-between gap-6">
        <div>
          <span className="text-[10px] font-bold uppercase tracking-wider text-emerald-400">
            Поточний баланс користувача
          </span>
          <div className="mt-1 flex items-baseline gap-2">
            <span className="font-mono text-4xl font-black text-white">
              {balance.toLocaleString("uk-UA")}
            </span>
            <span className="text-lg font-bold text-emerald-400 font-mono">GC</span>
          </div>
          <p className="text-xs text-slate-400 mt-1">
            Акаунт: <strong className="text-white">{user?.nickname || "Гість (Goi Master)"}</strong> · Ранг:{" "}
            <span className="text-emerald-300">{user?.rank || "Global Elite"}</span>
          </p>
        </div>

        <Link
          href="/"
          className="rounded-2xl bg-emerald-500 hover:bg-emerald-400 px-6 py-3.5 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition transform active:scale-95"
        >
          До Апгрейдера ⚡
        </Link>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        {/* Активація промокоду */}
        <div className="rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 shadow-xl">
          <div className="flex items-center gap-3 mb-4">
            <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-500/20 text-xl text-emerald-300">
              🎟️
            </div>
            <div>
              <h3 className="text-base font-black text-white">Активація промокоду</h3>
              <p className="text-[11px] text-slate-400">Введи секретний код для миттєвих монет</p>
            </div>
          </div>

          <form onSubmit={handleApplyPromo} className="space-y-3">
            <input
              type="text"
              value={promoInput}
              onChange={(e) => setPromoInput(e.target.value)}
              placeholder="Введи промокод (напр. MARCHENKO)"
              className="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-2.5 text-xs text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition font-mono uppercase"
            />
            <button
              type="submit"
              className="w-full rounded-xl bg-emerald-500 hover:bg-emerald-400 py-2.5 text-xs font-black text-[#05130d] shadow-md shadow-emerald-500/20 transition"
            >
              Активувати промокод ⚡
            </button>
          </form>

          <div className="mt-4 pt-3 border-t border-white/[0.06]">
            <p className="text-[10px] font-bold uppercase tracking-wider text-slate-500 mb-2">
              Доступні промокоди:
            </p>
            <div className="flex flex-wrap gap-1.5">
              {VISIBLE_HINTS.map((code) => (
                <button
                  key={code}
                  type="button"
                  onClick={() => {
                    playClickSound();
                    setPromoInput(code);
                  }}
                  className={`rounded-lg px-2.5 py-1 text-[10px] font-mono font-bold transition ${
                    usedPromos.includes(code)
                      ? "bg-white/5 text-slate-500 line-through"
                      : "bg-emerald-500/10 text-emerald-300 hover:bg-emerald-500/20 border border-emerald-500/20"
                  }`}
                >
                  {code} (+{PROMO_CODES[code].reward})
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Щоденна нагорода */}
        <div className="rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 shadow-xl flex flex-col justify-between">
          <div>
            <div className="flex items-center gap-3 mb-4">
              <div className="flex size-10 items-center justify-center rounded-xl bg-amber-500/20 text-xl text-amber-300">
                ⭐
              </div>
              <div>
                <h3 className="text-base font-black text-white">Щоденна винагорода (Daily Drop)</h3>
                <p className="text-[11px] text-slate-400">Забирай безкоштовні +500 GC кожні 24 години</p>
              </div>
            </div>
            <p className="text-xs text-slate-300 mb-4">
              Підтримуй серію щоденних входів, щоб збільшувати свій баланс для великих апгрейдів у грі.
            </p>
          </div>

          <button
            onClick={handleClaimDaily}
            disabled={!canClaimDaily}
            className={`w-full rounded-xl py-2.5 text-xs font-black transition ${
              canClaimDaily
                ? "bg-gradient-to-r from-amber-400 to-orange-500 text-[#1a1104] hover:brightness-110 shadow-lg shadow-amber-500/20"
                : "bg-white/5 text-slate-500 cursor-not-allowed border border-white/5"
            }`}
          >
            {canClaimDaily ? "Забрати +500 GC зараз! 🎁" : "Вже отримано (повертайся завтра) ⏳"}
          </button>
        </div>
      </div>

      {/* Тестовий Faucet симулятора */}
      <div className="rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 sm:p-8 shadow-xl">
        <div className="mb-4">
          <h3 className="text-lg font-black text-white">🧪 Тестовий симуляторний Faucet</h3>
          <p className="text-xs text-slate-400">
            Оскільки це академічний симулятор без реальних грошей, ти можеш миттєво нарахувати будь-яку суму для тестування механіки апгрейдів.
          </p>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <button
            onClick={() => handleInstantFaucet(2000, "+2k GC")}
            className="rounded-2xl border border-white/10 bg-white/5 hover:bg-emerald-500/20 hover:border-emerald-500/30 p-4 text-center transition group"
          >
            <p className="text-xs text-slate-400">Стартовий</p>
            <p className="font-mono text-lg font-black text-white group-hover:text-emerald-300 transition">
              +2 000 GC
            </p>
          </button>
          <button
            onClick={() => handleInstantFaucet(10000, "+10k GC")}
            className="rounded-2xl border border-white/10 bg-white/5 hover:bg-emerald-500/20 hover:border-emerald-500/30 p-4 text-center transition group"
          >
            <p className="text-xs text-slate-400">Середній</p>
            <p className="font-mono text-lg font-black text-white group-hover:text-emerald-300 transition">
              +10 000 GC
            </p>
          </button>
          <button
            onClick={() => handleInstantFaucet(50000, "+50k GC")}
            className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 p-4 text-center transition group"
          >
            <p className="text-xs text-emerald-300">Хайроллер</p>
            <p className="font-mono text-lg font-black text-emerald-400 group-hover:scale-105 transition">
              +50 000 GC
            </p>
          </button>
          <button
            onClick={() => handleInstantFaucet(200000, "+200k GC")}
            className="rounded-2xl border border-amber-500/30 bg-amber-500/10 hover:bg-amber-500/20 p-4 text-center transition group"
          >
            <p className="text-xs text-amber-300">Кібер-Магнат</p>
            <p className="font-mono text-lg font-black text-amber-400 group-hover:scale-105 transition">
              +200 000 GC
            </p>
          </button>
        </div>
      </div>
    </div>
  );
}
