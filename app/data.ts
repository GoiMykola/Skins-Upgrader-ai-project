export type Skin = {
  name: string;
  weapon: string;
  wear: string;
  price: number;
  rarity: string;
  accent: string;
  finish: string;
  kind: "rifle" | "sniper" | "knife";
};

export const skins: Skin[] = [
  {
    name: "Неонова гонка",
    weapon: "AK-47",
    wear: "Після польових випробувань",
    price: 1250,
    rarity: "Засекречена",
    accent: "#f59e0b",
    finish: "neon",
    kind: "rifle",
  },
  {
    name: "Гіперзвер",
    weapon: "AWP",
    wear: "Трохи поношений",
    price: 3480,
    rarity: "Засекречена",
    accent: "#a78bfa",
    finish: "hyper",
    kind: "sniper",
  },
  {
    name: "Виття",
    weapon: "M4A4",
    wear: "Після польових випробувань",
    price: 4980,
    rarity: "Контрабандний",
    accent: "#fb7185",
    finish: "howl",
    kind: "rifle",
  },
  {
    name: "Гамма-хвилі",
    weapon: "Ніж-метелик",
    wear: "Прямо із заводу",
    price: 7620,
    rarity: "Таємний",
    accent: "#34d399",
    finish: "gamma",
    kind: "knife",
  },
  {
    name: "Поверхневий гарт",
    weapon: "AK-47",
    wear: "Мінімальний знос",
    price: 2130,
    rarity: "Засекречена",
    accent: "#60a5fa",
    finish: "blue",
    kind: "rifle",
  },
  {
    name: "Елітне спорядження",
    weapon: "M4A4",
    wear: "Прямо із заводу",
    price: 890,
    rarity: "Армійська якість",
    accent: "#fbbf24",
    finish: "gold",
    kind: "rifle",
  },
];

export const inventorySkins = [
  skins[0],
  skins[1],
  skins[4],
  skins[5],
].filter((skin): skin is Skin => skin !== undefined);

export const players = [
  { rank: "01", name: "demo-player", level: "Еліта", value: 24860, skins: 18 },
  { rank: "02", name: "Kira.exe", level: "Майстер", value: 19420, skins: 14 },
  { rank: "03", name: "v1per", level: "Майстер", value: 16890, skins: 12 },
  { rank: "04", name: "n0va", level: "Ветеран", value: 12740, skins: 11 },
  { rank: "05", name: "pixel_king", level: "Ветеран", value: 9860, skins: 9 },
];

export function formatCoins(value: number) {
  return new Intl.NumberFormat("uk-UA").format(value);
}
