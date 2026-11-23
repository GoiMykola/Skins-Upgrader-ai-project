"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { formatCoins } from "@/app/data";
import SkinTile from "@/app/components/skin-tile";
import { getStoredInventory, getStoredBalance, type InventoryItem } from "@/lib/inventory-storage";

export default function InventoryPage() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [balance, setBalance] = useState(1000);

  useEffect(() => {
    setInventory(getStoredInventory());
    setBalance(getStoredBalance());

    const handleInv = (e: CustomEvent<InventoryItem[]>) => {
      if (e.detail) setInventory(e.detail);
    };
    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };

    window.addEventListener("goi-inventory-updated", handleInv as EventListener);
    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    return () => {
      window.removeEventListener("goi-inventory-updated", handleInv as EventListener);
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
    };
  }, []);

  const totalValue = inventory.reduce((acc, s) => acc + s.price, 0);

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
      <div className="mb-10 overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0e111a] p-6 sm:p-8">
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div className="flex items-center gap-4">
            <div className="flex size-16 items-center justify-center rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 text-2xl font-black text-[#1a1005]">
              G
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-2xl font-black text-white">Гравець demo-player</h1>
                <span className="rounded-md bg-amber-400/20 px-2 py-0.5 text-xs font-bold text-amber-300">
                  Global Elite
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-0.5">ID: #GP-88391 · Акаунт симулятора</p>
            </div>
          </div>
          <div className="flex gap-4">
            <div className="rounded-2xl border border-white/[0.06] bg-black/30 px-5 py-3">
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Баланс GC</p>
              <p className="mt-0.5 font-mono text-xl font-black text-amber-300">
                {balance.toLocaleString("uk-UA")} GC
              </p>
            </div>
            <div className="rounded-2xl border border-white/[0.06] bg-black/30 px-5 py-3">
              <p className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Вартість інвентаря</p>
              <p className="mt-0.5 font-mono text-xl font-black text-white">
                {formatCoins(totalValue)} GC
              </p>
            </div>
          </div>
        </div>
      </div>

      <div>
        <div className="mb-6 flex items-center justify-between border-b border-white/[0.08] pb-4">
          <h2 className="text-xl font-bold text-white">
            Предмети в інвентарі ({inventory.length})
          </h2>
          <Link
            href="/"
            className="rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 px-4 py-2 text-xs font-black text-[#1a1005] hover:brightness-110"
          >
            До Апгрейдера ⚡
          </Link>
        </div>
        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {inventory.map((skin) => (
            <SkinTile key={`inventory-tile-${skin.instanceId}`} skin={skin} action="Апгрейдити" href="/" />
          ))}
        </div>
      </div>
    </div>
  );
}
