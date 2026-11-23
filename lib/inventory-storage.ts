import { skins, inventorySkins, type Skin } from "@/app/data";

export type InventoryItem = Skin & { instanceId: string };

const INVENTORY_STORAGE_KEY = "goicoins_inventory_v3";
const BALANCE_STORAGE_KEY = "goicoins_balance_v3";

export function getStoredInventory(): InventoryItem[] {
  if (typeof window === "undefined") {
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  }
  try {
    const raw = localStorage.getItem(INVENTORY_STORAGE_KEY);
    if (!raw) {
      const initial = inventorySkins.map((s, idx) => ({
        ...s,
        instanceId: `default-${s.finish}-${idx}`,
      }));
      localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(initial));
      return initial;
    }
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed) && parsed.length > 0) {
      return parsed.map((item: Skin & { instanceId?: string }, idx: number) => ({
        ...item,
        instanceId:
          item.instanceId ||
          `item-${item.finish}-${idx}-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
      }));
    }
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  } catch {
    return inventorySkins.map((s, idx) => ({ ...s, instanceId: `default-${s.finish}-${idx}` }));
  }
}

export function addSkinToInventory(newSkin: Skin): InventoryItem[] {
  if (typeof window === "undefined") return [];
  try {
    const current = getStoredInventory();
    const newItem: InventoryItem = {
      ...newSkin,
      instanceId: `won-${newSkin.finish}-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
    };
    const updated = [newItem, ...current];
    localStorage.setItem(INVENTORY_STORAGE_KEY, JSON.stringify(updated));
    window.dispatchEvent(new CustomEvent("goi-inventory-updated", { detail: updated }));
    return updated;
  } catch {
    return [];
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
