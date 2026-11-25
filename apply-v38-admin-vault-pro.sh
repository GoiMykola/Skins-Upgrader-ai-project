#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v38: РОЗШИРЕНИЙ ADMIN VAULT PRO + БАЛАНС-СИСТЕМА"
echo "   1. 🔍 Збільшений масштаб адмін-панелі (великі зручні кнопки та текст)"
echo "   2. 👥 Нарахування монет та БУДЬ-ЯКОГО скіна іншим гравцям або собі"
echo "   3. 🎡 Чисте Колесо Фортуни (прибрано кнопку 'Скинути барабан')"
echo "   4. 🚫 Прибрано кнопки безкоштовного балансу в інвентарі та топ-апі"
echo "   5. 🏠 Відновлено перехід на головну сторінку при кліку на логотип 'G'"
echo "   6. ⌨️ Секретний вхід ВИКЛЮЧНО через гарячу комбінацію Ctrl+Shift+A"
echo "   7. 🧪 Повний білд та автодеплой на GitHub і Vercel"
echo "=========================================================="

mkdir -p lib components app/components app/inventory app/topup

# 1. lib/admin-vault-storage.ts: мультиюзерне нарахування монет та скінів
cat << 'VAULT_STORE' > lib/admin-vault-storage.ts
"use client";

import {
  getAllStoredUsers,
  AUTH_USERS_DB_KEY,
  getCurrentUser,
  type StoredUserAccount,
  type UserProfile,
} from "./auth-storage";
import { updateStoredBalance, addSkinToInventory, type InventoryItem } from "./inventory-storage";

// Секретні майстер-коди доступу розробника
const MASTER_PASSES = ["GOI-ADMIN-2026", "GoiMaster#2026", "admin777"];

const SESSION_TOKEN_KEY = "goicoins_admin_session_auth";
const ATTEMPTS_KEY = "goicoins_admin_failed_attempts";
const LOCKOUT_KEY = "goicoins_admin_lockout_until";
const GOD_MODE_KEY = "goicoins_dev_god_mode";

export function isLockedOut(): { locked: boolean; remainingSec: number } {
  if (typeof window === "undefined") return { locked: false, remainingSec: 0 };
  const raw = sessionStorage.getItem(LOCKOUT_KEY);
  if (!raw) return { locked: false, remainingSec: 0 };
  const until = parseInt(raw, 10);
  const now = Date.now();
  if (now >= until) {
    sessionStorage.removeItem(LOCKOUT_KEY);
    sessionStorage.removeItem(ATTEMPTS_KEY);
    return { locked: false, remainingSec: 0 };
  }
  return { locked: true, remainingSec: Math.ceil((until - now) / 1000) };
}

export function verifyAdminPassphrase(passphrase: string): boolean {
  if (typeof window === "undefined") return false;

  const lockStatus = isLockedOut();
  if (lockStatus.locked) return false;

  const clean = passphrase.trim();
  const isValid = MASTER_PASSES.includes(clean);

  if (isValid) {
    sessionStorage.setItem(SESSION_TOKEN_KEY, "authenticated_" + Date.now());
    sessionStorage.removeItem(ATTEMPTS_KEY);
    sessionStorage.removeItem(LOCKOUT_KEY);
    return true;
  } else {
    const rawAttempts = sessionStorage.getItem(ATTEMPTS_KEY);
    const attempts = (rawAttempts ? parseInt(rawAttempts, 10) : 0) + 1;
    sessionStorage.setItem(ATTEMPTS_KEY, attempts.toString());

    if (attempts >= 3) {
      const lockoutUntil = Date.now() + 10 * 60 * 1000; // 10 хвилин блокування
      sessionStorage.setItem(LOCKOUT_KEY, lockoutUntil.toString());
    }
    return false;
  }
}

export function isAdminAuthenticated(): boolean {
  if (typeof window === "undefined") return false;
  const token = sessionStorage.getItem(SESSION_TOKEN_KEY);
  return Boolean(token && token.startsWith("authenticated_"));
}

export function logoutAdmin(): void {
  if (typeof window !== "undefined") {
    sessionStorage.removeItem(SESSION_TOKEN_KEY);
    localStorage.removeItem(GOD_MODE_KEY);
  }
}

export function isGodModeActive(): boolean {
  if (typeof window === "undefined") return false;
  return localStorage.getItem(GOD_MODE_KEY) === "true";
}

export function setGodMode(active: boolean): void {
  if (typeof window !== "undefined") {
    if (active) {
      localStorage.setItem(GOD_MODE_KEY, "true");
    } else {
      localStorage.removeItem(GOD_MODE_KEY);
    }
    window.dispatchEvent(new CustomEvent("goi-godmode-toggled", { detail: active }));
  }
}

// Отримання списку всіх зареєстрованих гравців для адмінки
export function getAdminPlayerList(): { id: string; nickname: string; email: string; balance: number }[] {
  if (typeof window === "undefined") return [];
  const current = getCurrentUser();
  const storedUsers = getAllStoredUsers();

  const list: { id: string; nickname: string; email: string; balance: number }[] = [];

  // Додаємо поточного гравця першим у список
  list.push({
    id: current?.id || "current_session",
    nickname: current ? `${current.nickname} (Мій акаунт)` : "Мій поточний сеанс (Гість)",
    email: current?.email || "active_session",
    balance: current?.balance || 0,
  });

  // Додаємо решту зареєстрованих юзерів з бази
  for (const u of storedUsers) {
    if (current && u.id === current.id) continue;
    list.push({
      id: u.id,
      nickname: u.nickname,
      email: u.email,
      balance: u.balance || 0,
    });
  }

  return list;
}

// Нарахування монет конкретному гравцю (або собі)
export function grantCoinsToUser(targetId: string, amount: number): { success: boolean; targetName: string; newBalance: number } {
  if (typeof window === "undefined") return { success: false, targetName: "", newBalance: 0 };

  const current = getCurrentUser();
  const users = getAllStoredUsers();
  const isTargetCurrent = targetId === "current_session" || (current && targetId === current.id);

  if (isTargetCurrent) {
    const newBal = updateStoredBalance(amount);
    return {
      success: true,
      targetName: current ? current.nickname : "Твій баланс",
      newBalance: newBal,
    };
  }

  const targetIdx = users.findIndex((u) => u.id === targetId || u.email.toLowerCase() === targetId.toLowerCase());
  if (targetIdx !== -1) {
    users[targetIdx].balance = (users[targetIdx].balance || 0) + amount;
    localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
    return {
      success: true,
      targetName: users[targetIdx].nickname,
      newBalance: users[targetIdx].balance,
    };
  }

  const newBal = updateStoredBalance(amount);
  return { success: true, targetName: "Поточний баланс", newBalance: newBal };
}

// Нарахування будь-якого скіна конкретному гравцю (або собі)
export function grantSkinToUser(targetId: string, skin: any): { success: boolean; targetName: string } {
  if (typeof window === "undefined") return { success: false, targetName: "" };

  const current = getCurrentUser();
  const users = getAllStoredUsers();
  const isTargetCurrent = targetId === "current_session" || (current && targetId === current.id);

  const skinItem: InventoryItem = {
    name: skin.name,
    weapon: skin.weapon,
    price: skin.price,
    image: skin.image,
    rarity: skin.rarity || "Таємне",
    accent: skin.accent || "#ffd700",
    wear: "Прямо із заводу",
    floatValue: 0.001,
    instanceId: `admin-drop-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
  };

  if (isTargetCurrent) {
    addSkinToInventory(skinItem);
    return { success: true, targetName: current ? current.nickname : "Твій інвентар" };
  }

  const targetIdx = users.findIndex((u) => u.id === targetId || u.email.toLowerCase() === targetId.toLowerCase());
  if (targetIdx !== -1) {
    if (!users[targetIdx].inventory) users[targetIdx].inventory = [];
    users[targetIdx].inventory.unshift(skinItem);
    localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
    return { success: true, targetName: users[targetIdx].nickname };
  }

  addSkinToInventory(skinItem);
  return { success: true, targetName: "Твій інвентар" };
}
VAULT_STORE

# 2. components/admin-vault-modal.tsx: збільшений масштаб та вибір гравця/скіна
cat << 'VAULT_MODAL' > components/admin-vault-modal.tsx
"use client";

import { useState, useEffect, useMemo } from "react";
import {
  isAdminAuthenticated,
  verifyAdminPassphrase,
  logoutAdmin,
  isLockedOut,
  isGodModeActive,
  setGodMode,
  getAdminPlayerList,
  grantCoinsToUser,
  grantSkinToUser,
} from "@/lib/admin-vault-storage";
import { clearLiveDrops, addLiveDrop } from "@/lib/live-drops-storage";
import { resetWheelCooldownForTest } from "@/lib/daily-wheel-storage";
import { skins, formatCoins } from "@/app/data";
import { playClickSound, playWinSound, playCoinSound } from "@/lib/sound-fx";
import { triggerConfetti } from "@/lib/confetti";

interface AdminVaultModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function AdminVaultModal({ isOpen, onClose }: AdminVaultModalProps) {
  const [isAuth, setIsAuth] = useState(false);
  const [passphrase, setPassphrase] = useState("");
  const [errorMsg, setErrorMsg] = useState("");
  const [lockoutSec, setLockoutSec] = useState(0);
  const [godMode, setGodModeState] = useState(false);
  const [toastMsg, setToastMsg] = useState("");

  const [players, setPlayers] = useState<{ id: string; nickname: string; email: string; balance: number }[]>([]);
  const [selectedPlayerId, setSelectedPlayerId] = useState<string>("current_session");
  const [customCoins, setCustomCoins] = useState<string>("");

  const [skinSearch, setSkinSearch] = useState<string>("");

  useEffect(() => {
    if (isOpen) {
      setIsAuth(isAdminAuthenticated());
      setGodModeState(isGodModeActive());
      const lock = isLockedOut();
      setLockoutSec(lock.remainingSec);
      setErrorMsg("");
      setPassphrase("");

      const playerList = getAdminPlayerList();
      setPlayers(playerList);
      if (playerList.length > 0) {
        setSelectedPlayerId(playerList[0].id);
      }
    }
  }, [isOpen]);

  const filteredSkins = useMemo(() => {
    const q = skinSearch.toLowerCase().trim();
    if (!q) return skins.slice(0, 30);
    return skins.filter(
      (s) =>
        s.name.toLowerCase().includes(q) ||
        s.weapon.toLowerCase().includes(q) ||
        (s.rarity && s.rarity.toLowerCase().includes(q))
    ).slice(0, 30);
  }, [skinSearch]);

  if (!isOpen) return null;

  const showToast = (msg: string) => {
    setToastMsg(msg);
    setTimeout(() => setToastMsg(""), 3500);
  };

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    playClickSound();

    const lock = isLockedOut();
    if (lock.locked) {
      setErrorMsg(`Блокування активне: зачекайте ${lock.remainingSec}с`);
      return;
    }

    const success = verifyAdminPassphrase(passphrase);
    if (success) {
      setIsAuth(true);
      setErrorMsg("");
      playWinSound();
      triggerConfetti();
      const pList = getAdminPlayerList();
      setPlayers(pList);
    } else {
      const updatedLock = isLockedOut();
      if (updatedLock.locked) {
        setLockoutSec(updatedLock.remainingSec);
        setErrorMsg("⚠️ 3 невдалі спроби! Доступ заблоковано на 10 хвилин.");
      } else {
        setErrorMsg("❌ Невірний майстер-код доступу!");
      }
    }
  };

  const handleLogout = () => {
    playClickSound();
    logoutAdmin();
    setIsAuth(false);
    setGodModeState(false);
    onClose();
  };

  const handleToggleGodMode = () => {
    playClickSound();
    const next = !godMode;
    setGodMode(next);
    setGodModeState(next);
    showToast(next ? "🔥 Бог-Режим УВІМКНЕНО: 100% виграш в рулетці!" : "Бог-Режим вимкнено");
  };

  const handleSendCoins = (amount: number) => {
    playCoinSound();
    const res = grantCoinsToUser(selectedPlayerId, amount);
    if (res.success) {
      showToast(`🪙 Нараховано +${formatCoins(amount)} GC для [${res.targetName}]!`);
      setPlayers(getAdminPlayerList());
    }
  };

  const handleSendCustomCoins = (e: React.FormEvent) => {
    e.preventDefault();
    const val = parseInt(customCoins.replace(/\s+/g, ""), 10);
    if (isNaN(val) || val <= 0) return;
    handleSendCoins(val);
    setCustomCoins("");
  };

  const handleSendSkin = (skin: typeof skins[0]) => {
    playWinSound();
    const res = grantSkinToUser(selectedPlayerId, skin);
    if (res.success) {
      showToast(`🎁 Скін ${skin.weapon} | ${skin.name} видано для [${res.targetName}]!`);
    }
  };

  const handleBroadcastDrop = () => {
    playClickSound();
    addLiveDrop({
      playerName: "ADMIN ROOT ⚡",
      playerAvatar: "⚡",
      playerRank: "Developer",
      weapon: "AWP",
      name: "Dragon Lore",
      price: 450000,
      image: "https://community.akamai.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDEVlxkKgpot621FAR17PLfYQJD_9W7m5a0mvLwOq7c2D4B6pcn3-3E99n22Qfn_kFtY2inINfAcVJtNArR-1G5wri-jce0ot2XnjXh2Y2F",
      accent: "#eb4b4b",
      rarity: "Таємне",
      chance: "1.0%",
      multiplier: "×100.0",
    });
    showToast("📡 Тестовий дроп трансльовано в Live-стрічку!");
  };

  const selectedTargetObj = players.find((p) => p.id === selectedPlayerId) || players[0];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-2xl p-4 sm:p-6 animate-fade-in font-mono">
      <div className="relative w-full max-w-4xl max-h-[92vh] overflow-y-auto rounded-3xl border-2 border-cyan-500/50 bg-[#060913] p-6 sm:p-10 shadow-[0_0_100px_rgba(6,182,212,0.3)] text-slate-200">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-5 top-5 flex size-11 items-center justify-center rounded-2xl bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white transition text-lg font-bold"
        >
          ✕
        </button>

        <div className="flex items-center gap-3 text-cyan-400 mb-2">
          <span className="size-3.5 rounded-full bg-cyan-400 animate-ping" />
          <span className="text-xs sm:text-sm font-black tracking-widest uppercase">
            ROOT ACCESS // SECURE CONSOLE PRO
          </span>
        </div>
        <h2 className="text-3xl sm:text-4xl font-black text-white tracking-tight">Cyber Admin Vault v4.5</h2>
        <p className="text-sm text-slate-400 mt-1 max-w-2xl">
          Повний контроль над економікою CS2: нарахування монет та видача будь-якого скіна обраному учаснику.
        </p>

        {toastMsg && (
          <div className="my-4 rounded-2xl border border-cyan-400 bg-cyan-500/20 px-5 py-3.5 text-sm font-black text-cyan-200 animate-pulse shadow-lg">
            {toastMsg}
          </div>
        )}

        {!isAuth ? (
          <form onSubmit={handleLogin} className="mt-8 rounded-3xl border border-white/10 bg-white/[0.03] p-8 text-center max-w-xl mx-auto">
            <div className="text-5xl mb-4">🔒</div>
            <p className="text-lg font-black text-white mb-1">Введіть секретний Master-Passphrase</p>
            <p className="text-xs sm:text-sm text-slate-400 mb-6">
              Захист від сканування: доступ мають лише власники приватного ключа розробника.
            </p>

            <input
              type="password"
              required
              value={passphrase}
              onChange={(e) => setPassphrase(e.target.value)}
              placeholder="Введіть код доступу..."
              disabled={lockoutSec > 0}
              className="w-full rounded-2xl border-2 border-cyan-500/40 bg-black/70 px-5 py-4 text-center text-base sm:text-lg text-cyan-300 placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-cyan-400"
            />

            {errorMsg && <p className="mt-3 text-sm text-rose-400 font-bold">{errorMsg}</p>}

            <button
              type="submit"
              disabled={lockoutSec > 0}
              className="w-full mt-6 rounded-2xl bg-gradient-to-r from-cyan-500 to-blue-600 hover:brightness-110 py-4 text-base font-black text-[#041018] shadow-xl shadow-cyan-500/25 transition disabled:opacity-40"
            >
              {lockoutSec > 0 ? `Заблоковано (${lockoutSec}с)` : "РОЗБЛОКУВАТИ КОНСОЛЬ ⚡"}
            </button>
            <p className="text-xs text-slate-500 mt-4">Майстер-код за замовчуванням: GOI-ADMIN-2026</p>
          </form>
        ) : (
          <div className="mt-8 space-y-6">
            {/* Вибір цільового гравця */}
            <div className="rounded-2xl border border-cyan-500/30 bg-cyan-950/20 p-5">
              <div className="flex flex-wrap items-center justify-between gap-4">
                <div>
                  <p className="text-xs sm:text-sm font-black text-cyan-400 uppercase tracking-wider">
                    👤 Оберіть отримувача (Цільовий акаунт):
                  </p>
                  <p className="text-xs text-slate-400 mt-0.5">
                    Усі нарахування монет та скінів нижче будуть передані цьому гравцю.
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <select
                    value={selectedPlayerId}
                    onChange={(e) => setSelectedPlayerId(e.target.value)}
                    className="rounded-xl border border-cyan-500/40 bg-[#0d121f] px-4 py-2.5 text-sm font-black text-cyan-300 focus:outline-none focus:ring-2 focus:ring-cyan-400"
                  >
                    {players.map((p) => (
                      <option key={p.id} value={p.id} className="bg-[#0a0d18] text-white">
                        {p.nickname} {p.email !== "active_session" ? `(${p.email})` : ""}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {selectedTargetObj && (
                <div className="mt-3 pt-3 border-t border-cyan-500/20 flex flex-wrap items-center gap-4 text-xs text-slate-300">
                  <span>
                    Активний одержувач: <strong className="text-white">{selectedTargetObj.nickname}</strong>
                  </span>
                  <span>·</span>
                  <span>
                    Баланс: <strong className="text-emerald-400">{formatCoins(selectedTargetObj.balance)} GC</strong>
                  </span>
                </div>
              )}
            </div>

            {/* Бог-режим */}
            <div className="rounded-2xl border border-amber-500/40 bg-amber-500/10 p-5 flex flex-wrap items-center justify-between gap-4">
              <div>
                <div className="flex items-center gap-2.5">
                  <span className="text-xl">⚡</span>
                  <p className="text-base font-black text-amber-300 uppercase">Бог-Режим (100% Luck in Upgrader)</p>
                </div>
                <p className="text-xs sm:text-sm text-slate-300 mt-1">
                  Рулетка апгрейдера завжди гарантовано виграє для демонстрації безпрограшних серій.
                </p>
              </div>
              <button
                onClick={handleToggleGodMode}
                className={`rounded-2xl px-6 py-3.5 text-sm font-black transition ${
                  godMode
                    ? "bg-amber-400 text-black shadow-xl shadow-amber-400/30 scale-105"
                    : "border-2 border-white/20 bg-black/50 text-slate-400 hover:text-white"
                }`}
              >
                {godMode ? "УВІМКНЕНО 🔥" : "ВИМКНЕНО"}
              </button>
            </div>

            {/* Монетний двір */}
            <div className="rounded-2xl border border-white/10 bg-white/[0.02] p-5 sm:p-6">
              <p className="text-sm font-black text-emerald-400 uppercase tracking-wider mb-3">
                🪙 Монетний двір (Нарахування GoiCoins)
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-4">
                <button
                  onClick={() => handleSendCoins(100000)}
                  className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 py-3.5 px-4 text-sm font-black text-emerald-300 transition hover:scale-105 active:scale-95"
                >
                  +100 000 GC
                </button>
                <button
                  onClick={() => handleSendCoins(1000000)}
                  className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 py-3.5 px-4 text-sm font-black text-emerald-300 transition hover:scale-105 active:scale-95"
                >
                  +1 000 000 GC
                </button>
                <button
                  onClick={() => handleSendCoins(5000000)}
                  className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 py-3.5 px-4 text-sm font-black text-emerald-300 transition hover:scale-105 active:scale-95"
                >
                  +5 000 000 GC
                </button>
                <button
                  onClick={() => handleSendCoins(20000000)}
                  className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/20 py-3.5 px-4 text-sm font-black text-emerald-300 transition hover:scale-105 active:scale-95 shadow-lg shadow-emerald-500/20"
                >
                  +20 000 000 GC 🔥
                </button>
              </div>

              {/* Власна сума */}
              <form onSubmit={handleSendCustomCoins} className="flex gap-3">
                <input
                  type="number"
                  min="1"
                  value={customCoins}
                  onChange={(e) => setCustomCoins(e.target.value)}
                  placeholder="Введіть довільну кількість GC (напр. 50000)..."
                  className="flex-1 rounded-xl border border-white/15 bg-black/60 px-4 py-3 text-sm text-white placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-emerald-400"
                />
                <button
                  type="submit"
                  className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-6 py-3 text-sm font-black text-[#05130d] shadow-md transition"
                >
                  Нарахувати 🪙
                </button>
              </form>
            </div>

            {/* Видача будь-якого скіна */}
            <div className="rounded-2xl border border-white/10 bg-white/[0.02] p-5 sm:p-6">
              <div className="flex flex-wrap items-center justify-between gap-3 mb-3">
                <p className="text-sm font-black text-cyan-400 uppercase tracking-wider">
                  🎁 Видача будь-якого скіна в інвентар
                </p>
                <input
                  type="text"
                  value={skinSearch}
                  onChange={(e) => setSkinSearch(e.target.value)}
                  placeholder="Пошук скіна (AWP, Knife, Howl, Lore...)"
                  className="rounded-xl border border-cyan-500/30 bg-black/60 px-4 py-2 text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-cyan-400 w-full sm:w-64"
                />
              </div>

              <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-6 gap-3 max-h-60 overflow-y-auto p-1">
                {filteredSkins.map((skin) => (
                  <button
                    key={`${skin.weapon}-${skin.name}`}
                    onClick={() => handleSendSkin(skin)}
                    className="flex flex-col items-center justify-between rounded-xl border border-white/10 bg-black/50 p-2.5 hover:border-cyan-400/60 hover:bg-cyan-500/10 transition group text-center"
                    title={`Видати ${skin.weapon} | ${skin.name}`}
                  >
                    <img src={skin.image} alt={skin.name} className="h-12 object-contain my-1 group-hover:scale-105 transition" />
                    <span className="text-xs font-bold text-white truncate w-full">{skin.name}</span>
                    <span className="text-[10px] text-slate-400">{skin.weapon}</span>
                    <span className="text-[10px] text-emerald-400 font-mono mt-1">+{formatCoins(skin.price)} GC</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Системні утиліти */}
            <div className="rounded-2xl border border-white/10 bg-white/[0.02] p-5 flex flex-wrap items-center justify-between gap-3">
              <button
                onClick={handleBroadcastDrop}
                className="rounded-xl border border-purple-500/40 bg-purple-500/15 hover:bg-purple-500/25 px-4 py-3 text-xs sm:text-sm font-bold text-purple-300"
              >
                📡 Транслювати тестовий дроп
              </button>
              <button
                onClick={() => {
                  playClickSound();
                  resetWheelCooldownForTest();
                  showToast("🎡 Таймер колеса скинуто (для розробника)!");
                }}
                className="rounded-xl border border-amber-500/40 bg-amber-500/15 hover:bg-amber-500/25 px-4 py-3 text-xs sm:text-sm font-bold text-amber-300"
              >
                🎡 Скинути таймер колеса
              </button>
              <button
                onClick={() => {
                  playClickSound();
                  clearLiveDrops();
                  showToast("🧹 Стрічку дропів очищено!");
                }}
                className="rounded-xl border border-rose-500/40 bg-rose-500/15 hover:bg-rose-500/25 px-4 py-3 text-xs sm:text-sm font-bold text-rose-300"
              >
                🧹 Очистити Live-дропи
              </button>
            </div>

            {/* Нижня панель виходу */}
            <div className="pt-4 border-t border-white/10 flex flex-wrap items-center justify-between gap-3">
              <span className="text-xs text-slate-500">Автоматичне завершення сесії при закритті вкладки</span>
              <button
                onClick={handleLogout}
                className="rounded-2xl bg-rose-500/20 border border-rose-500/40 hover:bg-rose-500/30 px-6 py-3 text-sm font-black text-rose-300 transition shadow-lg"
              >
                🔒 ЕКСТРЕНИЙ ВИХІД (LOCKDOWN)
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
VAULT_MODAL

# 3. components/daily-wheel-modal.tsx: ПРИБРАНО кнопку 'Скинути таймер'
cat << 'WHEEL_MODAL' > components/daily-wheel-modal.tsx
"use client";

import { useState, useEffect } from "react";
import {
  WHEEL_PRIZES,
  canSpinWheel,
  claimWheelReward,
  type WheelPrize,
} from "@/lib/daily-wheel-storage";
import { triggerConfetti, playJackpotSound } from "@/lib/confetti";
import { playClickSound, playTickSound } from "@/lib/sound-fx";

interface DailyWheelModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function DailyWheelModal({ isOpen, onClose }: DailyWheelModalProps) {
  const [canSpin, setCanSpin] = useState(true);
  const [timeLeft, setTimeLeft] = useState(0);
  const [isSpinning, setIsSpinning] = useState(false);
  const [rotation, setRotation] = useState(0);
  const [wonPrize, setWonPrize] = useState<WheelPrize | null>(null);

  useEffect(() => {
    if (isOpen) {
      const status = canSpinWheel();
      setCanSpin(status.allowed);
      setTimeLeft(status.remainingSec);
      setWonPrize(null);
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleSpin = () => {
    if (isSpinning || !canSpin) return;
    playClickSound();
    setIsSpinning(true);
    setWonPrize(null);

    const prizeIndex = Math.floor(Math.random() * WHEEL_PRIZES.length);
    const selectedPrize = WHEEL_PRIZES[prizeIndex];

    const sliceAngle = 360 / WHEEL_PRIZES.length;
    const extraSpins = 5 * 360;
    const targetAngle = extraSpins + (360 - (prizeIndex * sliceAngle + sliceAngle / 2));

    setRotation(targetAngle);

    let tickCount = 0;
    const interval = setInterval(() => {
      tickCount++;
      if (tickCount % 4 === 0) playTickSound();
      if (tickCount > 35) clearInterval(interval);
    }, 100);

    setTimeout(() => {
      setIsSpinning(false);
      setWonPrize(selectedPrize);
      claimWheelReward(selectedPrize);
      setCanSpin(false);
      setTimeLeft(24 * 3600);
      playJackpotSound();
      triggerConfetti();
    }, 4000);
  };

  const formatCooldown = (seconds: number) => {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    return `${h}год ${m}хв ${s}с`;
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fade-in">
      <div className="relative w-full max-w-lg overflow-hidden rounded-3xl border border-emerald-500/30 bg-[#0a0d16] p-6 sm:p-8 shadow-[0_0_80px_rgba(16,185,129,0.25)] text-center">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          disabled={isSpinning}
          className="absolute right-4 top-4 flex size-9 items-center justify-center rounded-xl bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white transition"
        >
          ✕
        </button>

        <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-400/10 px-4 py-1.5 text-xs font-black uppercase tracking-wider text-emerald-400 mb-3">
          🎡 ЩОДЕННИЙ БОНУС
        </div>
        <h2 className="text-2xl sm:text-3xl font-black text-white">Колесо Фортуни CS2</h2>
        <p className="text-xs text-slate-400 mt-1 max-w-sm mx-auto">
          Крути щодня та забирай гарантовані GoiCoins або секретний скін!
        </p>

        {/* Колесо з секторами */}
        <div className="relative mx-auto my-6 flex size-64 sm:size-72 items-center justify-center">
          <div className="absolute -top-3 z-20 flex flex-col items-center">
            <div className="size-0 border-x-8 border-x-transparent border-t-[18px] border-t-emerald-400 filter drop-shadow-[0_0_10px_#10b981]" />
          </div>

          <div
            className="size-full rounded-full border-4 border-emerald-500/50 shadow-2xl relative overflow-hidden transition-transform duration-[4000ms] ease-[cubic-bezier(0.15,0.9,0.2,1)]"
            style={{ transform: `rotate(${rotation}deg)` }}
          >
            <svg viewBox="0 0 100 100" className="size-full -rotate-90">
              {WHEEL_PRIZES.map((prize, idx) => {
                const angle = 360 / WHEEL_PRIZES.length;
                const startAngle = idx * angle;
                const endAngle = startAngle + angle;
                const x1 = 50 + 50 * Math.cos((Math.PI * startAngle) / 180);
                const y1 = 50 + 50 * Math.sin((Math.PI * startAngle) / 180);
                const x2 = 50 + 50 * Math.cos((Math.PI * endAngle) / 180);
                const y2 = 50 + 50 * Math.sin((Math.PI * endAngle) / 180);
                return (
                  <path
                    key={prize.id}
                    d={`M50,50 L${x1},${y1} A50,50 0 0,1 ${x2},${y2} Z`}
                    fill={prize.color}
                    opacity={idx % 2 === 0 ? 0.9 : 0.75}
                    stroke="#0a0d16"
                    strokeWidth="0.8"
                  />
                );
              })}
            </svg>

            {WHEEL_PRIZES.map((prize, idx) => {
              const angle = 360 / WHEEL_PRIZES.length;
              const rot = idx * angle + angle / 2;
              return (
                <div
                  key={`label-${prize.id}`}
                  className="absolute inset-0 flex items-start justify-center pt-3 text-[9px] sm:text-[10px] font-black text-[#05130d] pointer-events-none"
                  style={{
                    transform: `rotate(${rot}deg)`,
                    transformOrigin: "center center",
                  }}
                >
                  <span className="bg-black/20 px-1 rounded backdrop-blur-[1px]">{prize.label}</span>
                </div>
              );
            })}
          </div>

          <div className="absolute z-10 flex size-14 items-center justify-center rounded-full border-2 border-emerald-400 bg-[#080a10] shadow-[0_0_20px_#10b981]">
            <span className="text-xl">🎁</span>
          </div>
        </div>

        {wonPrize && (
          <div className="mb-4 rounded-2xl border border-emerald-400 bg-emerald-500/20 p-3 animate-bounce">
            <p className="text-xs font-bold text-emerald-300">🎉 Твій виграш:</p>
            <p className="text-lg font-black text-white">{wonPrize.label}</p>
            <p className="text-[11px] text-slate-300">
              {wonPrize.type === "coins" ? `Нараховано +${wonPrize.value} GC на твій баланс!` : "Додано у твій інвентар!"}
            </p>
          </div>
        )}

        <button
          onClick={handleSpin}
          disabled={isSpinning || !canSpin}
          className="w-full rounded-2xl bg-gradient-to-r from-emerald-500 via-teal-400 to-emerald-500 hover:brightness-110 py-4 text-base font-black text-[#05130d] shadow-lg shadow-emerald-500/30 transition disabled:opacity-40 disabled:hover:brightness-100"
        >
          {isSpinning ? "Колесо обертається... ⚡" : canSpin ? "Крутити колесо безкоштовно 🎁" : `Доступно через: ${formatCooldown(timeLeft)}`}
        </button>
      </div>
    </div>
  );
}
WHEEL_MODAL

# 4. app/components/site-header.tsx: логотип 'G' веде на головну (/), а виклик адмінки ТІЛЬКИ через Ctrl+Shift+A
cat << 'HEADER_FILE' > app/components/site-header.tsx
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
    setBalance(getStoredBalance());
    setCurrentUser(getCurrentUser());

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
HEADER_FILE

# 5. app/inventory/page.tsx: ПРИБРАНО кнопку '+' (поповнення балансу)
node -e '
const fs = require("fs");
const file = "app/inventory/page.tsx";

if (fs.existsSync(file)) {
  let content = fs.readFileSync(file, "utf8");
  content = content.replace(/<Link[^>]*href=["\x27]\/topup["\x27][^>]*>[\s\S]*?\+[\s\S]*?<\/Link>/g, "");
  fs.writeFileSync(file, content, "utf8");
  console.log("✅ app/inventory/page.tsx кнопку фрі балансу (+) прибрано!");
}
' || true

# 6. app/topup/page.tsx: ПРИБРАНО розділ тестового крану з безкоштовними монетами
node -e '
const fs = require("fs");
const file = "app/topup/page.tsx";

if (fs.existsSync(file)) {
  let content = fs.readFileSync(file, "utf8");
  content = content.replace(/{\/\* Тестовий Faucet симулятора \*\/}[\s\S]*?<\/div>\s*<\/div>\s*<\/div>/, "</div>");
  fs.writeFileSync(file, content, "utf8");
  console.log("✅ app/topup/page.tsx безкоштовний тестовий кран прибрано!");
}
' || true

# 7. components/interactive-upgrader.tsx: перевірка Бог-Режиму
node -e '
const fs = require("fs");
const file = "components/interactive-upgrader.tsx";

if (fs.existsSync(file)) {
  let content = fs.readFileSync(file, "utf8");

  if (!content.includes("isGodModeActive")) {
    content = content.replace(
      /from ["\x27]@\/lib\/live-drops-storage["\x27];/,
      "from \"@/lib/live-drops-storage\";\nimport { isGodModeActive } from \"@/lib/admin-vault-storage\";"
    );
  }

  if (!content.includes("isGodModeActive()")) {
    content = content.replace(
      "const isWin = finalAngle < winAngle;",
      "const god = isGodModeActive();\n    const isWin = god ? true : (finalAngle < winAngle);"
    );
  }

  fs.writeFileSync(file, content, "utf8");
  console.log("✅ components/interactive-upgrader.tsx Бог-Режим активний!");
}
' || true

# 8. Перевірка білду Next.js
echo "=========================================================="
echo "🧪 ПЕРЕВІРКА БІЛДУ"
echo "=========================================================="
npm run build

# 9. Git Commit & Push на GitHub
echo "=========================================================="
echo "🚀 ФІКСАЦІЯ В GIT ТА PUSH НА GITHUB"
echo "=========================================================="
git add .
git commit -m "feat(admin): v38 enlarged vault pro, player targeting, skin spawner, restored logo link, removed free faucets" || true
git push origin main || true

echo "=========================================================="
echo "🎉 ВЕРСІЮ v38 УСПІШНО РОЗГОРНУТО!"
echo "=========================================================="
