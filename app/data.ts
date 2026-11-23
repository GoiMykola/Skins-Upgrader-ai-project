export type Skin = {
  name: string;
  weapon: string;
  wear: string;
  price: number;
  rarity: string;
  accent: string;
  finish: string;
  kind: "rifle" | "sniper" | "knife" | "pistol";
  image: string;
};

export type MarketSkin = {
  id: string;
  name: string;
  weapon: string;
  fullName: string;
  category: "knives" | "gloves" | "snipers" | "rifles" | "pistols" | "smgs" | "heavy" | "other";
  rarity: string;
  rarityUk: string;
  rarityColor: string;
  price: number;
  image: string;
  minFloat?: number;
  maxFloat?: number;
};

// Розумне форматування цін (1 грн = 1 GC), щоб текст не ламав картки (420к, 185к, 8.9к)
export function formatCoins(amount: number): string {
  if (!amount && amount !== 0) return "0";
  if (amount >= 1_000_000) {
    const val = amount / 1_000_000;
    return (val % 1 === 0 ? val.toFixed(0) : val.toFixed(1)) + "M";
  }
  if (amount >= 10_000) {
    const val = amount / 1_000;
    return (val % 1 === 0 ? val.toFixed(0) : val.toFixed(1)) + "к";
  }
  if (amount >= 1_000) {
    const val = amount / 1_000;
    return (val % 1 === 0 ? val.toFixed(0) : val.toFixed(1)) + "к";
  }
  return amount.toString();
}

// Конвертація предмету з Ринку в формат Скіна для Апгрейдера та Інвентаря
export function marketSkinToSkin(item: MarketSkin): Skin {
  return {
    name: item.name,
    weapon: item.weapon,
    wear: "Прямо із заводу",
    price: item.price,
    rarity: item.rarityUk || item.rarity,
    accent: item.rarityColor || "#eb4b4b",
    finish: item.id || item.name.toLowerCase().replace(/[^a-z0-9]/g, "-"),
    kind: (item.category === "knives" ? "knife" : item.category === "snipers" ? "sniper" : item.category === "pistols" ? "pistol" : "rifle") as any,
    image: item.image,
  };
}

// Стартові скіни (реальні ринкові ціни Lis-Skins у грн)
export const skins: Skin[] = [
  {
    name: "Neon Rider",
    weapon: "AK-47",
    wear: "Прямо із заводу",
    price: 4200,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "neon-rider",
    kind: "rifle",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwlcK3wiFO0POlV6poL_6sHG6UxPxJvOhuRz39xkQhsTnVzoygdy7Ea1UoCZQkRe9bs0brl9TvN-m0tVHYjY5CyS35jjQJsHhk4o5zcA",
  },
  {
    name: "Hyper Beast",
    weapon: "AWP",
    wear: "Після польових",
    price: 2800,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "hyper-beast",
    kind: "sniper",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_jdk7uW-V6x0MPWBMWWVwP1ij-1gSCGn20pxtm_WzNuoeHKeaFAnCZUiTe5bt0HqxofmZOrm5Q2IjoMQzS_5iShXrnE8NzWs__c",
  },
  {
    name: "Howl",
    weapon: "M4A4",
    wear: "Трохи поношене",
    price: 185000,
    rarity: "Контрабандний",
    accent: "#e4ae39",
    finish: "howl",
    kind: "rifle",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwiFO0P_6afVSKP-EAm6extF6ueZhW2exwkl2tmTXwt39eCiUPQR2DMN4TOVetUK8xoLgM-K341eM2otDnC6okGoXufBz_TAB",
  },
  {
    name: "Dragon Lore",
    weapon: "AWP",
    wear: "Прямо із заводу",
    price: 450000,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "dragon-lore",
    kind: "sniper",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_jdk4veqYaF7IfysCnWRxuF4j-B-Xxa_nBovp3Pdwtj9cC_GaAd0DZdwQu9fuhS4kNy0NePntVTbjYpCyyT_3CgY5i9j_a9cBkcCWUKV",
  },
  {
    name: "Gamma Doppler (Emerald)",
    weapon: "★ Butterfly Knife",
    wear: "Прямо із заводу",
    price: 420000,
    rarity: "Надзвичайне",
    accent: "#34d399",
    finish: "gamma-doppler",
    kind: "knife",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1Z-ua6bbZrLOmsD2qvxONzouBlSxa-lA8lvziMgIr9HifOOV5kFJp2Ee9b4Rntm4GxY7_ntQHc2o1DmH6r3Hgcv3w4t-pXU6ZzrPHQjQnfcepq0dwfRJw",
  },
  {
    name: "Fade (99.8%)",
    weapon: "★ Karambit",
    wear: "Прямо із заводу",
    price: 140000,
    rarity: "Надзвичайне",
    accent: "#ffd700",
    finish: "karambit-fade",
    kind: "knife",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1Q7uCvZaZkNM-SD1iWwOpzj-1gSCGn20tztm_UyIn_JHKUbgYlWMcmQ-ZcskSwldS0MOnntAfd3YlMzH35jntXrnE8SOGRGG8",
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
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_DVL0OK8Yap5M-SBC2ad_uJ_t-l9AX_qlk4k5GyAzo6ocC-QZgZxX8AjEbZY5xnrxtPjM7vnsgGIj9oTmXngznQeg3pfcPs",
  },
  {
    name: "Case Hardened",
    weapon: "AK-47",
    wear: "Мінімальний знос",
    price: 18500,
    rarity: "Засекречена",
    accent: "#d32ce6",
    finish: "case-hardened",
    kind: "rifle",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwlcK3wiNK0P2nZKFpH_yaCW-Ej7sk5bE8Sn-2lEpz4zndzoyvdHuUPwFzWZYiE7EK4Bi4k9TlY-y24FbAy9USGSiZd5Q",
  },
  {
    name: "Printstream",
    weapon: "Desert Eagle",
    wear: "Прямо із заводу",
    price: 3900,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "printstream-deagle",
    kind: "pistol",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL1m5fn8Sdk7OeRbKFsJ8-DHG6e1f1iouRoQha_nBovp3OGmdeqInyVP1V0XsYlRbEI50a5wNyzZr605AyI3t5MmCSohylAuC89_a9cBoMY9UkV",
  },
  {
    name: "Kill Confirmed",
    weapon: "USP-S",
    wear: "Після польових",
    price: 3200,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "kill-confirmed",
    kind: "pistol",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL1m5fn8S1E8emXZadkM-GGCWWZ_eJ_t-loA36mxw4u5GyAzNuufC3XPlNxA5YmEbZI71W8kIznZ-y6v1Xp2t9NzS_5mStXrnE9vW0vK9c",
  },
];

export const inventorySkins: Skin[] = [
  skins[0], // AK-47 Neon Rider (4 200 GC)
  skins[1], // AWP Hyper Beast (2 800 GC)
  skins[8], // Desert Eagle Printstream (3 900 GC)
  skins[9], // USP-S Kill Confirmed (3 200 GC)
];

export const players = [
  { rank: "01", name: "s1mple.ua", level: "Легенда", value: 890000, skins: 34 },
  { rank: "02", name: "demo-player", level: "Global Elite", value: 320000, skins: 18 },
  { rank: "03", name: "Kira.exe", level: "Майстер", value: 195000, skins: 14 },
  { rank: "04", name: "v1per", level: "Майстер", value: 145000, skins: 12 },
  { rank: "05", name: "n0va", level: "Ветеран", value: 85000, skins: 11 },
];
