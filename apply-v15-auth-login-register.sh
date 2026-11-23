#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v15: РЕЄСТРАЦІЯ ТА ВХІД ЗА ПОШТОЮ (GoiCoins Auth & Profiles)"
echo "=========================================================="

# 1. Створення lib/auth-storage.ts: повноцінна система автентифікації та профілів користувачів
cat << 'INNER_EOF' > lib/auth-storage.ts
"use client";

import type { InventoryItem } from "./inventory-storage";

export interface UserProfile {
  id: string;
  email: string;
  nickname: string;
  avatar: string;
  balance: number;
  rank: string;
  createdAt: number;
}

export interface StoredUserAccount extends UserProfile {
  password: string;
  inventory: InventoryItem[];
}

export interface AuthResult {
  success: boolean;
  message?: string;
  user?: UserProfile;
}

export const AUTH_USER_KEY = "goicoins_current_user";
export const AUTH_USERS_DB_KEY = "goicoins_users_db";
export const STARTER_REGISTRATION_BONUS_GC = 2500;

export const STARTER_REGISTRATION_SKINS = [
  {
    name: "Neon Rider",
    weapon: "AK-47",
    wear: "Прямо із заводу",
    price: 4200,
    rarity: "Таємне",
    accent: "#ec4899",
    finish: "neon-rider",
    kind: "rifle" as const,
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwhFQyvj8V7p8POXfDWadweB-Xxa_nRwvpnfSwNv7IHiQPFp1DYVyEbZY5xnrxtPjM7vnsgH_2o1A3t3x73z9yF-xW-I",
  },
  {
    name: "Hyper Beast",
    weapon: "AWP",
    wear: "Після польових",
    price: 2800,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "hyper-beast",
    kind: "sniper" as const,
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_jdk7uW-V6x0MPWBMWWVwP1ij-1gSCGn20pxtm_WzNuoeHKeaFAnCZUiTe5bt0HqxofmZOrm5Q2IjoMQzS_5iShXrnE8NzWs__c",
  },
  {
    name: "Printstream",
    weapon: "Desert Eagle",
    wear: "Прямо із заводу",
    price: 1950,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "printstream-deagle",
    kind: "pistol" as const,
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_DVL0OK8Yap5M-SBC2ad_uJ_t-l9AX_qlk4k5GyAzo6ocC-QZgZxX8AjEbZY5xnrxtPjM7vnsgGIj9oTmXngznQeg3pfcPs",
  },
  {
    name: "Kill Confirmed",
    weapon: "USP-S",
    wear: "Трохи поношене",
    price: 1800,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "kill-confirmed",
    kind: "pistol" as const,
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwhFQyvj8V7p8POXfDWadweB-Xxa_nRwvpnfSwNv7IHiQPFp1DYVyEbZY5xnrxtPjM7vnsgH_2o1A3t3x73z9yF-xW-I",
  },
];

export function getCurrentUser(): UserProfile | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = localStorage.getItem(AUTH_USER_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

export function getAllStoredUsers(): StoredUserAccount[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem(AUTH_USERS_DB_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

export function registerUser(email: string, nickname: string, password: string): AuthResult {
  if (typeof window === "undefined") return { success: false, message: "Серверне середовище" };

  const cleanEmail = email.trim().toLowerCase();
  const cleanNickname = nickname.trim();

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(cleanEmail)) {
    return { success: false, message: "Введіть коректну електронну пошту (наприклад: player@cs2goi.ua)!" };
  }

  if (cleanNickname.length < 2) {
    return { success: false, message: "Ігровий нікнейм повинен містити не менше 2 символів!" };
  }

  if (password.length < 6) {
    return { success: false, message: "Пароль повинен містити щонайменше 6 символів!" };
  }

  const users = getAllStoredUsers();
  if (users.some((u) => u.email.toLowerCase() === cleanEmail)) {
    return { success: false, message: "Користувач із цією поштою вже зареєстрований! Увійдіть у свій акаунт." };
  }

  const starterInventory: InventoryItem[] = STARTER_REGISTRATION_SKINS.map((s, idx) => ({
    ...s,
    instanceId: `user-starter-${s.finish}-${Date.now()}-${idx}-${Math.random().toString(36).substring(2, 6)}`,
  }));

  const initials = cleanNickname.length >= 2
    ? cleanNickname.substring(0, 2).toUpperCase()
    : cleanNickname.substring(0, 1).toUpperCase();

  const newAccount: StoredUserAccount = {
    id: "gp_" + Math.random().toString(36).substring(2, 9),
    email: cleanEmail,
    nickname: cleanNickname,
    avatar: initials,
    balance: STARTER_REGISTRATION_BONUS_GC,
    rank: "Global Elite",
    createdAt: Date.now(),
    password,
    inventory: starterInventory,
  };

  users.push(newAccount);
  localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));

  const profile: UserProfile = {
    id: newAccount.id,
    email: newAccount.email,
    nickname: newAccount.nickname,
    avatar: newAccount.avatar,
    balance: newAccount.balance,
    rank: newAccount.rank,
    createdAt: newAccount.createdAt,
  };

  localStorage.setItem(AUTH_USER_KEY, JSON.stringify(profile));
  localStorage.setItem("goicoins_balance_v3", newAccount.balance.toString());
  localStorage.setItem("goicoins_inventory_v3", JSON.stringify(starterInventory));

  window.dispatchEvent(new CustomEvent("goi-auth-updated", { detail: profile }));
  window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: newAccount.balance }));
  window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: starterInventory }));

  return {
    success: true,
    user: profile,
    message: `Вітаємо, ${cleanNickname}! Тобі нараховано +${STARTER_REGISTRATION_BONUS_GC.toLocaleString("uk-UA")} GC та 4 скіни!`,
  };
}

export function loginUser(email: string, password: string): AuthResult {
  if (typeof window === "undefined") return { success: false, message: "Серверне середовище" };

  const cleanEmail = email.trim().toLowerCase();
  const users = getAllStoredUsers();

  let user = users.find((u) => u.email.toLowerCase() === cleanEmail);

  if (!user && (cleanEmail === "demo@cs2goi.ua" || cleanEmail === "admin@cs2goi.ua")) {
    return registerUser(cleanEmail, "GoiMaster", password || "123456");
  }

  if (!user) {
    return {
      success: false,
      message: "Користувача з такою поштою не знайдено. Перевірте адресу або зареєструйтесь!",
    };
  }

  if (user.password !== password) {
    return {
      success: false,
      message: "Невірний пароль! Перевірте правильність введених даних.",
    };
  }

  const profile: UserProfile = {
    id: user.id,
    email: user.email,
    nickname: user.nickname,
    avatar: user.avatar,
    balance: user.balance,
    rank: user.rank,
    createdAt: user.createdAt,
  };

  localStorage.setItem(AUTH_USER_KEY, JSON.stringify(profile));
  localStorage.setItem("goicoins_balance_v3", user.balance.toString());
  localStorage.setItem("goicoins_inventory_v3", JSON.stringify(user.inventory || []));

  window.dispatchEvent(new CustomEvent("goi-auth-updated", { detail: profile }));
  window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: user.balance }));
  window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: user.inventory || [] }));

  return {
    success: true,
    user: profile,
    message: `Раді бачити, ${user.nickname}! Дані синхронізовано.`,
  };
}

export function logoutUser(): void {
  if (typeof window === "undefined") return;

  const currentUser = getCurrentUser();
  if (currentUser) {
    const users = getAllStoredUsers();
    const idx = users.findIndex((u) => u.id === currentUser.id);
    if (idx !== -1) {
      try {
        const curBalRaw = localStorage.getItem("goicoins_balance_v3");
        const curInvRaw = localStorage.getItem("goicoins_inventory_v3");
        if (curBalRaw) users[idx].balance = parseInt(curBalRaw, 10);
        if (curInvRaw) users[idx].inventory = JSON.parse(curInvRaw);
        localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
      } catch {}
    }
  }

  localStorage.removeItem(AUTH_USER_KEY);
  window.dispatchEvent(new CustomEvent("goi-auth-updated", { detail: null }));
}

export function syncUserBalance(newBalance: number) {
  if (typeof window === "undefined") return;
  const current = getCurrentUser();
  if (!current) return;
  current.balance = newBalance;
  localStorage.setItem(AUTH_USER_KEY, JSON.stringify(current));

  const users = getAllStoredUsers();
  const idx = users.findIndex((u) => u.id === current.id);
  if (idx !== -1) {
    users[idx].balance = newBalance;
    localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
  }
}

export function syncUserInventory(newInventory: InventoryItem[]) {
  if (typeof window === "undefined") return;
  const current = getCurrentUser();
  if (!current) return;

  const users = getAllStoredUsers();
  const idx = users.findIndex((u) => u.id === current.id);
  if (idx !== -1) {
    users[idx].inventory = newInventory;
    localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
  }
}
INNER_EOF

# 2. Оновлення lib/inventory-storage.ts
cat << 'INNER_EOF' > lib/inventory-storage.ts
"use client";

import { skins, inventorySkins, type Skin } from "@/app/data";
import { syncUserBalance, syncUserInventory } from "./auth-storage";

export type InventoryItem = Skin & { instanceId: string };

const INVENTORY_STORAGE_KEY = "goicoins_inventory_v3";
const BALANCE_STORAGE_KEY = "goicoins_balance_v3";

export function getStoredInventory(): InventoryItem[] {
  if (typeof window === "undefined") {
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  }
  try {
    const raw = localStorage.getItem(INVENTORY_STORAGE_KEY);
    if (!raw) {
      const initial = inventorySkins.map((s, idx) => ({
        ...s,
        instanceId: `default-${s.finish}-${idx}-${Date.now()}-${Math.random().toString(36).substring(2, 6)}`,
      }));
      localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(initial));
      return initial;
    }
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed) && parsed.length > 0) {
      return parsed.map((item: Skin & { instanceId?: string }, idx: number) => ({
        ...item,
        instanceId:
          item.instanceId ||
          `item-${item.finish || "skin"}-${idx}-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
      }));
    }
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  } catch {
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  }
}

export function addSkinToInventory(newSkin: Skin): InventoryItem[] {
  if (typeof window === "undefined") return [];
  try {
    const current = getStoredInventory();
    const newItem: InventoryItem = {
      ...newSkin,
      instanceId: `won-${newSkin.finish || "skin"}-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
    };
    const updated = [newItem, ...current];
    localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(updated));
    syncUserInventory(updated);
    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: updated }));
    return updated;
  } catch {
    return [];
  }
}

export function removeSkinFromInventory(instanceId: string): InventoryItem[] {
  if (typeof window === "undefined") return [];
  try {
    const current = getStoredInventory();
    const updated = current.filter((s) => s.instanceId !== instanceId);
    localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(updated));
    syncUserInventory(updated);
    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: updated }));
    return updated;
  } catch {
    return [];
  }
}

export function replaceSkinInInventory(oldInstanceId: string, newSkin: Skin): InventoryItem[] {
  if (typeof window === "undefined") return [];
  try {
    const current = getStoredInventory();
    const remaining = current.filter((s) => s.instanceId !== oldInstanceId);
    const newItem: InventoryItem = {
      ...newSkin,
      instanceId: `won-${newSkin.finish || "skin"}-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
    };
    const updated = [newItem, ...remaining];
    localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(updated));
    syncUserInventory(updated);
    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: updated }));
    return updated;
  } catch {
    return [];
  }
}

export function sellInventorySkin(item: InventoryItem): { newInventory: InventoryItem[]; newBalance: number } {
  const newInventory = removeSkinFromInventory(item.instanceId);
  const newBalance = updateStoredBalance(item.price);
  return { newInventory, newBalance };
}

export function sellAllInventorySkins(): { count: number; totalGained: number; newBalance: number } {
  if (typeof window === "undefined") return { count: 0, totalGained: 0, newBalance: 1500 };
  const current = getStoredInventory();
  if (current.length === 0) return { count: 0, totalGained: 0, newBalance: getStoredBalance() };
  const totalGained = current.reduce((sum, s) => sum + s.price, 0);
  const newBalance = updateStoredBalance(totalGained);
  localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify([]));
  syncUserInventory([]);
  window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: [] }));
  return { count: current.length, totalGained, newBalance };
}

export function getStoredBalance(): number {
  if (typeof window === "undefined") return 1500;
  try {
    const raw = localStorage.getItem(BALANCE_STORAGE_KEY);
    return raw ? parseInt(raw, 10) : 1500;
  } catch {
    return 1500;
  }
}

export function updateStoredBalance(delta: number): number {
  if (typeof window === "undefined") return 1500;
  try {
    const current = getStoredBalance();
    const updated = Math.max(0, current + delta);
    localStorage.setItem(BALANCE_STORAGE_KEY, updated.toString());
    syncUserBalance(updated);
    window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: updated }));
    return updated;
  } catch {
    return 1500;
  }
}
INNER_EOF

# 3. Створення components/auth-modal.tsx
cat << 'INNER_EOF' > components/auth-modal.tsx
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
  const [success, setSuccess] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setTab(initialTab);
    setError(null);
    setSuccess(null);
  }, [initialTab, isOpen]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && isOpen) {
        onClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const handleTabSwitch = (newTab: "login" | "register") => {
    playClickSound();
    setTab(newTab);
    setError(null);
    setSuccess(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    playClickSound();
    setError(null);
    setSuccess(null);

    if (tab === "register") {
      if (password !== confirmPassword) {
        playLossSound();
        setError("Введені паролі не співпадають!");
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
        setSuccess(res.message || "Успішна реєстрація! +2 500 GC нараховано!");
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
        setSuccess(res.message || "Успішний вхід!");
        setTimeout(() => {
          onClose();
          if (onSuccess && res.user) onSuccess(res.user);
        }, 1000);
      }
    }
  };

  const fillDemo = () => {
    playClickSound();
    setEmail("demo@cs2goi.ua");
    setPassword("123456");
    if (tab === "register") {
      setNickname("GoiMaster");
      setConfirmPassword("123456");
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
          <svg className="size-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <line x1="18" y1="6" x2="6" y2="18" strokeWidth={2} strokeLinecap="round" />
            <line x1="6" y1="6" x2="18" y2="18" strokeWidth={2} strokeLinecap="round" />
          </svg>
        </button>

        <div className="text-center">
          <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-xl font-black text-[#05130d] shadow-lg shadow-emerald-500/25">
            G
          </div>
          <h2 className="mt-3 text-xl font-black text-white">GoiCoins Simulator</h2>
          <p className="text-xs text-slate-400 mt-0.5">
            {tab === "login" ? "Авторизуйтесь для синхронізації скінів" : "Створіть свій ігровий профіль"}
          </p>
        </div>

        <div className="mt-5 grid grid-cols-2 gap-1 rounded-2xl border border-white/10 bg-black/40 p-1">
          <button
            type="button"
            onClick={() => handleTabSwitch("login")}
            className={`rounded-xl py-2 text-xs font-black transition ${
              tab === "login"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            🔑 Увійти
          </button>
          <button
            type="button"
            onClick={() => handleTabSwitch("register")}
            className={`flex items-center justify-center gap-1.5 rounded-xl py-2 text-xs font-black transition ${
              tab === "register"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            <span>✨ Реєстрація</span>
            <span
              className={`rounded-full px-1.5 py-0.2 text-[9px] font-black ${
                tab === "register" ? "bg-black/20 text-[#05130d]" : "bg-emerald-400/20 text-emerald-300"
              }`}
            >
              +2.5k
            </span>
          </button>
        </div>

        {tab === "register" && (
          <div className="mt-4 rounded-2xl border border-emerald-500/30 bg-emerald-500/10 p-3 flex items-center gap-3 animate-fade-in">
            <span className="text-2xl">🎁</span>
            <div className="text-xs leading-tight">
              <p className="font-black text-emerald-300">Вітальний бонус новачкам:</p>
              <p className="text-slate-300 text-[11px] mt-0.5">
                +2 500 GoiCoins та 4 CS2 скіни на твій аккаунт одразу після реєстрації!
              </p>
            </div>
          </div>
        )}

        {error && (
          <div className="mt-4 rounded-2xl border border-rose-500/30 bg-rose-500/10 p-3 text-xs font-semibold text-rose-300 animate-fade-in">
            ⚠️ {error}
          </div>
        )}

        {success && (
          <div className="mt-4 rounded-2xl border border-emerald-500/30 bg-emerald-500/10 p-3 text-xs font-semibold text-emerald-300 animate-fade-in">
            🎉 {success}
          </div>
        )}

        <form onSubmit={handleSubmit} className="mt-4 space-y-3">
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
                placeholder="Штанько Микола / GoiMaster"
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
                className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white transition text-xs"
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

          <div className="flex items-center justify-between pt-1">
            <button
              type="button"
              onClick={fillDemo}
              className="text-[11px] font-semibold text-emerald-400 hover:text-emerald-300 underline"
            >
              Вставити демо-дані
            </button>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full mt-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 py-2.5 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition disabled:opacity-50"
          >
            {loading
              ? "Завантаження..."
              : tab === "login"
              ? "Увійти в акаунт ⚡"
              : "Зареєструватися (+2.5k GC) 🔥"}
          </button>
        </form>

        <div className="mt-4 border-t border-white/10 pt-3 text-center">
          <p className="text-[11px] text-slate-400">
            {tab === "login" ? "Немає акаунта? " : "Вже маєте акаунт? "}
            <button
              type="button"
              onClick={() => handleTabSwitch(tab === "login" ? "register" : "login")}
              className="font-bold text-emerald-400 hover:text-emerald-300 underline ml-1"
            >
              {tab === "login" ? "Створити акаунт" : "Увійти"}
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}
INNER_EOF

# 4. Оновлення app/components/site-header.tsx
cat << 'INNER_EOF' > app/components/site-header.tsx
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

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-3.5 py-1.5 font-mono text-xs font-black text-emerald-300 shadow-[0_0_15px_rgba(16,185,129,0.15)]">
              <span className="text-emerald-400">🪙</span>
              <span>{balance.toLocaleString("uk-UA")} GC</span>
            </div>

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

      <AuthModal
        isOpen={isAuthOpen}
        initialTab={authTab}
        onClose={() => setIsAuthOpen(false)}
      />
    </>
  );
}
INNER_EOF

# 5. Сторінки входу та реєстрації
cat << 'INNER_EOF' > app/login/page.tsx
"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { loginUser } from "@/lib/auth-storage";
import { playWinSound, playLossSound, playClickSound } from "@/lib/sound-fx";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    playClickSound();
    setError(null);
    setLoading(true);

    const res = loginUser(email, password);
    setLoading(false);

    if (!res.success) {
      playLossSound();
      setError(res.message || "Помилка входу");
    } else {
      playWinSound();
      setSuccess(res.message || "Успішний вхід!");
      setTimeout(() => {
        router.push("/inventory");
      }, 1000);
    }
  };

  const handleDemoLogin = () => {
    setEmail("demo@cs2goi.ua");
    setPassword("123456");
  };

  return (
    <div className="min-h-[85vh] flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-md rounded-3xl border border-emerald-500/30 bg-[#0a0d14]/95 p-6 sm:p-8 shadow-[0_0_60px_rgba(16,185,129,0.15)] backdrop-blur-2xl">
        <div className="text-center">
          <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-xl font-black text-[#05130d] shadow-lg shadow-emerald-500/25">
            G
          </div>
          <h1 className="mt-4 text-2xl font-black text-white">Вхід у GoiCoins</h1>
          <p className="mt-1 text-xs text-slate-400">
            Увійдіть для синхронізації ваших скінів та балансу
          </p>
        </div>

        {error && (
          <div className="mt-5 rounded-2xl border border-rose-500/30 bg-rose-500/10 p-3.5 text-xs font-semibold text-rose-300">
            ⚠️ {error}
          </div>
        )}

        {success && (
          <div className="mt-5 rounded-2xl border border-emerald-500/30 bg-emerald-500/10 p-3.5 text-xs font-semibold text-emerald-300">
            🎉 {success}
          </div>
        )}

        <form onSubmit={handleSubmit} className="mt-6 space-y-4">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1.5">
              Електронна пошта
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="player@cs2goi.ua"
              className="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-2.5 text-sm text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1.5">
              Пароль
            </label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Введіть ваш пароль"
                className="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-2.5 pr-11 text-sm text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white transition"
              >
                {showPassword ? "🙈" : "👁️"}
              </button>
            </div>
          </div>

          <button
            type="button"
            onClick={handleDemoLogin}
            className="w-full text-right text-xs font-semibold text-emerald-400 hover:text-emerald-300 transition"
          >
            Вставити демо-дані для тесту
          </button>

          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-xl bg-emerald-500 hover:bg-emerald-400 py-3 text-sm font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition disabled:opacity-50"
          >
            {loading ? "Входимо..." : "Увійти в акаунт ⚡"}
          </button>
        </form>

        <div className="mt-6 border-t border-white/10 pt-4 text-center">
          <p className="text-xs text-slate-400">
            Немає акаунта?{" "}
            <Link
              href="/register"
              className="font-bold text-emerald-400 hover:text-emerald-300 underline"
            >
              Зареєструватися (+2 500 GC бонус)
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > app/register/page.tsx
"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { registerUser } from "@/lib/auth-storage";
import { playWinSound, playLossSound, playClickSound } from "@/lib/sound-fx";

export default function RegisterPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [nickname, setNickname] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    playClickSound();
    setError(null);

    if (password !== confirmPassword) {
      playLossSound();
      setError("Введені паролі не співпадають!");
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
      setSuccess(res.message || "Успішна реєстрація! Бонус +2 500 GC нараховано!");
      setTimeout(() => {
        router.push("/inventory");
      }, 1200);
    }
  };

  return (
    <div className="min-h-[85vh] flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-md rounded-3xl border border-emerald-500/30 bg-[#0a0d14]/95 p-6 sm:p-8 shadow-[0_0_60px_rgba(16,185,129,0.15)] backdrop-blur-2xl">
        <div className="text-center">
          <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-xl font-black text-[#05130d] shadow-lg shadow-emerald-500/25">
            G
          </div>
          <h1 className="mt-4 text-2xl font-black text-white">Реєстрація в GoiCoins</h1>
          <p className="mt-1 text-xs text-slate-400">
            Створи свій профіль та отримай вітальний бонус
          </p>
        </div>

        <div className="mt-5 rounded-2xl border border-emerald-500/30 bg-emerald-500/10 p-3.5 flex items-center gap-3">
          <span className="text-2xl">🎁</span>
          <div className="text-xs">
            <p className="font-black text-emerald-300">Вітальний бонус новачкам:</p>
            <p className="text-slate-300">+2 500 GoiCoins та 4 CS2 скіни на твій аккаунт!</p>
          </div>
        </div>

        {error && (
          <div className="mt-4 rounded-2xl border border-rose-500/30 bg-rose-500/10 p-3.5 text-xs font-semibold text-rose-300">
            ⚠️ {error}
          </div>
        )}

        {success && (
          <div className="mt-4 rounded-2xl border border-emerald-500/30 bg-emerald-500/10 p-3.5 text-xs font-semibold text-emerald-300">
            🎉 {success}
          </div>
        )}

        <form onSubmit={handleSubmit} className="mt-5 space-y-3.5">
          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">
              Електронна пошта
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="player@cs2goi.ua"
              className="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-2.5 text-sm text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">
              Ігровий нікнейм (позивний)
            </label>
            <input
              type="text"
              required
              value={nickname}
              onChange={(e) => setNickname(e.target.value)}
              placeholder="Штанько Микола"
              className="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-2.5 text-sm text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">
              Пароль (від 6 символів)
            </label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Створіть надійний пароль"
                className="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-2.5 pr-11 text-sm text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white transition"
              >
                {showPassword ? "🙈" : "👁️"}
              </button>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-300 mb-1">
              Підтвердження пароля
            </label>
            <input
              type={showPassword ? "text" : "password"}
              required
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Повторіть пароль ще раз"
              className="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-2.5 text-sm text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full mt-2 rounded-xl bg-emerald-500 hover:bg-emerald-400 py-3 text-sm font-black text-[#05130d] shadow-lg shadow-emerald-500/20 transition disabled:opacity-50"
          >
            {loading ? "Реєстрація..." : "Зареєструватися та забрати +2.5k GC 🔥"}
          </button>
        </form>

        <div className="mt-5 border-t border-white/10 pt-4 text-center">
          <p className="text-xs text-slate-400">
            Вже маєте акаунт?{" "}
            <Link
              href="/login"
              className="font-bold text-emerald-400 hover:text-emerald-300 underline"
            >
              Увійти в акаунт
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
INNER_EOF

# 6. Оновлення app/inventory/page.tsx
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

  const handleSellSkin = (item: InventoryItem) => {
    playCoinSound();
    const { newInventory, newBalance } = sellInventorySkin(item);
    setInventory(newInventory);
    setBalance(newBalance);
    showToast(`💰 Продано ${item.weapon} | ${item.name} за +${formatCoins(item.price)} GC!`);
  };

  const handleSellAll = () => {
    if (inventory.length === 0) return;
    playCoinSound();
    const { count, totalGained, newBalance } = sellAllInventorySkins();
    setInventory([]);
    setBalance(newBalance);
    showToast(`🎉 Продано всі ${count} скінів на суму +${formatCoins(totalGained)} GC!`);
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
            <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 px-5 py-3">
              <p className="text-[10px] font-bold uppercase tracking-wider text-emerald-300">Баланс GC</p>
              <p className="mt-0.5 font-mono text-xl font-black text-white">
                {balance.toLocaleString("uk-UA")} GC
              </p>
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
            Ти можеш продати будь-який скін за повну вартість у GoiCoins або запустити його в кібер-апгрейд.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2.5">
          {inventory.length > 0 && (
            <button
              onClick={handleSellAll}
              className="rounded-xl border border-amber-500/30 bg-amber-500/10 px-4 py-2 text-xs font-black text-amber-300 hover:bg-amber-500/20 transition"
            >
              💰 Продати весь інвентар ({formatCoins(totalValue)} GC)
            </button>
          )}
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
            Всі скіни було продано або програно в рулетці. Відвідай Ринок або зареєструйся для отримання бонусного набору!
          </p>
          <div className="mt-6 flex flex-wrap gap-3 justify-center">
            <Link
              href="/market"
              className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-6 py-2.5 text-xs font-black text-[#05130d] shadow-lg transition"
            >
              Перейти на Ринок CS2 →
            </Link>
            {!user && (
              <button
                onClick={openRegisterModal}
                className="rounded-xl border border-emerald-500/40 bg-emerald-500/10 hover:bg-emerald-500/20 px-6 py-2.5 text-xs font-bold text-emerald-300 transition"
              >
                Отримати стартовий набір (+2.5k GC) 🎁
              </button>
            )}
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
                  onClick={() => handleSellSkin(item)}
                  title={`Продати за +${formatCoins(item.price)} GC`}
                  className="rounded-lg bg-white/5 hover:bg-rose-500/20 px-2.5 py-1.5 text-center text-[10px] font-bold text-slate-300 hover:text-rose-300 transition"
                >
                  Продати 💰
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
INNER_EOF

# 7. Запуск компіляції та перевірка тестів
echo "⚡ Запускаємо npm run build та vitest..."
npm run build
npm test

echo "⚡ Зберігаємо зміни у Git..."
git add .
git commit -m "feat(auth): email registration, login, user session and custom profile" || true
git push origin main || true

echo "=========================================================="
echo "🎉 v15 УСПІШНО ЗАВЕРШЕНО! Реєстрація та вхід за поштою активовані!"
echo "=========================================================="
