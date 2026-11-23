import fs from "node:fs";
import path from "node:path";

async function main() {
  console.log("⚡ Оновлюємо базу даних скінів CS2...");
  const res = await fetch("https://raw.githubusercontent.com/ByMykel/CSGO-API/main/public/api/en/skins.json");
  if (!res.ok) throw new Error("HTTP error " + res.status);
  const raw = await res.json();

  function getSkinPrice(skin) {
    const name = skin.name || "";
    const cat = skin.category?.name || "";
    const rarity = skin.rarity?.name || "";
    const weapon = skin.weapon?.name || "";
    const pattern = skin.pattern?.name || "";

    if (name.includes("Dragon Lore") && weapon === "AWP") return 450000;
    if (name.includes("Gungnir") && weapon === "AWP") return 380000;
    if (name.includes("Howl") && weapon === "M4A4") return 185000;
    if (name.includes("Wild Lotus") && weapon === "AK-47") return 320000;
    if (weapon.includes("Butterfly") && pattern.includes("Emerald")) return 420000;
    if (weapon.includes("Butterfly") && pattern.includes("Sapphire")) return 390000;
    if (weapon.includes("Butterfly") && pattern.includes("Ruby")) return 340000;
    if (weapon.includes("Butterfly") && pattern.includes("Gamma Doppler")) return 95000;
    if (weapon.includes("Butterfly") && pattern.includes("Fade")) return 165000;
    if (weapon.includes("Butterfly") && pattern.includes("Doppler")) return 82000;
    if (weapon.includes("Karambit") && pattern.includes("Fade")) return 140000;
    if (weapon.includes("Karambit") && pattern.includes("Gamma Doppler")) return 78000;
    if (weapon.includes("Karambit") && pattern.includes("Doppler")) return 65000;
    if (weapon.includes("Karambit") && pattern.includes("Case Hardened")) return 38000;
    if (weapon.includes("M9 Bayonet") && pattern.includes("Lore")) return 85000;
    if (weapon.includes("M9 Bayonet") && pattern.includes("Fade")) return 75000;
    if (weapon.includes("M9 Bayonet") && pattern.includes("Doppler")) return 55000;
    
    // Рукавички (перевіряємо строго тип Gloves)
    if (name.includes("Vice") && (cat === "Gloves" || weapon.includes("Gloves") || weapon.includes("Wraps"))) return 280000;
    if (name.includes("Pandora") && (cat === "Gloves" || weapon.includes("Gloves") || weapon.includes("Wraps"))) return 390000;

    if (name.includes("Fire Serpent") && weapon === "AK-47") return 45000;
    if (name.includes("Gold Arabesque") && weapon === "AK-47") return 110000;
    if (name.includes("Welcome to the Jungle") && weapon === "M4A1-S") return 85000;
    if (name.includes("Medusa") && weapon === "AWP") return 110000;
    if (name.includes("The Prince") && weapon === "AWP") return 120000;
    if (name.includes("Desert Hydra") && weapon === "AWP") return 95000;
    if (name.includes("Hot Rod") && weapon === "M4A1-S") return 45000;
    if (name.includes("Blue Phosphor") && weapon === "M4A1-S") return 32000;
    if (name.includes("Blaze") && weapon === "Desert Eagle") return 26000;
    if (name.includes("Case Hardened") && weapon === "AK-47") return 18500;
    if (name.includes("Vulcan") && weapon === "AK-47") return 14000;
    if (name.includes("Printstream") && weapon === "M4A1-S") return 7200;
    if (name.includes("Printstream") && weapon === "AWP") return 6400;
    if (name.includes("Printstream") && weapon === "Desert Eagle") return 3900;
    if (name.includes("Bloodsport") && weapon === "AK-47") return 5200;
    if (name.includes("Neon Rider") && weapon === "AK-47") return 4200;
    if (name.includes("Hyper Beast") && weapon === "AWP") return 2800;
    if (name.includes("Kill Confirmed") && weapon === "USP-S") return 3200;
    if (name.includes("Asiimov") && weapon === "AWP") return 3400;

    let hash = 0;
    const str = skin.id || name;
    for (let i = 0; i < str.length; i++) {
      hash = (hash << 5) - hash + str.charCodeAt(i);
      hash |= 0;
    }
    const seed = Math.abs(hash) % 1000;

    if (cat === "Knives" || weapon.includes("Knife") || weapon.includes("Bayonet") || weapon.includes("Karambit")) {
      let knifeTier = 12000;
      if (/Butterfly|Karambit|M9 Bayonet/.test(weapon)) knifeTier = 38000;
      else if (/Skeleton|Talon|Stiletto/.test(weapon)) knifeTier = 22000;
      else if (/Bayonet|Ursus|Nomad|Classic/.test(weapon)) knifeTier = 14000;
      else if (/Gut|Navaja|Shadow Daggers/.test(weapon)) knifeTier = 4800;

      let mult = 1.0;
      if (/Doppler|Gamma Doppler/.test(pattern)) mult = 2.4;
      else if (/Fade|Marble Fade/.test(pattern)) mult = 2.8;
      else if (/Lore|Tiger Tooth|Slaughter/.test(pattern)) mult = 1.8;
      else if (/Crimson Web|Autotronic/.test(pattern)) mult = 1.6;
      else if (/Case Hardened/.test(pattern)) mult = 1.4;
      else if (/Rust Coat|Safari Mesh|Forest DDPAT|Boreal/.test(pattern)) mult = 0.65;

      return Math.round((knifeTier * mult) + (seed * 8));
    }

    if (cat === "Gloves" || weapon.includes("Gloves") || weapon.includes("Wraps")) {
      let gloveTier = 6500;
      if (/Sport|Specialist/.test(weapon)) gloveTier = 18000;
      else if (/Moto|Driver/.test(weapon)) gloveTier = 9500;
      return Math.round(gloveTier + (seed * 9));
    }

    switch (rarity) {
      case "Contraband": return 185000;
      case "Extraordinary": return Math.round(15000 + (seed * 15));
      case "Covert": {
        const base = (cat === "Rifles" || weapon === "AWP") ? 2200 : 1200;
        return Math.round(base + (seed * 4));
      }
      case "Classified": {
        const base = (cat === "Rifles" || weapon === "AWP") ? 600 : 380;
        return Math.round(base + (seed * 1.5));
      }
      case "Restricted": {
        const base = (cat === "Rifles" || weapon === "AWP") ? 160 : 110;
        return Math.round(base + (seed * 0.4));
      }
      case "Mil-Spec Grade": return Math.round(25 + (seed * 0.12));
      case "Industrial Grade": return Math.round(8 + (seed * 0.04));
      case "Consumer Grade": return Math.round(2 + (seed * 0.02));
      default: return Math.round(50 + (seed * 0.2));
    }
  }

  function getRarityUk(r) {
    switch (r) {
      case "Contraband": return "Контрабандний";
      case "Extraordinary": return "Надзвичайне ★";
      case "Covert": return "Таємне";
      case "Classified": return "Засекречене";
      case "Restricted": return "Заборонене";
      case "Mil-Spec Grade": return "Армійська якість";
      case "Industrial Grade": return "Промислова якість";
      case "Consumer Grade": return "Ширпотреб";
      default: return r || "Звичайне";
    }
  }

  const cleaned = [];
  for (const s of raw) {
    if (!s.image) continue;
    const catName = s.category?.name || "";
    let catKey = "other";
    if (catName === "Knives" || s.weapon?.name?.includes("Knife") || s.weapon?.name?.includes("Bayonet") || s.weapon?.name?.includes("Karambit")) {
      catKey = "knives";
    } else if (catName === "Gloves" || s.weapon?.name?.includes("Gloves") || s.weapon?.name?.includes("Wraps")) {
      catKey = "gloves";
    } else if (catName === "Rifles") {
      catKey = (s.weapon?.name === "AWP" || s.weapon?.name === "SSG 08") ? "snipers" : "rifles";
    } else if (catName === "Pistols") {
      catKey = "pistols";
    } else if (catName === "SMGs") {
      catKey = "smgs";
    } else if (catName === "Heavy") {
      catKey = "heavy";
    }

    cleaned.push({
      id: s.id,
      name: s.pattern?.name || s.name,
      weapon: s.weapon?.name || "Weapon",
      fullName: s.name,
      category: catKey,
      rarity: s.rarity?.name || "Common",
      rarityUk: getRarityUk(s.rarity?.name),
      rarityColor: s.rarity?.color || "#eb4b4b",
      price: getSkinPrice(s),
      image: s.image,
      minFloat: s.min_float ?? 0.0,
      maxFloat: s.max_float ?? 1.0,
    });
  }

  const outFilePath = path.join(process.cwd(), "public", "data", "cs2-market.json");
  fs.writeFileSync(outFilePath, JSON.stringify(cleaned), "utf8");
  console.log(`✓ Оновлено ${cleaned.length} скінів у public/data/cs2-market.json!`);
}

main().catch(console.error);
