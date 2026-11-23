import { skins, inventorySkins, type Skin } from "@/app/data";

const INVENTORY_STORAGE_KEY = "goicoins_player_inventory";
const BALANCE_STORAGE_KEY = "goicoins_player_balance";

export function getStoredInventory(): Skin[] {
  if (typeof window === "undefined") return inventorySkins;
  try {
    const raw = localStorage.getItem(INVENTORY_STORAGE_KEY);
    if (!raw) {
      localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(inventorySkins));
      return inventorySkins;
    }
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) && parsed.length > 0 ? parsed : inventorySkins;
  } catch {
    return inventorySkins;
  }
}

export function addSkinToInventory(newSkin: Skin): Skin[] {
  if (typeof window === "undefined") return inventorySkins;
  try {
    const current = getStoredInventory();
    const updated = [newSkin, ...current];
    localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(updated));
    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: updated }));
    return updated;
  } catch {
    return inventorySkins;
  }
}

export function getStoredBalance(): number {
  if (typeof window === "undefined") return 1000;
  try {
    const raw = localStorage.getItem(BALANCE_STORAGE_KEY);
    return raw ? parseInt(raw, 10) : 1000;
  } catch {
    return 1000;
  }
}

export function updateStoredBalance(delta: number): number {
  if (typeof window === "undefined") return 1000;
  try {
    const current = getStoredBalance();
    const updated = Math.max(0, current + delta);
    localStorage.setItem(BALANCE_STORAGE_KEY, updated.toString());
    window.dispatchEvent(new CustomEvent("goi-balance-updated", { detail: updated }));
    return updated;
  } catch {
    return 1000;
  }
}
