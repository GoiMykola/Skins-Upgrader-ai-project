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

  const totalValue = inventory.reduce((acc, s) => acc + s.price, 0);

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

      <div className="mb-6 overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 sm:p-8 shadow-xl">
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div className="flex items-center gap-4">
            <div className="flex size-16 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 text-2xl font-black text-[#05130d] shadow-lg shadow-emerald-500/20">
              {user?.avatar || "G"}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-2xl font-black text-white">
                  Гравець {user?.nickname || "Гість (demo-player)"}
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
              className="rounded-xl border border-amber-500/30 bg-amber-500/10 px-4 py-2 text-xs font-black text-amber-300 hover:bg-amber-500/20 transition"
            >
              💰 Продати весь інвентар ({formatCoins(totalValue)} GC)
            </button>
          )}
          <Link
            href="/topup"
            className="rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-2 text-xs font-bold text-emerald-300 hover:bg-emerald-500/20 transition"
          >
            Поповнити баланс (+) 🪙
          </Link>
          <Link
            href="/market"
            className="rounded-xl border border-white/10 bg-white/5 px-4 py-2 text-xs font-bold text-slate-300 hover:bg-white/10 transition"
          >
            Ринок скінів (2.2к) 🛒
          </Link>
          <Link
            href="/"
            className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-4 py-2 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition"
          >
            До Апгрейдера ⚡
          </Link>
        </div>
      </div>

      {inventory.length === 0 ? (
        <div className="flex flex-col items-center justify-center rounded-3xl border border-dashed border-white/10 bg-[#0c0f17] py-20 text-center">
          <div className="text-4xl">🎒</div>
          <h3 className="mt-4 text-xl font-bold text-white">Твій інвентар порожній</h3>
          <p className="mt-1 max-w-sm text-xs text-slate-400">
            Всі скіни було продано або програно в рулетці. Відвідай Ринок, поповни баланс або отримай щоденний бонус!
          </p>
          <div className="mt-6 flex flex-wrap gap-3 justify-center">
            <Link
              href="/topup"
              className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-6 py-2.5 text-xs font-black text-[#05130d] shadow-lg transition"
            >
              Отримати монети (+) 🪙
            </Link>
            <Link
              href="/market"
              className="rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 px-6 py-2.5 text-xs font-bold text-slate-300 transition"
            >
              Перейти на Ринок CS2 →
            </Link>
          </div>
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
                  style={{ backgroundColor: `${item.accent}20`, color: item.accent }}
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
                  style={{ backgroundColor: item.accent }}
                />
                <SkinArt
                  image={item.image}
                  name={item.name}
                  weapon={item.weapon}
                  accent={item.accent}
                  finish={item.finish}
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
                  style={{ backgroundColor: skinToSell.accent }}
                />
                <SkinArt
                  image={skinToSell.image}
                  name={skinToSell.name}
                  weapon={skinToSell.weapon}
                  accent={skinToSell.accent}
                  finish={skinToSell.finish}
                  className="h-20 w-full object-contain drop-shadow-lg"
                />
              </div>
              <p className="mt-2 text-xs font-semibold text-slate-400">{skinToSell.weapon}</p>
              <p className="text-base font-black text-white">{skinToSell.name}</p>
              <div className="mt-1 flex items-center justify-center gap-2 text-[11px]">
                <span
                  className="rounded px-1.5 py-0.5 font-bold uppercase"
                  style={{ backgroundColor: `${skinToSell.accent}20`, color: skinToSell.accent }}
                >
                  {skinToSell.rarity}
                </span>
                <span className="text-slate-500">·</span>
                <span className="text-slate-400">{skinToSell.wear}</span>
              </div>
              <div className="mt-3 inline-flex items-center gap-1.5 rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-1.5 font-mono text-xs font-black text-emerald-300">
                <span>Ви отримаєте:</span>
                <span className="text-emerald-400 font-bold">+{formatCoins(skinToSell.price)} GC</span>
              </div>
            </div>

            <p className="mt-4 text-center text-[11px] text-slate-400 leading-relaxed">
              Ця дія є остаточною. Скін буде вилучено з твого інвентаря, а монети зараховано на баланс.
            </p>

            <div className="mt-5 grid grid-cols-2 gap-3">
              <button
                onClick={() => {
                  playClickSound();
                  setSkinToSell(null);
                }}
                className="rounded-xl border border-white/10 bg-white/5 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/10 hover:text-white transition"
              >
                Скасувати
              </button>
              <button
                onClick={executeSellSkin}
                className="rounded-xl bg-amber-500 hover:bg-amber-400 py-2.5 text-xs font-black text-[#05130d] shadow-lg shadow-amber-500/20 transition"
              >
                Продати (+{formatCoins(skinToSell.price)} GC) 💰
              </button>
            </div>
          </div>
        </div>
      )}

      {confirmSellAll && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
          <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-rose-500/30 bg-[#0d1018]/95 p-6 sm:p-7 shadow-[0_0_50px_rgba(244,63,94,0.18)]">
            <div className="text-center">
              <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-rose-500/20 text-2xl">
                💥
              </div>
              <h3 className="mt-3 text-xl font-black text-white">Продати весь інвентар?</h3>
              <p className="mt-1 text-xs text-slate-400">
                Увага! Ти збираєшся продати всі {inventory.length} скінів в один клік.
              </p>
            </div>

            <div className="mt-5 rounded-2xl border border-white/10 bg-black/40 p-4 text-center">
              <div className="flex items-center justify-center gap-6">
                <div>
                  <p className="text-[10px] uppercase font-bold text-slate-400">Кількість скінів</p>
                  <p className="text-lg font-black text-white">{inventory.length} шт.</p>
                </div>
                <div className="h-8 w-px bg-white/10" />
                <div>
                  <p className="text-[10px] uppercase font-bold text-slate-400">Загальна виручка</p>
                  <p className="text-lg font-black text-emerald-400">+{formatCoins(totalValue)} GC</p>
                </div>
              </div>
            </div>

            <p className="mt-4 text-center text-[11px] text-rose-300">
              Всі скіни будуть спалені, а повна сума монет одразу зарахується на твій баланс.
            </p>

            <div className="mt-5 grid grid-cols-2 gap-3">
              <button
                onClick={() => {
                  playClickSound();
                  setConfirmSellAll(false);
                }}
                className="rounded-xl border border-white/10 bg-white/5 py-2.5 text-xs font-bold text-slate-300 hover:bg-white/10 hover:text-white transition"
              >
                Скасувати
              </button>
              <button
                onClick={executeSellAll}
                className="rounded-xl bg-rose-500 hover:bg-rose-400 py-2.5 text-xs font-black text-white shadow-lg shadow-rose-500/20 transition"
              >
                Продати все (+{formatCoins(totalValue)} GC) 💥
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
