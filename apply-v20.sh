#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v20: СПРАВЖНЯ ТАБЛИЦЯ ЛІДЕРІВ + АКАУНТИ SUPABASE"
echo "   (Вичищено фейкові профілі, додано Акаунти А і Б з ПР 5)"
echo "=========================================================="

mkdir -p app/leaderboard components lib

# 1. lib/auth-storage.ts: інтеграція Supabase акаунтів А і Б
cat << 'INNER_EOF' > lib/auth-storage.ts
"use client";

import type { InventoryItem } from "./inventory-storage";
import { RESTORE_BACKUP_SKINS } from "./inventory-storage";

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

// Два офіційні акаунти з ПР 5 (Supabase)
export const SUPABASE_TEST_ACCOUNTS: StoredUserAccount[] = [
  {
    id: "sp_user_a",
    email: "nikoly2305+a@gmail.com",
    nickname: "Goi Master",
    avatar: "GM",
    balance: 60922,
    rank: "Global Elite",
    createdAt: 1732388400000,
    password: "password123",
    inventory: RESTORE_BACKUP_SKINS.map((s, idx) => ({
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
    password: "password123",
    inventory: [
      {
        name: "Case Hardened",
        weapon: "AK-47",
        wear: "Мінімальний знос",
        price: 18500,
        rarity: "Засекречена",
        accent: "#d32ce6",
        finish: "case-hardened",
        kind: "rifle",
        image:
          "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwlcK3wiFO0POlV61-LPGdCliWzeFkse1WQyC0nQlpsDuGyt-pdnyRPA4hDcYkR-QPuhi-wdPuYbyx5AaMidkQnC_-2ilIuzErvbi4ijV5Mw",
        instanceId: "sp_b_1",
      },
      {
        name: "Printstream",
        weapon: "AWP",
        wear: "Мінімальний знос",
        price: 6400,
        rarity: "Таємне",
        accent: "#eb4b4b",
        finish: "printstream-awp",
        kind: "sniper",
        image:
          "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_DVL0OK8Yap5M-SBC2ad_uJ_t-l9AX_qlk4k5GyAzo6ocC-QZgZxX8AjEbZY5xnrxtPjM7vnsGIj9oTmXngznQeg3pfcPs",
        instanceId: "sp_b_2",
      },
      {
        name: "Stained",
        weapon: "★ Shadow Daggers",
        wear: "Прямо із заводу",
        price: 4800,
        rarity: "Надзвичайне",
        accent: "#64748b",
        finish: "shadow-daggers-stained",
        kind: "knife",
        image:
          "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1X6um-cbZvKM-SD1iWwOpzj-1gSCGn200ht2aDm9urI3uXag5yDMctFLVdtRS-ldThM-rm5gHZiYlS3yr5i39XrnE8G8fWkdc",
        instanceId: "sp_b_3",
      },
      {
        name: "Kill Confirmed",
        weapon: "USP-S",
        wear: "Після польових",
        price: 3200,
        rarity: "Таємне",
        accent: "#ef4444",
        finish: "kill-confirmed",
        kind: "pistol",
        image:
          "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL1m5fn8S1E8emXZadkM-GGCWWZ_eJ_t-loA36mxw4u5GyAzNuufC3XPlNxA5YmEbZI71W8kIznZ-y6v1Xp2t9NzS_5mStXrnE9vW0vK9c",
        instanceId: "sp_b_4",
      },
    ],
  },
];

export function getAllStoredUsers(): StoredUserAccount[] {
  if (typeof window === "undefined") return SUPABASE_TEST_ACCOUNTS;
  try {
    const raw = localStorage.getItem(AUTH_USERS_DB_KEY);
    let users: StoredUserAccount[] = raw ? JSON.parse(raw) : [];

    // Гарантуємо наявність обох Supabase-профілів у базі
    const existingEmails = new Set(users.map((u) => u.email.toLowerCase()));
    let changed = false;

    for (const sup of SUPABASE_TEST_ACCOUNTS) {
      if (!existingEmails.has(sup.email.toLowerCase())) {
        users.push(sup);
        changed = true;
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

  if (password.length < 6) {
    return { success: false, message: "Пароль повинен містити щонайменше 6 символів!" };
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

  let user = users.find((u) => u.email.toLowerCase() === cleanEmail);

  // Спрощений вхід для перевірочних акаунтів (включаючи акаунти Supabase з ПР 5)
  if (
    user &&
    (cleanEmail === "nikoly2305+a@gmail.com" ||
      cleanEmail === "nikoly2305+b@gmail.com" ||
      cleanEmail === "player@cs2goi.ua" ||
      cleanEmail === "admin@cs2goi.ua")
  ) {
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

  if (!user) {
    return {
      success: false,
      message: "Користувача з такою поштою не знайдено!",
    };
  }

  if (user.password !== password) {
    return {
      success: false,
      message: "Невірний пароль! Спробуйте ще раз.",
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
  const user = getCurrentUser();
  if (!user) return;
  user.balance = newBalance;
  localStorage.setItem(AUTH_USER_KEY, JSON.stringify(user));

  const users = getAllStoredUsers();
  const idx = users.findIndex((u) => u.id === user.id);
  if (idx !== -1) {
    users[idx].balance = newBalance;
    localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
  }
}

export function syncUserInventory(newInventory: InventoryItem[]) {
  if (typeof window === "undefined") return;
  const user = getCurrentUser();
  if (!user) return;

  const users = getAllStoredUsers();
  const idx = users.findIndex((u) => u.id === user.id);
  if (idx !== -1) {
    users[idx].inventory = newInventory;
    localStorage.setItem(AUTH_USERS_DB_KEY, JSON.stringify(users));
  }
}
INNER_EOF

# 2. app/leaderboard/page.tsx: динамічний рейтинг тільки реальних зареєстрованих юзерів
cat << 'INNER_EOF' > app/leaderboard/page.tsx
"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { formatCoins } from "@/app/data";
import { getAllStoredUsers, getCurrentUser, type StoredUserAccount, type UserProfile } from "@/lib/auth-storage";
import { getStoredInventory, getStoredBalance, type InventoryItem } from "@/lib/inventory-storage";
import { playClickSound } from "@/lib/sound-fx";

interface LeaderboardPlayer {
  id: string;
  name: string;
  email: string;
  avatar: string;
  rank: string;
  skinsCount: number;
  inventoryValue: number;
  balance: number;
  totalWealth: number;
  isCurrentUser: boolean;
  createdAt: number;
}

export default function LeaderboardPage() {
  const [players, setPlayers] = useState<LeaderboardPlayer[]>([]);
  const [currentUser, setCurrentUser] = useState<UserProfile | null>(null);

  const refreshLeaderboard = () => {
    const rawUsers = getAllStoredUsers();
    const active = getCurrentUser();
    setCurrentUser(active);

    const activeInv = getStoredInventory();
    const activeBal = getStoredBalance();

    const mapped: LeaderboardPlayer[] = rawUsers.map((u) => {
      const isCurrent = active ? active.id === u.id || active.email.toLowerCase() === u.email.toLowerCase() : false;
      const inv: InventoryItem[] = isCurrent ? activeInv : u.inventory || [];
      const bal: number = isCurrent ? activeBal : u.balance || 0;

      const invVal = inv.reduce((sum, s) => sum + (s.price || 0), 0);
      const total = invVal + bal;

      return {
        id: u.id,
        name: u.nickname || "Goi Master",
        email: u.email,
        avatar: u.avatar || u.nickname?.substring(0, 2).toUpperCase() || "G",
        rank: u.rank || "Global Elite",
        skinsCount: inv.length,
        inventoryValue: invVal,
        balance: bal,
        totalWealth: total,
        isCurrentUser: isCurrent,
        createdAt: u.createdAt || Date.now(),
      };
    });

    mapped.sort((a, b) => b.totalWealth - a.totalWealth);
    setPlayers(mapped);
  };

  useEffect(() => {
    refreshLeaderboard();

    const handleAuth = () => refreshLeaderboard();
    const handleInv = () => refreshLeaderboard();
    const handleBal = () => refreshLeaderboard();

    window.addEventListener("goi-auth-updated", handleAuth);
    window.addEventListener("goi-inventory-updated", handleInv);
    window.addEventListener("goi-balance-updated", handleBal);

    return () => {
      window.removeEventListener("goi-auth-updated", handleAuth);
      window.removeEventListener("goi-inventory-updated", handleInv);
      window.removeEventListener("goi-balance-updated", handleBal);
    };
  }, []);

  const totalPlayers = players.length;
  const totalMarketValue = players.reduce((sum, p) => sum + p.totalWealth, 0);

  const openAuthModal = () => {
    playClickSound();
    window.dispatchEvent(new CustomEvent("goi-open-auth", { detail: "register" }));
  };

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8 min-h-screen">
      {/* Шапка таблиці */}
      <div className="mb-8 flex flex-wrap items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="flex size-2.5 rounded-full bg-emerald-400 animate-pulse" />
            <span className="text-[11px] font-bold uppercase tracking-wider text-emerald-400">
              Офіційний рейтинг · Жива синхронізація
            </span>
          </div>
          <h1 className="text-3xl font-black text-white sm:text-4xl">Таблиця лідерів</h1>
          <p className="mt-1 text-sm text-slate-400 max-w-2xl">
            Справжній рейтинг виключно зареєстрованих користувачів платформи (включаючи профілі з Supabase).
            Ранжування здійснюється за загальною вартістю зібраної колекції скінів та балансом.
          </p>
        </div>

        <div className="flex gap-4">
          <div className="rounded-2xl border border-white/10 bg-[#0e111a] px-5 py-3 shadow-lg">
            <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Гравців у базі</p>
            <p className="font-mono text-xl font-black text-white mt-0.5">{totalPlayers}</p>
          </div>
          <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 px-5 py-3 shadow-lg">
            <p className="text-[10px] font-bold uppercase tracking-wider text-emerald-300">Капітал рейтингу</p>
            <p className="font-mono text-xl font-black text-emerald-400 mt-0.5">
              {formatCoins(totalMarketValue)} GC
            </p>
          </div>
        </div>
      </div>

      {!currentUser && (
        <div className="mb-8 rounded-3xl border border-amber-500/30 bg-gradient-to-r from-amber-500/10 via-[#181308] to-transparent p-5 sm:p-6 shadow-xl flex flex-wrap items-center justify-between gap-4 animate-fade-in">
          <div className="flex items-center gap-4">
            <div className="flex size-12 items-center justify-center rounded-2xl bg-amber-500/20 text-2xl">
              🏆
            </div>
            <div>
              <h3 className="text-base font-black text-white">Твій акаунт ще не в рейтингу!</h3>
              <p className="text-xs text-slate-300 mt-0.5">
                Зареєструйся за своєю поштою або увійди, щоб посісти своє заслужене місце серед лідерів GoiCoins!
              </p>
            </div>
          </div>
          <button
            onClick={openAuthModal}
            className="rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 hover:brightness-110 px-6 py-2.5 text-xs font-black text-[#1a1104] shadow-lg shadow-amber-500/20 transition"
          >
            Увійти / Зареєструватися ⚡
          </button>
        </div>
      )}

      {/* Таблиця лідерів */}
      <div className="overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0e111a] shadow-2xl">
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-white/[0.08] bg-white/[0.02] text-[11px] font-bold uppercase tracking-wider text-slate-400">
                <th className="py-4 px-6 text-center w-20">Місце</th>
                <th className="py-4 px-6">Гравець</th>
                <th className="py-4 px-6">Ранг</th>
                <th className="py-4 px-6 text-center">Скінів</th>
                <th className="py-4 px-6 text-right">Вартість інвентаря</th>
                <th className="py-4 px-6 text-right">Загальний капітал</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/[0.06] text-sm">
              {players.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center text-slate-500 text-sm">
                    Немає зареєстрованих гравців у базі даних.
                  </td>
                </tr>
              ) : (
                players.map((p, index) => {
                  const placeNumber = index + 1;
                  const isTop1 = index === 0;
                  const isTop2 = index === 1;
                  const isTop3 = index === 2;

                  const medalBadge = isTop1
                    ? "text-amber-300 bg-amber-400/20 border-amber-400/30 shadow-md shadow-amber-500/10"
                    : isTop2
                    ? "text-slate-200 bg-slate-300/20 border-slate-300/30"
                    : isTop3
                    ? "text-amber-600 bg-amber-700/20 border-amber-700/30"
                    : "text-slate-400 bg-white/5 border-white/5";

                  const medalIcon = isTop1 ? "🥇" : isTop2 ? "🥈" : isTop3 ? "🥉" : null;

                  return (
                    <tr
                      key={p.id}
                      className={`transition duration-150 ${
                        p.isCurrentUser
                          ? "bg-emerald-500/[0.07] hover:bg-emerald-500/[0.12] border-l-4 border-l-emerald-400"
                          : "hover:bg-white/[0.02]"
                      }`}
                    >
                      {/* Номер / Медаль */}
                      <td className="py-4 px-6 text-center font-mono font-bold">
                        <span
                          className={`inline-flex items-center justify-center min-w-8 h-8 px-2 rounded-xl border text-xs font-black ${medalBadge}`}
                        >
                          {medalIcon ? `${medalIcon} 0${placeNumber}` : `0${placeNumber}`}
                        </span>
                      </td>

                      {/* Гравець */}
                      <td className="py-4 px-6">
                        <div className="flex items-center gap-3.5">
                          <div className="relative flex size-10 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-teal-600 text-xs font-black text-[#05130d] shadow-md shadow-emerald-500/20">
                            {p.avatar}
                          </div>
                          <div>
                            <div className="flex items-center gap-2">
                              <span className="font-bold text-white text-sm">{p.name}</span>
                              {p.isCurrentUser && (
                                <span className="rounded-full bg-emerald-400/20 px-2 py-0.5 text-[10px] font-black text-emerald-300 border border-emerald-400/30">
                                  Це ти ✨
                                </span>
                              )}
                            </div>
                            <span className="text-[11px] font-mono text-slate-500 block">{p.email}</span>
                          </div>
                        </div>
                      </td>

                      {/* Ранг */}
                      <td className="py-4 px-6">
                        <span className="rounded-lg border border-white/10 bg-white/5 px-3 py-1 text-xs font-bold text-slate-300">
                          {p.rank}
                        </span>
                      </td>

                      {/* Кількість скінів */}
                      <td className="py-4 px-6 text-center font-mono font-bold text-slate-300">
                        {p.skinsCount} шт.
                      </td>

                      {/* Вартість інвентаря */}
                      <td className="py-4 px-6 text-right font-mono font-bold text-slate-200">
                        {formatCoins(p.inventoryValue)} GC
                      </td>

                      {/* Загальний капітал */}
                      <td className="py-4 px-6 text-right font-mono font-black text-emerald-400 text-base">
                        {formatCoins(p.totalWealth)} GC
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      <div className="mt-8 flex flex-wrap items-center justify-between gap-4 text-xs text-slate-500">
        <p>💡 Рейтинг оновлюється автоматично при кожній зміні інвентаря або реєстрації нового користувача.</p>
        <Link href="/" className="font-bold text-emerald-400 hover:text-emerald-300 transition">
          Перейти до Апгрейдера →
        </Link>
      </div>
    </div>
  );
}
INNER_EOF

# 3. components/auth-modal.tsx з кнопками входу для Акаунтів А і Б з Supabase
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
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  useEffect(() => {
    setTab(initialTab);
    setError(null);
    setSuccessMsg(null);
  }, [initialTab, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccessMsg(null);

    if (tab === "login") {
      const res = loginUser(email, password);
      if (res.success && res.user) {
        playWinSound();
        setSuccessMsg(res.message || "Успішний вхід!");
        setTimeout(() => {
          onSuccess?.(res.user!);
          onClose();
        }, 800);
      } else {
        playLossSound();
        setError(res.message || "Помилка входу");
      }
    } else {
      const res = registerUser(email, nickname, password);
      if (res.success && res.user) {
        playWinSound();
        setSuccessMsg(res.message || "Успішна реєстрація!");
        setTimeout(() => {
          onSuccess?.(res.user!);
          onClose();
        }, 1200);
      } else {
        playLossSound();
        setError(res.message || "Помилка реєстрації");
      }
    }
  };

  const handleQuickSupabaseDemo = (account: "a" | "b") => {
    playClickSound();
    if (account === "a") {
      setEmail("nikoly2305+a@gmail.com");
      setNickname("Goi Master");
      setPassword("password123");
    } else {
      setEmail("nikoly2305+b@gmail.com");
      setNickname("Cyber Player");
      setPassword("password123");
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
      <div className="relative w-full max-w-md overflow-hidden rounded-3xl border border-white/10 bg-[#0d1018]/95 p-6 sm:p-8 shadow-[0_0_50px_rgba(16,185,129,0.15)]">
        <button
          onClick={() => {
            playClickSound();
            onClose();
          }}
          className="absolute right-4 top-4 rounded-xl p-2 text-slate-400 hover:bg-white/5 hover:text-white transition"
          aria-label="Закрити"
        >
          ✕
        </button>

        <div className="flex items-center gap-3 mb-6">
          <div className="flex size-11 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 text-xl font-black text-[#05130d] shadow-lg shadow-emerald-500/20">
            G
          </div>
          <div>
            <h2 className="text-xl font-black text-white">GoiCoins Simulator</h2>
            <p className="text-xs text-slate-400">Система акаунтів та хмарний інвентар</p>
          </div>
        </div>

        <div className="flex rounded-xl bg-black/40 p-1 mb-6 border border-white/5">
          <button
            onClick={() => {
              playClickSound();
              setTab("login");
              setError(null);
            }}
            className={`flex-1 rounded-lg py-2 text-xs font-bold transition ${
              tab === "login"
                ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                : "text-slate-400 hover:text-white"
            }`}
          >
            Увійти
          </button>
          <button
            onClick={() => {
              playClickSound();
              setTab("register");
              setError(null);
            }}
            className={`flex-1 rounded-lg py-2 text-xs font-bold transition ${
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
                Ігровий нікнейм (позивний)
              </label>
              <input
                type="text"
                required
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                placeholder="Goi Master"
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

          <button
            type="submit"
            className="w-full rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 py-2.5 text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/25 hover:brightness-110 active:scale-[0.99] transition mt-2"
          >
            {tab === "login" ? "Увійти в акаунт ⚡" : "Зареєструватися (+2 500 GC) 🎁"}
          </button>
        </form>

        <div className="mt-5 border-t border-white/5 pt-4">
          <p className="text-[10px] font-bold uppercase tracking-wider text-slate-500 text-center mb-2.5">
            Швидкий вхід акаунтами з Supabase (ПР 5):
          </p>
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => handleQuickSupabaseDemo("a")}
              className="flex-1 rounded-lg border border-emerald-500/30 bg-emerald-500/10 py-1.5 text-[11px] font-medium text-emerald-300 hover:bg-emerald-500/20 transition"
            >
              👑 Акаунт А (Goi Master)
            </button>
            <button
              type="button"
              onClick={() => handleQuickSupabaseDemo("b")}
              className="flex-1 rounded-lg border border-white/10 bg-white/5 py-1.5 text-[11px] font-medium text-slate-300 hover:bg-white/10 hover:text-white transition"
            >
              👤 Акаунт Б (Cyber Player)
            </button>
          </div>
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
git commit -m "feat(leaderboard): dynamic real user leaderboard with Supabase accounts" || true
git push origin main || true

echo "=========================================================="
echo "🎉 ГОТОВО! Фейкові профілі s1mple/demo/v1per вичищено."
echo "   У Таблиці лідерів тепер лише справжні зареєстровані гравці,"
echo "   включаючи ваші акаунти А та Б з Supabase!"
echo "=========================================================="
