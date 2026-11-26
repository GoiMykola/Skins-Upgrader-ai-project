"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { LiveDropsTicker } from "@/components/live-drops-ticker";
import { getStoredInventory, removeSkinFromInventory, addSkinToInventory, type InventoryItem } from "@/lib/inventory-storage";
import { formatCoins, skins, type Skin } from "@/app/data";
import { triggerConfetti, playJackpotSound } from "@/lib/confetti";
import { playClickSound } from "@/lib/sound-fx";
import { sanitizeImageUrl } from "@/lib/safe-url";

export default function ContractsPage() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [isSigning, setIsSigning] = useState(false);
  const [craftedSkin, setCraftedSkin] = useState<Skin | null>(null);

  useEffect(() => {
    let active = true;
    queueMicrotask(() => {
      if (active) setInventory(getStoredInventory());
    });
    return () => {
      active = false;
    };
  }, []);

  const selectedItems = inventory.filter((item) => selectedIds.includes(item.instanceId));
  const totalValue = selectedItems.reduce((acc, item) => acc + item.price, 0);
  const estimatedOutcomePrice = Math.round(totalValue * 1.35);

  const toggleSelect = (instanceId: string) => {
    playClickSound();
    if (selectedIds.includes(instanceId)) {
      setSelectedIds(selectedIds.filter((id) => id !== instanceId));
    } else {
      if (selectedIds.length >= 10) return;
      setSelectedIds([...selectedIds, instanceId]);
    }
  };

  const handleSignContract = () => {
    if (selectedIds.length < 3 || isSigning) return;
    setIsSigning(true);
    setCraftedSkin(null);

    setTimeout(() => {
      const eligiblePool = skins.filter((s) => s.price >= totalValue * 0.9);
      const chosen = eligiblePool.length > 0
        ? eligiblePool[Math.floor(Math.random() * eligiblePool.length)]
        : skins[Math.floor(Math.random() * skins.length)];

      selectedIds.forEach((id) => removeSkinFromInventory(id));

      addSkinToInventory({
        name: chosen.name,
        weapon: chosen.weapon,
        price: chosen.price,
        image: chosen.image,
        rarity: chosen.rarity || "Таємне",
        accent: chosen.accent || "#eb4b4b",
        wear: "Прямо із заводу",
        floatValue: 0.03,
      });

      setInventory(getStoredInventory());
      setSelectedIds([]);
      setCraftedSkin(chosen);
      setIsSigning(false);
      playJackpotSound();
      triggerConfetti();
    }, 2500);
  };

  return (
    <div className="min-h-screen pb-20 bg-[#070910]">
            <LiveDropsTicker />

      <main className="mx-auto max-w-[1760px] px-4 pt-8 sm:px-6 lg:px-10 xl:px-12">
        <div className="text-center max-w-3xl mx-auto mb-8">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-400/10 px-4 py-1.5 text-xs font-black uppercase tracking-wider text-emerald-400 mb-3">
            📜 КРАФТ ТА ОБМІН СТАРИХ СКІНІВ
          </div>
          <h1 className="text-3xl sm:text-5xl font-black text-white">Контракти обміну CS2</h1>
          <p className="text-sm text-slate-400 mt-2">
            Поклади від 3 до 10 скінів зі свого інвентарю для підписання контракту на один скін вищого ґатунку!
          </p>
        </div>

        <div className="rounded-3xl border border-white/10 bg-[#0c101c] p-6 sm:p-8 shadow-2xl relative overflow-hidden">
          <div className="flex flex-col lg:flex-row items-center justify-between gap-6 border-b border-white/10 pb-6">
            <div>
              <p className="text-xs font-bold text-slate-400 uppercase">Слотів заповнено: {selectedIds.length} з 10 (мін. 3)</p>
              <p className="text-2xl font-black text-white mt-1">
                Загальна вартість депозиту: <span className="text-emerald-400 font-mono">{formatCoins(totalValue)} GC</span>
              </p>
            </div>
            <div className="text-right">
              <p className="text-xs font-bold text-slate-400 uppercase">Очікуваний виграшний клас</p>
              <p className="text-2xl font-black text-amber-400 font-mono">~{formatCoins(estimatedOutcomePrice)} GC (+35% Boost)</p>
            </div>
            <button
              onClick={handleSignContract}
              disabled={selectedIds.length < 3 || isSigning}
              className="rounded-2xl bg-gradient-to-r from-emerald-500 to-teal-400 hover:brightness-110 px-8 py-4 text-base font-black text-[#05130d] shadow-lg shadow-emerald-500/25 transition disabled:opacity-40"
            >
              {isSigning ? "Підписання контракту... ✍️" : `Підписати контракт (${selectedIds.length}/10)`}
            </button>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-5 lg:grid-cols-10 gap-3 my-6">
            {Array.from({ length: 10 }).map((_, idx) => {
              const item = selectedItems[idx];
              return (
                <div
                  key={`slot-${idx}`}
                  onClick={() => item && toggleSelect(item.instanceId)}
                  className={`h-28 rounded-2xl border-2 flex flex-col items-center justify-center p-2 transition cursor-pointer ${
                    item
                      ? "border-emerald-500 bg-emerald-500/10 hover:border-rose-400"
                      : "border-dashed border-white/10 bg-white/[0.02]"
                  }`}
                >
                  {item ? (
                    <>
                      {sanitizeImageUrl(item.image) && (
                        <img src={sanitizeImageUrl(item.image)} alt={item.name} className="h-12 object-contain" />
                      )}
                      <p className="text-[10px] font-bold text-white truncate w-full text-center mt-1">{item.name}</p>
                      <span className="text-[9px] font-mono text-emerald-400 font-black">{formatCoins(item.price)} GC</span>
                    </>
                  ) : (
                    <span className="text-xs text-slate-600 font-bold">Слот #{idx + 1}</span>
                  )}
                </div>
              );
            })}
          </div>

          {craftedSkin && (
            <div className="mt-6 rounded-2xl border-2 border-emerald-400 bg-emerald-500/20 p-6 text-center animate-bounce">
              <p className="text-xs font-black uppercase text-emerald-400">🎉 КОНТРАКТ УСПІШНО ПІДПИСАНО! ОТРИМАНО:</p>
              <div className="my-3 flex justify-center">
                {sanitizeImageUrl(craftedSkin.image) && (
                  <img src={sanitizeImageUrl(craftedSkin.image)} alt={craftedSkin.name} className="h-28 object-contain" />
                )}
              </div>
              <p className="text-xl font-black text-white">{craftedSkin.weapon} | {craftedSkin.name}</p>
              <p className="text-base font-mono font-black text-emerald-400 mt-1">{formatCoins(craftedSkin.price)} GC</p>
            </div>
          )}
        </div>

        <div className="mt-8">
          <h3 className="text-xl font-black text-white mb-4">Обери скіни зі свого інвентарю:</h3>
          {inventory.length === 0 ? (
            <div className="text-center py-12 text-slate-500">
              Твій інвентар порожній. Купи скіни на <Link href="/market" className="text-emerald-400 underline">Ринку</Link> або виграй в Апгрейдері!
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-6 lg:grid-cols-8 gap-3">
              {inventory.map((item) => {
                const isSelected = selectedIds.includes(item.instanceId);
                const safeItemImage = sanitizeImageUrl(item.image);
                return (
                  <div
                    key={item.instanceId}
                    onClick={() => toggleSelect(item.instanceId)}
                    className={`rounded-2xl border p-3 flex flex-col justify-between items-center text-center cursor-pointer transition ${
                      isSelected
                        ? "border-emerald-400 bg-emerald-500/20 scale-95"
                        : "border-white/10 bg-[#0e111a] hover:border-emerald-500/40"
                    }`}
                  >
                    {safeItemImage && (
                      <img src={safeItemImage} alt={item.name} className="h-16 object-contain my-1" />
                    )}
                    <p className="text-xs font-black text-white truncate w-full">{item.name}</p>
                    <span className="text-xs font-mono text-emerald-400 font-bold mt-1">{formatCoins(item.price)} GC</span>
                    <button className="mt-2 w-full rounded-xl bg-white/5 py-1 text-[10px] font-black text-slate-300">
                      {isSelected ? "✓ Обрано" : "+ Додати"}
                    </button>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
