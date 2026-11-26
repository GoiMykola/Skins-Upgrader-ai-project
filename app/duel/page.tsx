"use client";

import { useState, useEffect } from "react";
import { LiveDropsTicker } from "@/components/live-drops-ticker";
import { getStoredInventory, removeSkinFromInventory, addSkinToInventory, type InventoryItem } from "@/lib/inventory-storage";
import { formatCoins, skins } from "@/app/data";
import { triggerConfetti, playJackpotSound } from "@/lib/confetti";
import { playClickSound, playTickSound } from "@/lib/sound-fx";
import { sanitizeImageUrl } from "@/lib/safe-url";

const BOTS = [
  { id: "b1", name: "🤖 Bot S1mple", rank: "Global Elite" },
  { id: "b2", name: "🤖 Bot ZywOo", rank: "Global Elite" },
  { id: "b3", name: "🤖 Bot M0NESY", rank: "Supreme" },
];

export default function DuelPage() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [selectedSkin, setSelectedSkin] = useState<InventoryItem | null>(null);
  const [selectedBot] = useState(BOTS[0]);
  const [botSkin, setBotSkin] = useState<any>(skins[0]);
  const [isDueling, setIsDueling] = useState(false);
  const [duelWinner, setDuelWinner] = useState<"player" | "bot" | null>(null);

  useEffect(() => {
    const inv = getStoredInventory();
    setInventory(inv);
    if (inv.length > 0) {
      setSelectedSkin(inv[0]);
      matchBotSkin(inv[0].price);
    }
  }, []);

  const matchBotSkin = (price: number) => {
    const matched = skins.filter((s) => Math.abs(s.price - price) < price * 0.3);
    setBotSkin(matched.length > 0 ? matched[Math.floor(Math.random() * matched.length)] : skins[0]);
  };

  const handleSelectSkin = (skin: InventoryItem) => {
    playClickSound();
    setSelectedSkin(skin);
    matchBotSkin(skin.price);
    setDuelWinner(null);
  };

  const handleStartDuel = () => {
    if (!selectedSkin || isDueling) return;
    setIsDueling(true);
    setDuelWinner(null);

    const playerWins = Math.random() < 0.52;

    let ticks = 0;
    const interval = setInterval(() => {
      ticks++;
      if (ticks % 3 === 0) playTickSound();
      if (ticks > 30) clearInterval(interval);
    }, 100);

    setTimeout(() => {
      setIsDueling(false);
      if (playerWins) {
        setDuelWinner("player");
        addSkinToInventory({
          name: botSkin.name,
          weapon: botSkin.weapon,
          price: botSkin.price,
          image: botSkin.image,
          rarity: botSkin.rarity || "Таємне",
          accent: botSkin.accent || "#ffd700",
          wear: "Прямо із заводу",
          floatValue: 0.01,
        });
        playJackpotSound();
        triggerConfetti();
      } else {
        setDuelWinner("bot");
        removeSkinFromInventory(selectedSkin.instanceId);
      }
      setInventory(getStoredInventory());
    }, 3500);
  };

  return (
    <div className="min-h-screen pb-20 bg-[#070910]">
            <LiveDropsTicker />

      <main className="mx-auto max-w-[1760px] px-4 pt-8 sm:px-6 lg:px-10 xl:px-12">
        <div className="text-center max-w-3xl mx-auto mb-8">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-400/10 px-4 py-1.5 text-xs font-black uppercase tracking-wider text-emerald-400 mb-3">
            ⚔️ CS2 UPGRADE DUELS (PVP)
          </div>
          <h1 className="text-3xl sm:text-5xl font-black text-white">Битва Апгрейдерів</h1>
          <p className="text-sm text-slate-400 mt-2">
            Кидай виклик кібер-ботам на рівних ставках. Переможець забирає обидва скіни собі в інвентар!
          </p>
        </div>

        <div className="rounded-3xl border border-white/10 bg-[#0c101c] p-6 sm:p-10 shadow-2xl">
          <div className="grid grid-cols-1 lg:grid-cols-[1fr_auto_1fr] items-center gap-8">
            <div className={`rounded-2xl border-2 p-6 text-center transition ${duelWinner === "player" ? "border-emerald-400 bg-emerald-500/15" : "border-white/10 bg-[#0e121e]"}`}>
              <span className="text-xs font-black uppercase text-emerald-400">ТВІЙ СКІН (ТИ)</span>
              {selectedSkin ? (
                <div className="my-4">
                  {sanitizeImageUrl(selectedSkin.image) && (
                    <img src={sanitizeImageUrl(selectedSkin.image)} alt={selectedSkin.name} className="h-32 object-contain mx-auto" />
                  )}
                  <p className="text-lg font-black text-white mt-2">{selectedSkin.weapon} | {selectedSkin.name}</p>
                  <p className="text-base font-mono font-black text-emerald-400">{formatCoins(selectedSkin.price)} GC</p>
                </div>
              ) : (
                <p className="text-sm text-slate-500 my-8">Обери скін нижче</p>
              )}
            </div>

            <div className="text-center">
              <span className="text-3xl font-black text-amber-400 block mb-3">VS</span>
              <button
                onClick={handleStartDuel}
                disabled={!selectedSkin || isDueling}
                className="rounded-2xl bg-gradient-to-r from-amber-500 via-rose-500 to-amber-500 hover:brightness-110 px-8 py-4 text-base font-black text-white shadow-xl shadow-amber-500/20 transition disabled:opacity-40"
              >
                {isDueling ? "Битва триває... ⚡" : "РОЗПОЧАТИ ДУЕЛЬ ⚔️"}
              </button>
              {duelWinner && (
                <p className={`mt-3 font-black text-sm ${duelWinner === "player" ? "text-emerald-400" : "text-rose-400"}`}>
                  {duelWinner === "player" ? "🎉 ПЕРЕМОГА! Обидва скіни твої!" : "💀 ПРОГРАШ! Бот забрав твій скін."}
                </p>
              )}
            </div>

            <div className={`rounded-2xl border-2 p-6 text-center transition ${duelWinner === "bot" ? "border-rose-400 bg-rose-500/15" : "border-white/10 bg-[#0e121e]"}`}>
              <div className="flex items-center justify-center gap-2 mb-2">
                <span className="text-xs font-black uppercase text-rose-400">{selectedBot.name}</span>
                <span className="text-[10px] bg-rose-500/20 text-rose-300 px-2 py-0.5 rounded-full">{selectedBot.rank}</span>
              </div>
              <div className="my-4">
                {sanitizeImageUrl(botSkin.image) && (
                  <img src={sanitizeImageUrl(botSkin.image)} alt={botSkin.name} className="h-32 object-contain mx-auto" />
                )}
                <p className="text-lg font-black text-white mt-2">{botSkin.weapon} | {botSkin.name}</p>
                <p className="text-base font-mono font-black text-rose-400">{formatCoins(botSkin.price)} GC</p>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8">
          <h3 className="text-xl font-black text-white mb-4">Обери свій скін для битви:</h3>
          <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-6 lg:grid-cols-8 gap-3">
            {inventory.map((item) => {
              const safeImg = sanitizeImageUrl(item.image);
              return (
                <div
                  key={item.instanceId}
                  onClick={() => handleSelectSkin(item)}
                  className={`rounded-2xl border p-3 flex flex-col justify-between items-center text-center cursor-pointer transition ${
                    selectedSkin?.instanceId === item.instanceId
                      ? "border-emerald-400 bg-emerald-500/20 scale-95"
                      : "border-white/10 bg-[#0e111a] hover:border-emerald-500/40"
                  }`}
                >
                  {safeImg && <img src={safeImg} alt={item.name} className="h-16 object-contain my-1" />}
                  <p className="text-xs font-black text-white truncate w-full">{item.name}</p>
                  <span className="text-xs font-mono text-emerald-400 font-bold mt-1">{formatCoins(item.price)} GC</span>
                </div>
              );
            })}
          </div>
        </div>
      </main>
    </div>
  );
}
