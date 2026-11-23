#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v16: ПІДТВЕРДЖЕННЯ ПРОДАЖУ СКІНІВ + СТОРІНКА ПОПОВНЕННЯ БАЛАНСУ (+)"
echo "=========================================================="

# 1. Оновлення app/components/site-header.tsx:
# Додано кнопку плюса [+] біля балансу GC для переходу на сторінку поповнення /topup
cat << 'EOF' > app/components/site-header.tsx
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
          {/* Логотип */}
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

          {/* Навігація */}
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

          {/* Права частина: Баланс з кнопкою плюса [+] + Авторизація / Профіль */}
          <div className="flex items-center gap-3">
            {/* Баланс GC з інтегрованою кнопкою плюса [+] для поповнення */}
            <div className="flex items-center rounded-xl border border-emerald-500/30 bg-emerald-500/10 p-1 font-mono text-xs font-black text-emerald-300 shadow-[0_0_15px_rgba(16,185,129,0.15)]">
              <div className="flex items-center gap-1.5 px-2.5 py-0.5">
                <span className="text-emerald-400">🪙</span>
                <span>{balance.toLocaleString("uk-UA")} GC</span>
              </div>
              <Link
                href="/topup"
                title="Поповнити баланс GoiCoins (+)"
                className="flex size-6 items-center justify-center rounded-lg bg-emerald-500 hover:bg-emerald-400 text-[#05130d] font-black text-sm shadow shadow-emerald-500/30 hover:scale-105 active:scale-95 transition ml-1"
              >
                +
              </Link>
            </div>

            {/* Користувач / Кнопки входу */}
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
                  <svg
                    className={`size-3.5 text-slate-400 transition-transform ${showDropdown ? "rotate-180" : ""}`}
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                  </svg>
                </button>

                {/* Dropdown меню */}
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

      {/* Модальне вікно авторизації */}
      <AuthModal
        isOpen={isAuthOpen}
        initialTab={authTab}
        onClose={() => setIsAuthOpen(false)}
      />
    </>
  );
}
EOF

# 2. Оновлення app/inventory/page.tsx:
# Обов'язкове модальне вікно підтвердження перед продажем БУДЬ-ЯКОГО скіна або всього інвентаря
cat << 'EOF' > app/inventory/page.tsx
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

  // Стейт для модальних вікон підтвердження продажу
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
    setTimeout(() => {
      setToastMessage(null);
    }, 3000);
  };

  // 1. Запит на продаж одного скіна (відкриває модалку)
  const requestSellSkin = (item: InventoryItem) => {
    playClickSound();
    setSkinToSell(item);
  };

  // 2. Підтверджений продаж одного скіна
  const executeSellSkin = () => {
    if (!skinToSell) return;
    playCoinSound();
    const { newInventory, newBalance } = sellInventorySkin(skinToSell);
    setInventory(newInventory);
    setBalance(newBalance);
    showToast(`💰 Продано ${skinToSell.weapon} | ${skinToSell.name} за +${formatCoins(skinToSell.price)} GC!`);
    setSkinToSell(null);
  };

  // 3. Запит на продаж всього інвентаря (відкриває модалку)
  const requestSellAll = () => {
    if (inventory.length === 0) return;
    playClickSound();
    setConfirmSellAll(true);
  };

  // 4. Підтверджений продаж всього інвентаря
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
      {/* Спливаюче сповіщення про продаж */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 rounded-2xl border border-emerald-500/40 bg-[#0d1614]/95 px-5 py-3 text-sm font-bold text-emerald-300 shadow-2xl backdrop-blur-md animate-fade-in">
          {toastMessage}
        </div>
      )}

      {/* Верхня панель профілю та балансу */}
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

      {/* Банер реєстрації для гостьового користувача */}
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

      {/* Панель дій над інвентарем */}
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

      {/* Сітка предметів Widescreen */}
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
              {/* Рідкість та ціна */}
              <div className="flex items-center justify-between text-[10px]">
                <span
                  className="rounded px-1.5 py-0.5 font-bold uppercase tracking-wider"
                  style={{
                    backgroundColor: `${item.accent}20`,
                    color: item.accent,
                  }}
                >
                  {item.rarity}
                </span>
                <span className="font-mono font-bold text-emerald-400">
                  {formatCoins(item.price)} GC
                </span>
              </div>

              {/* Зображення зброї */}
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

              {/* Назва та знос */}
              <div>
                <p className="text-[11px] font-semibold text-slate-400">{item.weapon}</p>
                <p className="truncate text-xs font-black text-white group-hover:text-emerald-300 transition">
                  {item.name}
                </p>
                <p className="text-[10px] text-slate-500">{item.wear}</p>
              </div>

              {/* Кнопки дій */}
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

      {/* ⚠️ МОДАЛЬНЕ ВІКНО ПІДТВЕРДЖЕННЯ ПРОДАЖУ ОДНОГО СКІНА */}
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

            {/* Картка скіна */}
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

            {/* Кнопки дій */}
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

      {/* ⚠️ МОДАЛЬНЕ ВІКНО ПІДТВЕРДЖЕННЯ ПРОДАЖУ ВСЬОГО ІНВЕНТАРЯ */}
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
EOF

# 3. Створення інтерактивної сторінки поповнення балансу app/topup/page.tsx:
# Щоденний бонус, секретні промокоди та віртуальний Faucet-симулятор поповнення
cat << 'EOF' > app/topup/page.tsx
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

    // Завантаження використаних промокодів
    try {
      const rawPromos = localStorage.getItem("goicoins_used_promos");
      if (rawPromos) setUsedPromos(JSON.parse(rawPromos));
    } catch {}

    // Перевірка щоденного бонусу
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

  // 1. Отримання щоденного бонусу
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

  // 2. Активація промокоду
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

  // 3. Миттєве поповнення демо-пакетом
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

      {/* Верхній банер балансу */}
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
        {/* БЛОК 1: Щоденний безкоштовний бонус */}
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

        {/* БЛОК 2: Активація промокодів */}
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

        {/* БЛОК 3: Як ще заробити монети */}
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

      {/* БЛОК 4: Віртуальні пакети поповнення Faucet */}
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
EOF

# 4. Створення аліасу app/deposit/page.tsx для зручності
cat << 'EOF' > app/deposit/page.tsx
import { redirect } from "next/navigation";

export default function DepositPage() {
  redirect("/topup");
}
EOF

# 5. Запуск компіляції та тестів
echo "⚡ Запускаємо npm run build та vitest..."
npm run build
npm test

echo "⚡ Зберігаємо зміни у Git..."
git add .
git commit -m "feat(economy): sell confirmation modal and interactive topup page with plus button" || true
git push origin main || true

echo "=========================================================="
echo "🎉 v16 УСПІШНО ЗАВЕРШЕНО! Підтвердження продажу та сторінка поповнення готові!"
echo "=========================================================="
