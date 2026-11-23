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
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwhFQyvj8V7p8POXfDWadweB-Xxa_nRwvpnfSwNv7IHiQPFp1DYVyEbZY5xnrxtPjM7vnsgH_2o1A3t3x73z9yF-xW-I",
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
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_jdk7uW-V6x0MPWBMWWVwP1ij-1gSCGn20pxtm_WzNuoeHKeaFAnCZUiTe5bt0HqxofmZOrm5Q2IjoMQzS_5iShXrnE8NzWs__c",
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
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_DVL0OK8Yap5M-SBC2ad_uJ_t-l9AX_qlk4k5GyAzo6ocC-QZgZxX8AjEbZY5xnrxtPjM7vnsgGIj9oTmXngznQeg3pfcPs",
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
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwhFQyvj8V7p8POXfDWadweB-Xxa_nRwvpnfSwNv7IHiQPFp1DYVyEbZY5xnrxtPjM7vnsgH_2o1A3t3x73z9yF-xW-I",
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

  const starterInventory: InventoryItem[] = STARTER_REGISTRATION_SKINS.map((s, idx) => ({
    ...s,
    instanceId: `starter-${s.finish}-${Date.now()}-${idx}-${Math.random().toString(36).substring(2, 6)}`,
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
