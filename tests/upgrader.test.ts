import { describe, expect, it } from "vitest";
import { getUserBalance, acquireSkin, listUserInventory } from "@/lib/data/inventory";
import { calculateUpgradeChance, executeUpgrade } from "@/lib/data/upgrades";

describe("GoiCoins Skin Simulator - Критерії приймання MVP", () => {
  it("Ф1.1: новий користувач має стартовий баланс 1000 GoiCoins", async () => {
    const balance = await getUserBalance("user-1");
    expect(balance).toBe(1000);
  });

  it("Ф2.1: придбання скіна додає його до інвентаря гравця", async () => {
    await acquireSkin("user-1", "skin-ak47");
    const items = await listUserInventory("user-1");
    expect(items.length).toBeGreaterThan(0);
  });

  it("Ф3.1: розрахунок шансу апгрейду повертає коректний відсоток", async () => {
    const chance = await calculateUpgradeChance(100, 200);
    expect(chance).toBe(50);
  });

  it("Ф3.3: запуск апгрейду повертає розрахований результат та повідомлення", async () => {
    const result = await executeUpgrade("user-1", "inv-1", "skin-howl");
    expect(result.message).not.toBe("");
    expect(result.chance).toBeGreaterThan(0);
  });
});
