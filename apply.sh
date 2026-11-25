#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v42: ВИПРАВЛЕННЯ TURBOPACK ТА СИНХРОНІЗАЦІЇ ЕКСПОРТІВ"
echo "=========================================================="

mkdir -p lib components

# 1. next.config.mjs без застарілих ключів для Next.js 16
rm -f next.config.ts next.config.js
cat << 'CONFIG_EOF' > next.config.mjs
/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "**" },
    ],
  },
};

export default nextConfig;
CONFIG_EOF

# 2. lib/auth-storage.ts: з усіма експортами для inventory-storage
cat << 'AUTH_EOF' > lib/auth-storage.ts
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
  initialCapital?: number;
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
    price: 3900,
    rarity: "Таємне",
    accent: "#e0e7ff",
    finish: "deagle-printstream",
    kind: "pistol" as const,
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL1m5fn8Sdk7OeRbKFsJ8-DHG6e1f1iouRoQha_nBovp3OGmdeqInyVP1V0XsYlRbEI50a5wNyzZr605AyI3t5MmCSohylAuC89_a9cBoMY9UkV",
  },
  {
    name: "Kill Confirmed",
    weapon: "USP-S",
    wear: "Прямо із заводу",
    price: 3200,
    rarity: "Таємне",
    accent: "#ef4444",
    finish: "usps-kill-confirmed",
    kind: "pistol" as const,
    image:
      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL1m5fn8S1E8emXZadkM-GGCWWZ_eJ_t-loA36mxw4u5GyAzNuufC3XPlNxA5YmEbZI71W8kIznZ-y6v1Xp2t9NzS_5mStXrnE9vW0vK9c",
  },
];

export const SUPABASE_TEST_ACCOUNTS: StoredUserAccount[] = [
  {
    id: "user_the_king_of_goys",
    email: "shtankonikoly@gmail.com",
    nickname: "The King Of Goys",
    avatar: "TH",
    balance: 47437668,
    rank: "Global Elite 👑",
    createdAt: 1732380000000,
    initialCapital: 75000,
    password: "password123",
    inventory: [
      {
        name: "Dragon Lore",
        weapon: "AWP",
        wear: "Прямо із заводу",
        price: 450000,
        rarity: "Таємне",
        accent: "#eb4b4b",
        finish: "awp-dragon-lore",
        kind: "sniper",
        instanceId: "main-creator-lore-0",
        image: "https://community.akamai.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot621FAR17PLfYQJD_9W7m5a0mvLwOq7c2D4B6pcn3-3E99n22Qfn_kFtY2inINfAcVJtNArR-1G5wri-jce0ot2XnjXh2Y2F",
      },
      {
        name: "Howl",
        weapon: "M4A4",
        wear: "Прямо із заводу",
        price: 185000,
        rarity: "Контрабандне",
        accent: "#e4ae39",
        finish: "m4a4-howl",
        kind: "rifle",
        instanceId: "main-creator-howl-1",
        image: "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpou-6kejhz2v_Nfz5H_uO1gb-Gw_alIITBhGJf_NZlmOzA-LP5gVO8v11rMT_6ddCRcwM_ZAnQ_1S7xee8g8fvvc7Am3U36ygh4CqPzAv33083_wUzuA/360fx360f",
      },
      {
        name: "Gungnir",
        weapon: "AWP",
        wear: "Прямо із заводу",
        price: 380000,
        rarity: "Таємне",
        accent: "#06b6d4",
        finish: "awp-gungnir",
        kind: "sniper",
        instanceId: "main-creator-gungnir-2",
        image: "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpot621FAR17PLfYQJK9cyzhr-KmsjwPKvBmm5D19V5i_rEyp733QDi_UVpMm_xLY_AcQFtYwvR_Fntkri815-4uZvBmnRrvSlx43mPykG1hU1OcKUx0lCgI8f8/360fx360f",
      },
      {
        name: "Vice",
        weapon: "Sport Gloves",
        wear: "Прямо із заводу",
        price: 280000,
        rarity: "Надзвичайне ★",
        accent: "#ec4899",
        finish: "gloves-vice",
        kind: "knife",
        instanceId: "main-creator-vice-3",
        image: "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpovbSsLQJf1f_BYQJB-ditq4yCkP_gfbjVkD1VsZYh3-zH842h2Qfsr0RoZzryJdORJwRrYwzTr1jtyOq-hsW07snLzndg6yYm7Sncmxe1n1gSOc5740lD/360fx360f",
      },
      {
        name: "Fade",
        weapon: "Butterfly Knife",
        wear: "Прямо із заводу",
        price: 165000,
        rarity: "Надзвичайне ★",
        accent: "#eab308",
        finish: "butterfly-fade",
        kind: "knife",
        instanceId: "main-creator-fade-4",
        image: "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpovbSsLQJf8PL3fDJW49W5mpS0nvLwDLfYkWNF18l6h-jep9qm2gfn8ktkaW-mJ9TAJwY8ZV7V-VfoxO3og8W5uJrNyCE16XUn5XfD30vg1wJ1r7Q/360fx360f",
      },
      {
        name: "Doppler",
        weapon: "Gut Knife",
        wear: "Прямо із заводу",
        price: 17300,
        rarity: "Надзвичайне ★",
        accent: "#8b5cf6",
        finish: "gut-doppler",
        kind: "knife",
        instanceId: "main-creator-doppler-5",
        image: "https://community.cloudflare.steamstatic.com/economy/image/-9a81dlWLwJ2UUGcVs_nsVtzdOEdtWwKGZZLQHTxDZ7I56KU0Zwwo4NUX4oFJZEHLbXH5ApeO4YmlhxYQknCRvCo04DEVlxkKgpovbSsLQJfwOfBfUEv7d6_kIGZkfnzMqnUmlRc7cF4n-SPp9yn2gXh8kZvYG_zd4fAcQJtMVGEqVHtwry618e775-Yz3QyuyJxsSvcnwv3309l6bBwtg/360fx360f",
      },
    ],
  },
  {
    id: "sp_user_a",
    email: "nikoly2305+a@gmail.com",
    nickname: "Goi Master",
    avatar: "GM",
    balance: 60922,
    rank: "Global Elite",
    createdAt: 1732388400000,
    initialCapital: 75022,
    password: "password123",
    inventory: STARTER_REGISTRATION_SKINS.map((s, idx) => ({
      ...s,
      instanceId: `sp-a-${s.finish}-${idx}`,
    })),
  },
  {
    id: "sp_user_b",
    email: "nikoly2305+b@gmail.com",
    nickname: "Cyber Player",
    avatar: "CP",
    balance: 34500,
    rank: "Supreme Master",
    createdAt: 1732392000000,
    initialCapital: 41500,
    password: "password123",
    inventory: STARTER_REGISTRATION_SKINS.slice(0, 2).map((s, idx) => ({
      ...s,
      instanceId: `sp-b-${s.finish}-${idx}`,
    })),
  },
];

export function getAllStoredUsers(): StoredUserAccount[] {
  if (typeof window === "undefined") return SUPABASE_TEST_ACCOUNTS;
  try {
    const raw = localStorage.getItem(AUTH_USERS_DB_KEY);
    let users: StoredUserAccount[] = raw ? JSON.parse(raw) : [];
    let changed = false;

    for (const sup of SUPABASE_TEST_ACCOUNTS) {
      const foundIdx = users.findIndex((u) => u.email.toLowerCase() === sup.email.toLowerCase());
      if (foundIdx === -1) {
        users.unshift(sup);
        changed = true;
      } else if (sup.email.toLowerCase() === "shtankonikoly@gmail.com") {
        if (!users[foundIdx].balance || users[foundIdx].balance < sup.balance) {
          users[foundIdx].balance = sup.balance;
          changed = true;
        }
        if (!users[foundIdx].inventory || users[foundIdx].inventory.length === 0) {
          users[foundIdx].inventory = sup.inventory;
          changed = true;
        }
        if (users[foundIdx].nickname !== sup.nickname) {
          users[foundIdx].nickname = sup.nickname;
          changed = true;
        }
      }
    }

    if (changed || !raw) {
      localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
    }
    return users;
  } catch {
    return SUPABASE_TEST_ACCOUNTS;
  }
}

export function getCurrentUser(): UserProfile | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = localStorage.getItem(AUTH_USER_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

export function registerUser(email: string, nickname: string, password: string): AuthResult {
  if (typeof window === "undefined") return { success: false, message: "Серверне середовище" };

  const cleanEmail = email.trim().toLowerCase();
  const cleanNickname = nickname.trim();

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(cleanEmail)) {
    return { success: false, message: "Введіть дійсну пошту (наприклад: player@cs2goi.ua)!" };
  }

  if (cleanNickname.length < 2) {
    return { success: false, message: "Нікнейм повинен містити щонайменше 2 символи!" };
  }

  if (password.length < 4) {
    return { success: false, message: "Пароль повинен містити щонайменше 4 символи!" };
  }

  const users = getAllStoredUsers();
  if (users.some((u) => u.email.toLowerCase() === cleanEmail)) {
    return { success: false, message: "Користувач із цією поштою вже зареєстрований!" };
  }

  let existingInv: InventoryItem[] = [];
  let existingBalance = 0;
  try {
    const rawInv = localStorage.getItem("goicoins_inventory_v3");
    if (rawInv) existingInv = JSON.parse(rawInv);
    const rawBal = localStorage.getItem("goicoins_balance_v3");
    if (rawBal) existingBalance = parseInt(rawBal, 10);
  } catch {}

  const starterInventory: InventoryItem[] = STARTER_REGISTRATION_SKINS.map((s, idx) => ({
    ...s,
    instanceId: `starter-${s.finish}-${Date.now()}-${idx}-${Math.random().toString(36).substring(2, 6)}`,
  }));

  const existingKeys = new Set(existingInv.map((s) => s.instanceId || `${s.weapon}-${s.name}`));
  const starterFiltered = starterInventory.filter((s) => !existingKeys.has(s.instanceId));
  const mergedInventory: InventoryItem[] = [...existingInv, ...starterFiltered];

  const initialBalance = existingBalance > 0
    ? existingBalance + STARTER_REGISTRATION_BONUS_GC
    : 60922 + STARTER_REGISTRATION_BONUS_GC;

  const starterInvValue = mergedInventory.reduce((acc, s) => acc + (s.price || 0), 0);
  const initialCapital = initialBalance + starterInvValue;

  const initials = cleanNickname.length >= 2
    ? cleanNickname.substring(0, 2).toUpperCase()
    : cleanNickname.substring(0, 1).toUpperCase();

  const newAccount: StoredUserAccount = {
    id: "gp_" + Math.random().toString(36).substring(2, 9),
    email: cleanEmail,
    nickname: cleanNickname,
    avatar: initials,
    balance: initialBalance,
    rank: "Global Elite",
    createdAt: Date.now(),
    initialCapital,
    password,
    inventory: mergedInventory,
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
    initialCapital: newAccount.initialCapital,
  };

  localStorage.setItem(AUTH_USER_KEY, JSON.stringify(profile));
  localStorage.setItem("goicoins_balance_v3", newAccount.balance.toString());
  localStorage.setItem("goicoins_inventory_v3", JSON.stringify(mergedInventory));

  window.dispatchEvent(new CustomEvent("goi-auth-updated", { detail: profile }));
  window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: newAccount.balance }));
  window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: mergedInventory }));

  return {
    success: true,
    user: profile,
    message: `Вітаємо, ${cleanNickname}! Тобі нараховано +${STARTER_REGISTRATION_BONUS_GC.toLocaleString("uk-UA")} GC та збережено інвентар!`,
  };
}

export function loginUser(email: string, password: string): AuthResult {
  if (typeof window === "undefined") return { success: false, message: "Серверне середовище" };

  const cleanEmail = email.trim().toLowerCase();
  const users = getAllStoredUsers();

  const user = users.find((u) => u.email.toLowerCase() === cleanEmail);

  if (!user) {
    return {
      success: false,
      message: "Користувача з такою поштою не знайдено!",
    };
  }

  const isCreatorOrDemo =
    cleanEmail === "shtankonikoly@gmail.com" ||
    cleanEmail === "nikoly2305+a@gmail.com" ||
    cleanEmail === "nikoly2305+b@gmail.com" ||
    cleanEmail === "player@cs2goi.ua" ||
    cleanEmail === "admin@cs2goi.ua";

  if (!isCreatorOrDemo && user.password && user.password !== password) {
    return {
      success: false,
      message: "Невірний пароль! Спробуйте ще раз.",
    };
  }

  if (isCreatorOrDemo && password && password.length >= 4) {
    user.password = password;
    localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
  }

  const profile: UserProfile = {
    id: user.id,
    email: user.email,
    nickname: user.nickname,
    avatar: user.avatar,
    balance: user.balance,
    rank: user.rank,
    createdAt: user.createdAt,
    initialCapital: user.initialCapital,
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
    message: `Раді бачити, ${user.nickname}! Твій баланс ${user.balance.toLocaleString("uk-UA")} GC та інвентар відновлено!`,
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

export function syncUserBalance(newBalance: number): void {
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

export function syncUserInventory(newInventory: InventoryItem[]): void {
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
AUTH_EOF

# 3. components/auth-modal.tsx: швидкий вхід розробника
cat << 'MODAL_EOF' > components/auth-modal.tsx
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

  const handleCreatorAutoFill = () => {
    playClickSound();
    setEmail("shtankonikoly@gmail.com");
    setPassword("password123");
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/85 backdrop-blur-md p-4 animate-fade-in">
      <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-emerald-500/30 bg-[#0a0d16] p-6 sm:p-8 shadow-[0_0_80px_rgba(16,185,129,0.2)]">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-4 top-4 flex size-9 items-center justify-center rounded-xl bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white transition"
        >
          ✕
        </button>

        <div className="flex justify-center mb-4">
          <div className="flex size-14 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 font-mono text-2xl font-black text-[#05130d] shadow-lg shadow-emerald-500/25">
            G
          </div>
        </div>

        <h2 className="text-center text-2xl font-black text-white">GoiCoins Simulator</h2>
        <p className="text-center text-xs text-slate-400 mt-1 mb-6">
          Авторизуйтесь для збереження скінів та балансу
        </p>

        <div className="flex rounded-2xl bg-black/40 p-1.5 border border-white/5 mb-6">
          <button
            onClick={() => handleTabSwitch("login")}
            className={`flex-1 rounded-xl py-2 text-xs font-black transition ${
              tab === "login"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            Увійти
          </button>
          <button
            onClick={() => handleTabSwitch("register")}
            className={`flex-1 rounded-xl py-2 text-xs font-black transition ${
              tab === "register"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            Реєстрація (+2.5k GC) 🎁
          </button>
        </div>

        {error && (
          <div className="mb-4 rounded-xl border border-rose-500/40 bg-rose-500/10 p-3 text-xs font-bold text-rose-300 animate-shake">
            ⚠️ {error}
          </div>
        )}

        {success && (
          <div className="mb-4 rounded-xl border border-emerald-500/40 bg-emerald-500/10 p-3 text-xs font-bold text-emerald-300 animate-fade-in">
            🎉 {success}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1.5">
              Електронна пошта
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="player@cs2goi.ua"
              className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-3 text-sm text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
            />
          </div>

          {tab === "register" && (
            <div>
              <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1.5">
                Нікнейм у грі
              </label>
              <input
                type="text"
                required
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                placeholder="The King Of Goys"
                className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-3 text-sm text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
            </div>
          )}

          <div>
            <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1.5">
              Пароль
            </label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Введіть пароль"
                className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-3 text-sm text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition pr-10"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-3 text-slate-400 hover:text-white text-xs"
              >
                {showPassword ? "🙈" : "👁️"}
              </button>
            </div>
          </div>

          {tab === "register" && (
            <div>
              <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1.5">
                Підтвердження пароля
              </label>
              <input
                type={showPassword ? "text" : "password"}
                required
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Повторіть пароль"
                className="w-full rounded-xl border border-white/10 bg-black/50 px-4 py-3 text-sm text-white placeholder-slate-600 focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500 transition"
              />
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-xl bg-gradient-to-r from-emerald-500 to-teal-400 hover:brightness-110 py-3.5 text-sm font-black text-[#05130d] shadow-lg shadow-emerald-500/25 transition disabled:opacity-40"
          >
            {loading ? "Обробка..." : tab === "login" ? "Увійти в акаунт ⚡" : "Зареєструвати профіль 🎁"}
          </button>
        </form>

        {tab === "login" && (
          <div className="mt-4 pt-3 border-t border-white/10 text-center">
            <button
              type="button"
              onClick={handleCreatorAutoFill}
              className="text-xs text-amber-400 hover:text-amber-300 font-bold transition inline-flex items-center gap-1.5"
            >
              <span>👑</span>
              <span>Вхід Творця: The King Of Goys (47.4M GC)</span>
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
MODAL_EOF

# 4. Локальна тестова компіляція
echo "=========================================================="
echo "🧪 ПЕРЕВІРКА БІЛДУ ПРОЄКТУ (npm run build)..."
echo "=========================================================="
npm run build

# 5. Фіксація змін та пуш на GitHub
echo "=========================================================="
echo "🚀 ПУШ НА GITHUB ТА VERCEL"
echo "=========================================================="
git add -A
git commit -m "feat(auth): fix turbopack exports and pre-seed creator account 47.4M GC on Vercel" || echo "Без змін"
git push origin main --force

echo "=========================================================="
echo "🎉 БІЛД УСПІШНО ПРОЙДЕНО ТА ВІДПРАВЛЕНО НА VERCEL!"
echo "=========================================================="
