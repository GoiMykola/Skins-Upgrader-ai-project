#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v18: ОЧИЩЕННЯ ТА ПРИХОВУВАННЯ ТЕСТОВИХ КНОПОК"
echo "   (Прибрано банери та кнопки відновлення для юзерів)"
echo "=========================================================="

# 1. Чистий app/inventory/page.tsx без жодних банерів та кнопок відновлення
cat << 'INNER_EOF' > app/inventory/page.tsx
"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { formatCoins } from "@/app/data";
import SkinArt from "@/app/components/skin-art";
import {
  getStoredInventory,
  getStoredBalance,
  sellInventorySkin,
  sellAllInventorySkins,
  type InventoryItem,
} from "@/lib/inventory-storage";
import { getCurrentUser, type UserProfile } from "@/lib/auth-storage";
import { playCoinSound, playClickSound } from "@/lib/sound-fx";

export default function InventoryPage() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [balance, setBalance] = useState(1500);
  const [user, setUser] = useState<UserProfile | null>(null);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const [skinToSell, setSkinToSell] = useState<InventoryItem | null>(null);
  const [confirmSellAll, setConfirmSellAll] = useState(false);

  useEffect(() => {
    setInventory(getStoredInventory());
    setBalance(getStoredBalance());
    setUser(getCurrentUser());

    const handleInv = (e: CustomEvent<InventoryItem[]>) => {
      if (e.detail) setInventory(e.detail);
    };
    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    const handleAuth = (e: CustomEvent<UserProfile | null>) => {
      setUser(e.detail ?? null);
    };

    window.addEventListener("goi-inventory-updated", handleInv as EventListener);
    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    window.addEventListener("goi-auth-updated", handleAuth as EventListener);

    return () => {
      window.removeEventListener("goi-inventory-updated", handleInv as EventListener);
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
      window.removeEventListener("goi-auth-updated", handleAuth as EventListener);
    };
  }, []);

  const totalValue = inventory.reduce((acc, s) => acc + (s.price || 0), 0);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  };

  const requestSellSkin = (item: InventoryItem) => {
    playClickSound();
    setSkinToSell(item);
  };

  const executeSellSkin = () => {
    if (!skinToSell) return;
    playCoinSound();
    const { newInventory, newBalance } = sellInventorySkin(skinToSell);
    setInventory(newInventory);
    setBalance(newBalance);
    showToast(`💰 Продано ${skinToSell.weapon} | ${skinToSell.name} за +${formatCoins(skinToSell.price)} GC!`);
    setSkinToSell(null);
  };

  const requestSellAll = () => {
    if (inventory.length === 0) return;
    playClickSound();
    setConfirmSellAll(true);
  };

  const executeSellAll = () => {
    playCoinSound();
    const { count, totalGained, newBalance } = sellAllInventorySkins();
    setInventory([]);
    setBalance(newBalance);
    showToast(`🎉 Продано всі ${count} скінів на суму +${formatCoins(totalGained)} GC!`);
    setConfirmSellAll(false);
  };

  const handleSelectAsUpgradeSource = (item: InventoryItem) => {
    playClickSound();
    try {
      localStorage.setItem("goicoins_selected_source", JSON.stringify(item));
    } catch {}
  };

  const openRegisterModal = () => {
    playClickSound();
    window.dispatchEvent(new CustomEvent("goi-open-auth", { detail: "register" }));
  };

  return (
    <div className="mx-auto max-w-[1760px] px-4 py-8 sm:px-6 lg:px-10 xl:px-12 min-h-screen">
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 rounded-2xl border border-emerald-500/40 bg-[#0d1614]/95 px-5 py-3 text-sm font-bold text-emerald-300 shadow-2xl backdrop-blur-md animate-fade-in">
          {toastMessage}
        </div>
      )}

      {/* Верхня панель профілю */}
      <div className="mb-6 overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 sm:p-8 shadow-xl">
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div className="flex items-center gap-4">
            <div className="flex size-16 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 text-2xl font-black text-[#05130d] shadow-lg shadow-emerald-500/20">
              {user?.avatar || "G"}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-2xl font-black text-white">
                  Гравець {user?.nickname || "Гість (Goi Master)"}
                </h1>
                <span className="rounded-md bg-emerald-400/20 px-2 py-0.5 text-xs font-bold text-emerald-300">
                  {user?.rank || "Global Elite"}
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">
                {user ? user.email : "ID: #GP-88391 · Твій персональний інвентар CS2"}
              </p>
            </div>
          </div>

          <div className="flex flex-wrap gap-4">
            <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 px-5 py-3 flex items-center gap-3">
              <div>
                <p className="text-[10px] font-bold uppercase tracking-wider text-emerald-300">Баланс GC</p>
                <p className="mt-0.5 font-mono text-xl font-black text-white">
                  {balance.toLocaleString("uk-UA")} GC
                </p>
              </div>
              <Link
                href="/topup"
                title="Поповнити баланс (+)"
                className="flex size-8 items-center justify-center rounded-xl bg-emerald-500 hover:bg-emerald-400 text-[#05130d] font-black text-lg shadow-md shadow-emerald-500/30 hover:scale-105 active:scale-95 transition"
              >
                +
              </Link>
            </div>
            <div className="rounded-2xl border border-white/[0.06] bg-black/40 px-5 py-3">
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Вартість інвентаря</p>
              <p className="mt-0.5 font-mono text-xl font-black text-emerald-400">
                {formatCoins(totalValue)} GC
              </p>
            </div>
            <div className="rounded-2xl border border-white/[0.06] bg-black/40 px-5 py-3">
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Кількість предметів</p>
              <p className="mt-0.5 font-mono text-xl font-black text-white">
                {inventory.length} шт.
              </p>
            </div>
          </div>
        </div>
      </div>

      {!user && (
        <div className="mb-8 rounded-3xl border border-emerald-500/30 bg-gradient-to-r from-emerald-500/10 via-[#0e1713] to-emerald-500/5 p-5 sm:p-6 flex flex-wrap items-center justify-between gap-4 shadow-lg animate-fade-in">
          <div className="flex items-center gap-4">
            <div className="flex size-12 items-center justify-center rounded-2xl bg-emerald-500/20 text-2xl">
              🎁
            </div>
            <div>
              <h3 className="text-base font-black text-white">
                Ти граєш як Гість! Зареєструйся та отримай бонус
              </h3>
              <p className="text-xs text-slate-300 mt-0.5">
                Прив&apos;яжи свої скіни до власної пошти та отримай <strong className="text-emerald-400">+2 500 GoiCoins</strong> та 4 стартових скіни!
              </p>
            </div>
          </div>
          <button
            onClick={openRegisterModal}
            className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-6 py-2.5 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition"
          >
            Зареєструватися (+2.5k GC) ⚡
          </button>
        </div>
      )}

      {/* Заголовок списку скінів */}
      <div className="mb-6 flex flex-wrap items-center justify-between gap-4 border-b border-white/[0.08] pb-4">
        <div>
          <h2 className="text-2xl font-black text-white">
            Предмети в інвентарі ({inventory.length})
          </h2>
          <p className="text-xs text-slate-400 mt-0.5">
            Ти можеш продати будь-який скін за повну вартість у GoiCoins (з підтвердженням) або запустити його в кібер-апгрейд.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2.5">
          {inventory.length > 0 && (
            <button
              onClick={requestSellAll}
              className="rounded-xl border border-amber-500/40 bg-amber-500/10 hover:bg-amber-500/20 px-4 py-2 text-xs font-bold text-amber-300 transition"
            >
              Продати весь інвентар (+{formatCoins(totalValue)} GC) 💰
            </button>
          )}
          <Link
            href="/"
            className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-4 py-2 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition"
          >
            До Апгрейдера ⚡
          </Link>
        </div>
      </div>

      {/* Сітка інвентарю */}
      {inventory.length === 0 ? (
        <div className="flex min-h-[400px] flex-col items-center justify-center rounded-3xl border border-dashed border-white/10 bg-[#0d1018]/50 p-12 text-center">
          <div className="text-6xl mb-4">🎒</div>
          <h3 className="text-xl font-bold text-white">Твій інвентар порожній</h3>
          <p className="text-sm text-slate-400 max-w-md mt-1 mb-6">
            Купуй скіни на CS2 Ринку або скористайся щоденними бонусами на сторінці поповнення!
          </p>
          <Link
            href="/market"
            className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-6 py-2.5 text-xs font-black text-[#05130d] transition shadow-lg shadow-emerald-500/20"
          >
            Перейти на Ринок CS2 →
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-7">
          {inventory.map((item) => (
            <div
              key={item.instanceId}
              className="group relative flex flex-col justify-between overflow-hidden rounded-2xl border border-white/[0.08] bg-[#0d1018]/90 p-3.5 transition duration-200 hover:border-emerald-500/50 hover:bg-[#121622] hover:shadow-xl hover:shadow-emerald-500/10"
            >
              <div className="flex items-center justify-between text-[10px]">
                <span
                  className="rounded px-1.5 py-0.5 font-bold uppercase tracking-wider"
                  style={{ backgroundColor: `${item.accent || "#eb4b4b"}20`, color: item.accent || "#eb4b4b" }}
                >
                  {item.rarity}
                </span>
                <span className="font-mono font-bold text-emerald-400">
                  {formatCoins(item.price)} GC
                </span>
              </div>

              <div className="relative my-3 flex aspect-video items-center justify-center">
                <div
                  className="absolute inset-0 opacity-20 blur-xl transition group-hover:opacity-40"
                  style={{ backgroundColor: item.accent || "#eb4b4b" }}
                />
                <SkinArt
                  skin={item}
                  className="h-24 w-full object-contain drop-shadow-lg transition-transform duration-300 group-hover:scale-105"
                />
              </div>

              <div>
                <p className="text-[11px] font-semibold text-slate-400">{item.weapon}</p>
                <p className="truncate text-xs font-black text-white group-hover:text-emerald-300 transition">
                  {item.name}
                </p>
                <p className="text-[10px] text-slate-500">{item.wear}</p>
              </div>

              <div className="mt-3 flex gap-1.5 pt-2 border-t border-white/[0.06]">
                <Link
                  href="/"
                  onClick={() => handleSelectAsUpgradeSource(item)}
                  className="flex-1 rounded-lg bg-emerald-500/15 hover:bg-emerald-500/25 py-1.5 text-center text-[10px] font-bold text-emerald-300 transition"
                >
                  В Апгрейд ⚡
                </Link>
                <button
                  onClick={() => requestSellSkin(item)}
                  title={`Продати за +${formatCoins(item.price)} GC`}
                  className="rounded-lg bg-white/5 hover:bg-amber-500/20 px-2.5 py-1.5 text-center text-[10px] font-bold text-slate-300 hover:text-amber-300 transition"
                >
                  Продати 💰
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Модалка підтвердження продажу окремого скіна */}
      {skinToSell && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
          <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-amber-500/30 bg-[#0d1018]/95 p-6 sm:p-7 shadow-[0_0_50px_rgba(245,158,11,0.18)]">
            <div className="text-center">
              <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-amber-500/20 text-2xl">
                ⚠️
              </div>
              <h3 className="mt-3 text-xl font-black text-white">Підтвердження продажу</h3>
              <p className="mt-1 text-xs text-slate-400">
                Ти дійсно хочеш продати цей скін за GoiCoins?
              </p>
            </div>

            <div className="mt-5 rounded-2xl border border-white/10 bg-black/40 p-4 text-center">
              <div className="relative mx-auto flex h-24 w-full items-center justify-center">
                <div
                  className="absolute inset-0 opacity-20 blur-xl"
                  style={{ backgroundColor: skinToSell.accent || "#eb4b4b" }}
                />
                <SkinArt
                  skin={skinToSell}
                  className="h-20 w-full object-contain drop-shadow-lg"
                />
              </div>
              <p className="mt-2 text-xs font-semibold text-slate-400">{skinToSell.weapon}</p>
              <p className="text-base font-black text-white">{skinToSell.name}</p>
              <div className="mt-1 flex items-center justify-center gap-2 text-[11px]">
                <span
                  className="rounded px-1.5 py-0.5 font-bold uppercase"
                  style={{ backgroundColor: `${skinToSell.accent || "#eb4b4b"}20`, color: skinToSell.accent || "#eb4b4b" }}
                >
                  {skinToSell.rarity}
                </span>
                <span className="text-slate-500">·</span>
                <span className="text-slate-400">{skinToSell.wear}</span>
              </div>
              <div className="mt-3 rounded-xl bg-emerald-500/10 border border-emerald-500/30 py-2">
                <span className="text-[10px] font-bold text-emerald-300 uppercase">Отримаєш: </span>
                <span className="text-base font-black text-emerald-400 font-mono">
                  +{formatCoins(skinToSell.price)} GC
                </span>
              </div>
            </div>

            <div className="mt-6 flex gap-3">
              <button
                onClick={() => setSkinToSell(null)}
                className="flex-1 rounded-xl border border-white/10 bg-white/5 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/10 hover:text-white transition"
              >
                Скасувати
              </button>
              <button
                onClick={executeSellSkin}
                className="flex-1 rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 py-2.5 text-xs font-black text-[#1a1104] shadow-lg shadow-amber-500/20 hover:brightness-110 transition"
              >
                Підтвердити продаж 💰
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Модалка підтвердження продажу ВСЬОГО інвентаря */}
      {confirmSellAll && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
          <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-rose-500/40 bg-[#0d1018]/95 p-6 sm:p-7 shadow-[0_0_50px_rgba(244,63,94,0.2)]">
            <div className="text-center">
              <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-rose-500/20 text-2xl text-rose-400">
                🚨
              </div>
              <h3 className="mt-3 text-xl font-black text-white">Продати весь інвентар?</h3>
              <p className="mt-1 text-xs text-slate-400">
                Ця дія безповоротно продасть <strong className="text-white">{inventory.length} скінів</strong> за повну ринкову вартість.
              </p>
            </div>

            <div className="mt-5 rounded-2xl border border-white/10 bg-black/40 p-4 text-center">
              <p className="text-xs text-slate-400">Загальне нарахування на баланс:</p>
              <p className="mt-1 font-mono text-2xl font-black text-emerald-400">
                +{formatCoins(totalValue)} GC
              </p>
              <p className="mt-1 text-[11px] text-slate-500">
                Новий баланс: {(balance + totalValue).toLocaleString("uk-UA")} GC
              </p>
            </div>

            <div className="mt-6 flex gap-3">
              <button
                onClick={() => setConfirmSellAll(false)}
                className="flex-1 rounded-xl border border-white/10 bg-white/5 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/10 hover:text-white transition"
              >
                Скасувати
              </button>
              <button
                onClick={executeSellAll}
                className="flex-1 rounded-xl bg-rose-500 hover:bg-rose-400 py-2.5 text-xs font-black text-white shadow-lg shadow-rose-500/25 transition"
              >
                Так, продати все 💥
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
INNER_EOF

# 2. Чистий app/topup/page.tsx: без кнопки відновлення у картці балансу та без підказок GOI60K
cat << 'INNER_EOF' > app/topup/page.tsx
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
INNER_EOF

echo "=========================================================="
echo "🧪 ЗАПУСК ТЕСТІВ ТА БІЛДУ"
echo "=========================================================="
npm test
npm run build

echo "=========================================================="
echo "🚀 ФІКСАЦІЯ В GIT ТА PUSH"
echo "=========================================================="
git add .
git commit -m "chore(ui): remove temporary restore banner and clean up user interface" || true
git push origin main || true

echo "=========================================================="
echo "🎉 ГОТОВО! Інтерфейс очищено: жодних банерів відновлення."
echo "   Твій баланс та скіни надійно збережені в акаунті!"
echo "=========================================================="
