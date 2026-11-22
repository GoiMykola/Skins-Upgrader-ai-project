import { describe, expect, it } from "vitest";
import { createSkin, deleteSkin, getSkin } from "@/lib/data/db/skins";

describe("операції зі скінами в базі Supabase", () => {
  it("створений скін читається назад", async () => {
    const uniqueName = "тест-" + Date.now();
    const created = await createSkin({
      name: uniqueName,
      weapon: "AK-47",
      category: "Штурмові гвинтівки",
      rarity: "Засекречена",
      price: 1500,
      image: "neon",
    });
    const found = await getSkin(created.id);
    expect(found?.name).toBe(uniqueName);
    if (created.id) await deleteSkin(created.id);
  });

  it("видалений скін не знаходиться", async () => {
    const uniqueName = "тест-del-" + Date.now();
    const created = await createSkin({
      name: uniqueName,
      weapon: "AWP",
      category: "Снайперські",
      rarity: "Таємний",
      price: 3000,
      image: "hyper",
    });
    expect(await getSkin(created.id)).not.toBeNull();
    await deleteSkin(created.id);
    expect(await getSkin(created.id)).toBeNull();
  });

  it("обов'язкове поле не приймає порожнє значення", async () => {
    await expect(
      createSkin({
        name: "   ",
        weapon: "M4A4",
        category: "Штурмові гвинтівки",
        rarity: "Армійська",
        price: 500,
        image: "gold",
      }),
    ).rejects.toThrow();
  });
});
