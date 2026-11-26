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
export function grantSkinToUser(
  targetId: string,
  skin: { name: string; weapon: string; price: number; image: string; rarity?: string; accent?: string },
): { success: boolean; targetName: string } {
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
