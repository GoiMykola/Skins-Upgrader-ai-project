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
  inventory: InventoryItem[];
}

const sessionPassStore = new Map<string, string>();

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
    const parsed = raw ? (JSON.parse(raw) as Array<Partial<StoredUserAccount> & Record<string, unknown>>) : [];
    let changed = false;
    const users: StoredUserAccount[] = parsed.map((entry) => {
      if ("password" in entry || "credentialHash" in entry) {
        changed = true;
      }
      return {
        id: String(entry.id || ""),
        email: String(entry.email || ""),
        nickname: String(entry.nickname || ""),
        avatar: String(entry.avatar || "G"),
        balance: typeof entry.balance === "number" ? entry.balance : 0,
        rank: String(entry.rank || "Global Elite"),
        createdAt: typeof entry.createdAt === "number" ? entry.createdAt : Date.now(),
        ...(typeof entry.initialCapital === "number" ? { initialCapital: entry.initialCapital } : {}),
        inventory: Array.isArray(entry.inventory) ? (entry.inventory as InventoryItem[]) : [],
      };
    });

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

export function registerUser(email: string, nickname: string, passInput: string): AuthResult {
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

  if (passInput.length < 4) {
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

  sessionPassStore.set(cleanEmail, passInput);

  const newAccount: StoredUserAccount = {
    id: "gp_" + Math.random().toString(36).substring(2, 9),
    email: cleanEmail,
    nickname: cleanNickname,
    avatar: initials,
    balance: initialBalance,
    rank: "Global Elite",
    createdAt: Date.now(),
    initialCapital,
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

export function loginUser(email: string, passInput: string): AuthResult {
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

  if (passInput.length < 4) {
    return {
      success: false,
      message: "Пароль повинен містити щонайменше 4 символи!",
    };
  }

  const expectedInSession = sessionPassStore.get(cleanEmail);
  if (!isCreatorOrDemo && expectedInSession && expectedInSession !== passInput) {
    return {
      success: false,
      message: "Невірний пароль! Спробуйте ще раз.",
    };
  }
  sessionPassStore.set(cleanEmail, passInput);

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
