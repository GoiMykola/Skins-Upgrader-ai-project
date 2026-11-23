"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { formatCoins } from "@/app/data";
import { getStoredBalance, updateStoredBalance } from "@/lib/inventory-storage";
import { playCoinSound, playWinSound, playLossSound, playClickSound } from "@/lib/sound-fx";

interface PromoCodeConfig {
  reward: number;
  title: string;
}

const PROMO_CODES: Record<string, PromoCodeConfig> = {
  GOI2026: { reward: 1000, title: "Сезон 2026 GoiCoins" },
  S1MPLE: { reward: 2500, title: "Легендарний снайпер s1mple" },
  MARCHENKO: { reward: 5000, title: "Студентський VIP бонус Марченка" },
  CS2: { reward: 1500, title: "Офіційний реліз CS2" },
  FREECOINS: { reward: 777, title: "Щасливий куш 777" },
};

const FAUCET_PACKAGES = [
  {
    id: "tier1",
    title: "Початківець",
    amount: 2000,
    badge: "Старт",
    desc: "Вистачить на базовий дроп та перші апгрейди",
    icon: "🥉",
  },
  {
    id: "tier2",
    title: "Снайпер",
    amount: 10000,
    badge: "Популярний",
    desc: "Чудово підходить для апгрейду на Hyper Beast або Asiimov",
    icon: "🥈",
  },
  {
    id: "tier3",
    title: "Глобал Еліта",
    amount: 50000,
    badge: "Хайролер",
    desc: "Шанс отримати найрідкісніші рукавички та ножі",
    icon: "🥇",
  },
  {
    id: "tier4",
    title: "Олігарх КС2",
    amount: 200000,
    badge: "VIP Максимум",
    desc: "Для найдорожчих трофеїв: Dragon Lore, Howl та Fade",
    icon: "👑",
  },
];

export default function TopupPage() {
  const [balance, setBalance] = useState(1500);
  const [promoInput, setPromoInput] = useState("");
  const [promoFeedback, setPromoFeedback] = useState<{ text: string; success: boolean } | null>(null);
  const [usedPromos, setUsedPromos] = useState<string[]>([]);
  const [dailyClaimed, setDailyClaimed] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  useEffect(() => {
    setBalance(getStoredBalance());

    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    window.addEventListener("goi-balance-updated", handleBal as EventListener);

    try {
      const rawPromos = localStorage.getItem("goicoins_used_promos");
      if (rawPromos) setUsedPromos(JSON.parse(rawPromos));
    } catch {}

    try {
      const lastDaily = localStorage.getItem("goicoins_last_daily");
      if (lastDaily) {
        const diff = Date.now() - parseInt(lastDaily, 10);
        if (diff < 24 * 60 * 60 * 1000) {
          setDailyClaimed(true);
        }
      }
    } catch {}

    return () => {
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
    };
  }, []);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  const handleClaimDaily = () => {
    if (dailyClaimed) {
      playClickSound();
      showToast("⏳ Щоденний бонус уже отримано! Завітай знову через 24 години.");
      return;
    }

    playWinSound();
    const newBal = updateStoredBalance(500);
    setBalance(newBal);
    setDailyClaimed(true);
    try {
      localStorage.setItem("goicoins_last_daily", Date.now().toString());
    } catch {}
    showToast("🎉 Вітаємо! Отримано щоденний бонус: +500 GoiCoins!");
  };

  const handleApplyPromo = (e: React.FormEvent) => {
    e.preventDefault();
    playClickSound();
    const code = promoInput.trim().toUpperCase();

    if (!code) return;

    if (usedPromos.includes(code)) {
      playLossSound();
      setPromoFeedback({
        text: `⚠️ Промокод "${code}" вже був активований раніше на цьому пристрої!`,
        success: false,
      });
      return;
    }

    const promo = PROMO_CODES[code];
    if (promo) {
      playWinSound();
      const updatedPromos = [...usedPromos, code];
      setUsedPromos(updatedPromos);
      try {
        localStorage.setItem("goicoins_used_promos", JSON.stringify(updatedPromos));
      } catch {}

      const newBal = updateStoredBalance(promo.reward);
      setBalance(newBal);
      setPromoFeedback({
        text: `🎉 Успішно! Активовано "${promo.title}": +${promo.reward.toLocaleString("uk-UA")} GC!`,
        success: true,
      });
      setPromoInput("");
      showToast(`+${promo.reward.toLocaleString("uk-UA")} GC зараховано на твій баланс!`);
    } else {
      playLossSound();
      setPromoFeedback({
        text: "❌ Невірний промокод! Спробуй один з доступних кодів нижче.",
        success: false,
      });
    }
  };

  const handleClaimPackage = (amount: number, title: string) => {
    playCoinSound();
    const newBal = updateStoredBalance(amount);
    setBalance(newBal);
    showToast(`🪙 Пакет "${title}": +${formatCoins(amount)} GC успішно нараховано!`);
  };

  return (
    <div className="mx-auto max-w-[1760px] px-4 py-8 sm:px-6 lg:px-10 xl:px-12 min-h-screen">
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 rounded-2xl border border-emerald-500/40 bg-[#0d1614]/95 px-5 py-3 text-sm font-bold text-emerald-300 shadow-2xl backdrop-blur-md animate-fade-in">
          {toastMessage}
        </div>
      )}

      <div className="mb-8 overflow-hidden rounded-3xl border border-emerald-500/30 bg-gradient-to-r from-emerald-500/10 via-[#0e1713] to-emerald-500/5 p-6 sm:p-8 shadow-xl">
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div className="flex items-center gap-4">
            <div className="flex size-16 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 text-3xl font-black text-[#05130d] shadow-lg shadow-emerald-500/25">
              🪙
            </div>
            <div>
              <h1 className="text-2xl sm:text-3xl font-black text-white">
                Поповнення балансу GoiCoins
              </h1>
              <p className="text-xs sm:text-sm text-slate-400 mt-1">
                Отримуй щоденні нагороди, секретні промокоди та віртуальні пакети монет для апгрейду скінів CS2!
              </p>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="rounded-2xl border border-emerald-500/40 bg-black/50 px-6 py-3 shadow-inner">
              <p className="text-[10px] font-bold uppercase tracking-wider text-emerald-300">Твій поточний баланс</p>
              <p className="mt-0.5 font-mono text-2xl font-black text-white">
                {balance.toLocaleString("uk-UA")} GC
              </p>
            </div>
            <Link
              href="/"
              className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-5 py-3 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition"
            >
              До Апгрейдера ⚡
            </Link>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-10">
        <div className="rounded-3xl border border-white/[0.08] bg-[#0d1018]/90 p-6 flex flex-col justify-between shadow-xl">
          <div>
            <div className="flex items-center justify-between">
              <span className="text-2xl">🎁</span>
              <span className="rounded-full bg-emerald-500/20 px-2.5 py-0.5 text-[10px] font-bold text-emerald-300">
                Кожні 24 години
              </span>
            </div>
            <h2 className="mt-4 text-xl font-black text-white">Щоденний бонус</h2>
            <p className="mt-1 text-xs text-slate-400">
              Забирай безкоштовні монети кожен день просто за вхід у гру!
            </p>
            <div className="my-5 rounded-2xl border border-emerald-500/20 bg-emerald-500/5 p-4 text-center">
              <span className="font-mono text-3xl font-black text-emerald-400">+500 GC</span>
              <p className="text-[11px] text-slate-400 mt-1">Миттєве зарахування на рахунок</p>
            </div>
          </div>
          <button
            onClick={handleClaimDaily}
            disabled={dailyClaimed}
            className={`w-full rounded-xl py-3 text-xs font-black transition ${
              dailyClaimed
                ? "bg-white/5 text-slate-500 cursor-not-allowed border border-white/5"
                : "bg-emerald-500 hover:bg-emerald-400 text-[#05130d] shadow-lg shadow-emerald-500/20"
            }`}
          >
            {dailyClaimed ? "⏳ Вже отримано сьогодні" : "Забрати щоденні +500 GC 🎁"}
          </button>
        </div>

        <div className="rounded-3xl border border-white/[0.08] bg-[#0d1018]/90 p-6 flex flex-col justify-between shadow-xl">
          <div>
            <div className="flex items-center justify-between">
              <span className="text-2xl">🎟️</span>
              <span className="rounded-full bg-amber-500/20 px-2.5 py-0.5 text-[10px] font-bold text-amber-300">
                Секретні коди
              </span>
            </div>
            <h2 className="mt-4 text-xl font-black text-white">Активувати промокод</h2>
            <p className="mt-1 text-xs text-slate-400">
              Введи секретний код або обери один із доступних бонусів:
            </p>

            <form onSubmit={handleApplyPromo} className="mt-4 flex gap-2">
              <input
                type="text"
                value={promoInput}
                onChange={(e) => setPromoInput(e.target.value)}
                placeholder="Введи промокод (напр. S1MPLE)"
                className="w-full rounded-xl border border-white/10 bg-black/40 px-3.5 py-2.5 text-xs text-white uppercase tracking-wider placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition font-mono"
              />
              <button
                type="submit"
                className="rounded-xl bg-amber-500 hover:bg-amber-400 px-4 py-2.5 text-xs font-black text-[#05130d] transition whitespace-nowrap"
              >
                Активувати ⚡
              </button>
            </form>

            {promoFeedback && (
              <p
                className={`mt-3 text-xs font-semibold ${
                  promoFeedback.success ? "text-emerald-400" : "text-rose-400"
                }`}
              >
                {promoFeedback.text}
              </p>
            )}

            <div className="mt-4">
              <p className="text-[11px] font-bold uppercase tracking-wider text-slate-400 mb-2">
                Доступні промокоди (натисни щоб ввести):
              </p>
              <div className="flex flex-wrap gap-1.5">
                {Object.keys(PROMO_CODES).map((code) => {
                  const isUsed = usedPromos.includes(code);
                  return (
                    <button
                      key={code}
                      type="button"
                      onClick={() => setPromoInput(code)}
                      disabled={isUsed}
                      className={`rounded-lg px-2.5 py-1 text-[11px] font-mono font-bold transition ${
                        isUsed
                          ? "bg-white/5 text-slate-600 line-through cursor-not-allowed"
                          : "bg-emerald-500/10 text-emerald-300 border border-emerald-500/30 hover:bg-emerald-500/20"
                      }`}
                    >
                      {code} (+{PROMO_CODES[code].reward} GC)
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        </div>

        <div className="rounded-3xl border border-white/[0.08] bg-[#0d1018]/90 p-6 flex flex-col justify-between shadow-xl">
          <div>
            <div className="flex items-center justify-between">
              <span className="text-2xl">💡</span>
              <span className="rounded-full bg-blue-500/20 px-2.5 py-0.5 text-[10px] font-bold text-blue-300">
                Поради гри
              </span>
            </div>
            <h2 className="mt-4 text-xl font-black text-white">Способи заробітку GC</h2>
            <div className="mt-3 space-y-2.5 text-xs">
              <div className="rounded-xl border border-white/5 bg-black/30 p-2.5 flex items-center gap-3">
                <span className="text-base">🎒</span>
                <div>
                  <p className="font-bold text-white">Продаж непотрібних скінів</p>
                  <p className="text-[11px] text-slate-400">Продай скіни з інвентаря за повну вартість 1 грн = 1 GC.</p>
                </div>
              </div>
              <div className="rounded-xl border border-white/5 bg-black/30 p-2.5 flex items-center gap-3">
                <span className="text-base">🎯</span>
                <div>
                  <p className="font-bold text-white">Кібер-апгрейд скінів</p>
                  <p className="text-[11px] text-slate-400">Перетворюй дешеві скіни на дорогі топові ножі та AWP.</p>
                </div>
              </div>
              <div className="rounded-xl border border-white/5 bg-black/30 p-2.5 flex items-center gap-3">
                <span className="text-base">👤</span>
                <div>
                  <p className="font-bold text-white">Реєстрація акаунта</p>
                  <p className="text-[11px] text-slate-400">+2 500 GC та 4 скіни для нових зареєстрованих профілів.</p>
                </div>
              </div>
            </div>
          </div>
          <Link
            href="/inventory"
            className="w-full mt-4 rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 py-2.5 text-center text-xs font-bold text-slate-300 hover:text-white transition"
          >
            Перейти в Інвентар для продажу →
          </Link>
        </div>
      </div>

      <div className="mb-10">
        <div className="mb-5 flex items-center justify-between border-b border-white/[0.08] pb-3">
          <div>
            <h2 className="text-2xl font-black text-white">
              Миттєві демо-пакети монет (Faucet)
            </h2>
            <p className="text-xs text-slate-400 mt-0.5">
              Обирай будь-який віртуальний пакет для тестування найдорожчих апгрейдів у симуляторі:
            </p>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          {FAUCET_PACKAGES.map((pkg) => (
            <div
              key={pkg.id}
              className="group relative flex flex-col justify-between rounded-3xl border border-white/[0.08] bg-[#0d1018]/90 p-5 transition duration-200 hover:border-emerald-500/50 hover:bg-[#121622] hover:shadow-xl hover:shadow-emerald-500/10"
            >
              <div>
                <div className="flex items-center justify-between">
                  <span className="text-3xl">{pkg.icon}</span>
                  <span className="rounded-full bg-emerald-500/20 px-2.5 py-0.5 text-[10px] font-bold text-emerald-300">
                    {pkg.badge}
                  </span>
                </div>
                <h3 className="mt-3 text-lg font-black text-white group-hover:text-emerald-300 transition">
                  {pkg.title}
                </h3>
                <p className="mt-1 text-xs text-slate-400 min-h-[36px]">{pkg.desc}</p>
                <div className="my-4 rounded-2xl border border-emerald-500/20 bg-emerald-500/5 py-3 text-center">
                  <span className="font-mono text-2xl font-black text-emerald-400">
                    +{pkg.amount.toLocaleString("uk-UA")} GC
                  </span>
                </div>
              </div>

              <button
                onClick={() => handleClaimPackage(pkg.amount, pkg.title)}
                className="w-full rounded-xl bg-emerald-500 hover:bg-emerald-400 py-2.5 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition active:scale-95"
              >
                Отримати +{formatCoins(pkg.amount)} GC 🪙
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
