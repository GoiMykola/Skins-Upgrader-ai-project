import { describe, expect, it } from "vitest";
import { addSkinAction, deleteSkinAction } from "@/app/catalog/actions";
import { getSkin } from "@/lib/data/db/skins";
import { submit } from "./helpers/submit";
import { signInAs } from "./helpers/users";

describe("точки доступу: скіни каталогу", () => {
  it("успішний виклик: гравець додає скін у каталог, і він є в базі", async () => {
    const uniqueName = "тест-" + Date.now();
    const result = await submit(addSkinAction, {
      name: uniqueName,
      weapon: "AK-47",
      category: "Штурмові гвинтівки",
      rarity: "Засекречена",
      price: "1200",
      image: "neon",
    });
    expect(result.status).toBe(201);
    expect(await getSkin(result.id ?? "")).not.toBeNull();
    if (result.id) await submit(deleteSkinAction, { id: result.id });
  });

  it("невалідні дані: порожня назва скіна повз форму відхиляється з кодом 400", async () => {
    const result = await submit(addSkinAction, {
      name: "   ",
      weapon: "AK-47",
      category: "Штурмові гвинтівки",
      rarity: "Засекречена",
      price: "1200",
      image: "neon",
    });
    expect(result.status).toBe(400);
    expect(result.fieldErrors?.name).toBeTruthy();
  });

  it("чужий запис: акаунт Б не бачить і не видаляє скін акаунта А", async () => {
    const uniqueName = "тест-owner-" + Date.now();
    const created = await submit(addSkinAction, {
      name: uniqueName,
      weapon: "AWP",
      category: "Снайперські",
      rarity: "Таємний",
      price: "2500",
      image: "hyper",
    });
    expect(created.status).toBe(201);

    await signInAs("B");
    expect(await getSkin(created.id ?? "")).toBeNull();
    expect((await submit(deleteSkinAction, { id: created.id ?? "" })).status).toBe(404);

    await signInAs("A");
    expect(await getSkin(created.id ?? "")).not.toBeNull();
    if (created.id) await submit(deleteSkinAction, { id: created.id });
  });
});
