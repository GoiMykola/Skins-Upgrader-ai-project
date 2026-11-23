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

export const skins: Skin[] = [
  {
    name: "Neon Rider",
    weapon: "AK-47",
    wear: "Прямо із заводу",
    price: 1250,
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
    price: 3480,
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
    price: 8900,
    rarity: "Контрабандний",
    accent: "#e4ae39",
    finish: "howl",
    kind: "rifle",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwiFO0P_6afVSKP-EAm6extF6ueZhW2exwkl2tmTXwt39eCiUPQR2DMN4TOVetUK8xoLgM-K341eM2otDnC6okGoXufBz_TAB",
  },
  {
    name: "Gamma Doppler (Emerald)",
    weapon: "★ Butterfly Knife",
    wear: "Прямо із заводу",
    price: 14500,
    rarity: "Надзвичайне",
    accent: "#34d399",
    finish: "gamma-doppler",
    kind: "knife",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1Z-ua6bbZrLOmsD2qvxONzouBlSxa-lA8lvziMgIr9HifOOV5kFJp2Ee9b4Rntm4GxY7_ntQHc2o1DmH6r3Hgcv3w4t-pXU6ZzrPHQjQnfcepq0dwfRJw",
  },
  {
    name: "Printstream",
    weapon: "AWP",
    wear: "Мінімальний знос",
    price: 5600,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "printstream-awp",
    kind: "sniper",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_DVL0OK8Yap5M-SBC2ad_uJ_t-l9AX_qlk4k5GyAzo6ocC-QZgZxX8AjEbZY5xnrxtPjM7vnsgGIj9oTmXngznQeg3pfcPs",
  },
  {
    name: "Printstream",
    weapon: "Desert Eagle",
    wear: "Прямо із заводу",
    price: 1850,
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
    price: 2200,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "kill-confirmed",
    kind: "pistol",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLkjYbf7itX6vytbbZSI-WsG3SA_uV_vO1WTCa9kxQ1vjiBpYPwJiPTcFB2Xpp5TO5cskG9lYCxZu_jsVCL3o4Xnij23ClO5ik9tegFA_It8qHJz1aWe-uc160",
  },
  {
    name: "Asiimov",
    weapon: "AK-47",
    wear: "Після польових",
    price: 2900,
    rarity: "Таємне",
    accent: "#eb4b4b",
    finish: "asiimov-ak",
    kind: "rifle",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwlcK3wiFO0POlPPNSIeOaB2qf19F6ueZhW2e2wEt-t2jcytf6dymSO1JxA5oiRecLsRa5kIfkYr-241aLgotHz3-rkGoXuUp8oX57",
  },
  {
    name: "Fade (99.8%)",
    weapon: "★ Karambit",
    wear: "Прямо із заводу",
    price: 18900,
    rarity: "Надзвичайне",
    accent: "#ffd700",
    finish: "karambit-fade",
    kind: "knife",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1Q7uCvZaZkNM-SD1iWwOpzj-1gSCGn20tztm_UyIn_JHKUbgYlWMcmQ-ZcskSwldS0MOnntAfd3YlMzH35jntXrnE8SOGRGG8",
  },
  {
    name: "Water Elemental",
    weapon: "Glock-18",
    wear: "Після польових",
    price: 750,
    rarity: "Засекречена",
    accent: "#d32ce6",
    finish: "water-elemental",
    kind: "pistol",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL2kpnj9h1Y-s2pZKtuK72fB3aFxP11te99cCW6khUz_TjVyompc3-QOFR2DJQkFOMJtBbqk9LlY-7n5QLZjtkTxCWqhixPv311o7FVIf8eASQ",
  },
  {
    name: "Case Hardened",
    weapon: "AK-47",
    wear: "Мінімальний знос",
    price: 3150,
    rarity: "Засекречена",
    accent: "#d32ce6",
    finish: "case-hardened",
    kind: "rifle",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwlcK3wiNK0P2nZKFpH_yaCW-Ej7sk5bE8Sn-2lEpz4zndzoyvdHuUPwFzWZYiE7EK4Bi4k9TlY-y24FbAy9USGSiZd5Q",
  },
];

export const inventorySkins = [
  skins[0],
  skins[1],
  skins[5],
  skins[6],
  skins[9],
].filter((skin): skin is Skin => skin !== undefined);

export const players = [
  { rank: "01", name: "s1mple.ua", level: "Легенда", value: 34860, skins: 24 },
  { rank: "02", name: "demo-player", level: "Global Elite", value: 24860, skins: 18 },
  { rank: "03", name: "Kira.exe", level: "Майстер", value: 19420, skins: 14 },
  { rank: "04", name: "v1per", level: "Майстер", value: 16890, skins: 12 },
  { rank: "05", name: "n0va", level: "Ветеран", value: 12740, skins: 11 },
];

export function formatCoins(value: number) {
  return new Intl.NumberFormat("uk-UA").format(value);
}
