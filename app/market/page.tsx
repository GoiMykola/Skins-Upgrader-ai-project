"use client";

/* eslint-disable @next/next/no-img-element */
import { useState, useEffect, useMemo } from "react";
import Link from "next/link";
import { formatCoins, type MarketSkin, marketSkinToSkin } from "@/app/data";
import {
  getStoredBalance,
  updateStoredBalance,
  addSkinToInventory,
} from "@/lib/inventory-storage";
import { playWinSound, playClickSound } from "@/lib/sound-fx";

export default function MarketPage() {
  const [marketSkins, setMarketSkins] = useState<MarketSkin[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("all");
  const [selectedRarity, setSelectedRarity] = useState("all");
  const [priceSort, setPriceSort] = useState<"desc" | "asc">("desc");
  const [balance, setBalance] = useState(1500);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  useEffect(() => {
    setBalance(getStoredBalance());

    fetch("/data/cs2-market.json")
      .then((res) => res.json())
      .then((data: MarketSkin[]) => {
        setMarketSkins(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Помилка завантаження ринку:", err);
        setLoading(false);
      });

    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    return () => {
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
    };
  }, []);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  const handleBuySkin = (skin: MarketSkin) => {
    const currentBal = getStoredBalance();
    if (currentBal < skin.price) {
      showToast(
        `⚠️ Недостатньо GC! Твій баланс: ${currentBal.toLocaleString("uk-UA")} GC. Потрібно: ${skin.price.toLocaleString("uk-UA")} GC. Продай скіни в інвентарі або підніми баланс!`
      );
      return;
    }

    playWinSound();
    updateStoredBalance(-skin.price);
    const converted = marketSkinToSkin(skin);
    addSkinToInventory(converted);
    showToast(`🎉 Вітаємо! Скін ${skin.fullName} успішно куплено та додано в Інвентар!`);
  };

  const handleSelectForUpgrade = (skin: MarketSkin) => {
    playClickSound();
    const converted = marketSkinToSkin(skin);
    try {
      localStorage.setItem("goicoins_selected_target", JSON.stringify(converted));
    } catch {}
  };

  const categories = [
    { id: "all", label: "Всі категорії" },
    { id: "knives", label: "Ножі ★" },
    { id: "gloves", label: "Рукавички ★" },
    { id: "snipers", label: "Снайперки" },
    { id: "rifles", label: "Гвинтівки" },
    { id: "pistols", label: "Пістолети" },
    { id: "smgs", label: "ПП" },
    { id: "heavy", label: "Важке" },
  ];

  const rarities = [
    { id: "all", label: "Всі рідкості" },
    { id: "covert", label: "Таємне (Червоне)" },
    { id: "classified", label: "Засекречене (Рожеве)" },
    { id: "restricted", label: "Заборонене (Фіолетове)" },
    { id: "mil-spec", label: "Армійське (Синє)" },
    { id: "extraordinary", label: "Надзвичайне ★" },
    { id: "contraband", label: "Контрабандне" },
  ];

  const filteredSkins = useMemo(() => {
    return marketSkins
      .filter((skin) => {
        if (selectedCategory !== "all") {
          if (selectedCategory === "knives" && skin.category !== "knives") return false;
          if (selectedCategory === "gloves" && skin.category !== "gloves") return false;
          if (selectedCategory === "snipers" && skin.category !== "snipers") return false;
          if (selectedCategory === "rifles" && skin.category !== "rifles") return false;
          if (selectedCategory === "pistols" && skin.category !== "pistols") return false;
          if (selectedCategory === "smgs" && skin.category !== "smgs") return false;
          if (selectedCategory === "heavy" && skin.category !== "heavy") return false;
        }

        if (selectedRarity !== "all") {
          if (selectedRarity === "extraordinary" && !skin.rarityUk.includes("★")) return false;
          else if (selectedRarity !== "extraordinary" && !skin.rarity.toLowerCase().includes(selectedRarity)) return false;
        }

        if (search.trim()) {
          const q = search.toLowerCase().trim();
          const matchName = skin.fullName.toLowerCase().includes(q);
          const matchWeapon = skin.weapon.toLowerCase().includes(q);
          if (!matchName && !matchWeapon) return false;
        }

        return true;
      })
      .sort((a, b) => {
        return priceSort === "desc" ? b.price - a.price : a.price - b.price;
      });
  }, [marketSkins, selectedCategory, selectedRarity, search, priceSort]);

  return (
    <div className="mx-auto max-w-[1760px] px-4 py-8 sm:px-6 lg:px-10 xl:px-12 min-h-screen">
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 max-w-md rounded-2xl border border-emerald-500/40 bg-[#0e1614]/95 p-4 text-xs font-bold text-emerald-300 shadow-2xl backdrop-blur-md">
          {toastMessage}
        </div>
      )}

      {/* Верхній банер ринку Widescreen */}
      <div className="overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0c0f17] p-6 sm:p-8">
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div className="max-w-2xl">
            <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wider text-emerald-300">
              <span className="size-2 rounded-full bg-emerald-400 shadow-[0_0_8px_#10b981]" />
              Офіційний ринок CS2 · 2 246 скінів
            </div>
            <h1 className="mt-3 text-3xl font-black text-white sm:text-4xl">
              Повний Ринок Скінів Counter-Strike 2
            </h1>
            <p className="mt-2 text-sm text-slate-400 sm:text-base">
              Повний каталог скінів Counter-Strike 2 з офіційними зображеннями Steam. 
              Курс симулятора суворо калібровано: <span className="font-bold text-emerald-400">1 грн = 1 GoiCoin (GC)</span>.
            </p>
          </div>

          {/* Плашка балансу без кнопки +100 GC */}
          <div className="flex flex-col gap-3 rounded-2xl border border-white/[0.08] bg-black/40 p-5 min-w-[240px]">
            <span className="text-xs font-bold uppercase tracking-wider text-slate-400">Твій баланс</span>
            <p className="font-mono text-2xl font-black text-emerald-400">
              {balance.toLocaleString("uk-UA")} <span className="text-sm">GC</span>
            </p>
            <div className="flex gap-2">
              <Link
                href="/"
                className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-3 py-1.5 text-xs font-black text-[#05130d] text-center flex-1 transition"
              >
                До Апгрейдера ⚡
              </Link>
              <Link
                href="/inventory"
                className="rounded-xl border border-white/10 bg-white/5 px-3 py-1.5 text-xs font-bold text-slate-300 hover:bg-white/10 text-center flex-1 transition"
              >
                Інвентар 🎒
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* Панель фільтрів та пошуку */}
      <div className="mt-8 space-y-4 rounded-3xl border border-white/[0.08] bg-[#0c0f17] p-6">
        <div className="flex flex-col sm:flex-row gap-4 items-center justify-between">
          <div className="relative flex-1 w-full">
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Пошук скіна: AWP | Dragon Lore, AK-47, Printstream, Doppler..."
              className="w-full rounded-2xl border border-white/10 bg-black/50 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none focus:border-emerald-400 transition"
            />
          </div>

          <div className="flex items-center gap-2 shrink-0">
            <button
              onClick={() => {
                playClickSound();
                setPriceSort(priceSort === "desc" ? "asc" : "desc");
              }}
              className="flex items-center gap-2 rounded-2xl border border-white/10 bg-black/50 px-4 py-3 text-xs font-bold text-white hover:border-emerald-400 transition"
            >
              <span>Ціна:</span>
              <span className="text-emerald-400">
                {priceSort === "desc" ? "від дорогих ↓" : "від дешевих ↑"}
              </span>
            </button>
          </div>
        </div>

        {/* Категорії зброї */}
        <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
          {categories.map((cat) => (
            <button
              key={`market-cat-${cat.id}`}
              onClick={() => {
                playClickSound();
                setSelectedCategory(cat.id);
              }}
              className={`rounded-xl px-3.5 py-1.5 text-xs font-bold transition shrink-0 ${
                selectedCategory === cat.id
                  ? "bg-emerald-500 text-[#05130d] font-black"
                  : "border border-white/5 bg-white/5 text-slate-400 hover:text-white"
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Рідкості */}
        <div className="flex gap-2 overflow-x-auto pb-1 no-scrollbar">
          {rarities.map((r) => (
            <button
              key={`market-rarity-${r.id}`}
              onClick={() => {
                playClickSound();
                setSelectedRarity(r.id);
              }}
              className={`rounded-xl px-3 py-1 text-xs font-semibold transition shrink-0 ${
                selectedRarity === r.id
                  ? "border border-emerald-400 bg-emerald-400/20 text-emerald-300"
                  : "border border-white/5 bg-white/5 text-slate-400 hover:text-white"
              }`}
            >
              {r.label}
            </button>
          ))}
        </div>
      </div>

      {/* Список скінів на Widescreen сітці */}
      <div className="mt-8">
        <div className="mb-4 flex items-center justify-between text-xs text-slate-400">
          <span>Знайдено: <strong className="text-white">{filteredSkins.length}</strong> скінів</span>
        </div>

        {loading ? (
          <div className="py-20 text-center">
            <div className="inline-block size-8 animate-spin rounded-full border-4 border-emerald-500 border-t-transparent" />
            <p className="mt-3 text-sm text-slate-400">Завантажуємо каталог 2 246 скінів CS2...</p>
          </div>
        ) : filteredSkins.length === 0 ? (
          <div className="py-20 text-center">
            <p className="text-base font-bold text-slate-400">Скінів за вашим запитом не знайдено.</p>
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
            {filteredSkins.map((skin, idx) => (
              <article
                key={`market-skin-card-${skin.id}-${idx}`}
                className="group relative flex flex-col justify-between rounded-2xl border border-white/[0.08] bg-[#0c0f17] p-3.5 transition hover:-translate-y-1 hover:border-emerald-400/50 hover:shadow-xl hover:shadow-black/60"
              >
                <div>
                  <div
                    className="relative flex h-32 items-center justify-center overflow-hidden rounded-xl bg-black/40"
                    style={{
                      backgroundImage: `radial-gradient(circle at center, ${skin.rarityColor}20, transparent 75%)`,
                    }}
                  >
                    <img
                      src={skin.image}
                      alt={skin.fullName}
                      className="max-h-[85%] max-w-[90%] object-contain drop-shadow transition-transform group-hover:scale-110"
                      loading="lazy"
                    />
                    <span
                      className="absolute top-1.5 right-1.5 rounded px-1.5 py-0.5 text-[8px] font-black uppercase"
                      style={{ color: skin.rarityColor }}
                    >
                      {skin.rarityUk}
                    </span>
                  </div>

                  <div className="mt-3">
                    <p className="text-[10px] font-bold text-slate-500 uppercase truncate">
                      {skin.weapon}
                    </p>
                    <h3 className="text-xs font-bold text-white truncate">{skin.name}</h3>
                  </div>
                </div>

                <div className="mt-4 border-t border-white/[0.06] pt-3">
                  <div className="flex items-center justify-between mb-2">
                    <p className="font-mono text-sm font-black text-emerald-400">
                      {formatCoins(skin.price)} <span className="text-[10px]">GC</span>
                    </p>
                    <span className="text-[10px] text-slate-500">
                      ≈ {skin.price.toLocaleString("uk-UA")} грн
                    </span>
                  </div>

                  <div className="grid grid-cols-2 gap-1.5">
                    <button
                      onClick={() => handleBuySkin(skin)}
                      className="rounded-xl bg-emerald-500 hover:bg-emerald-400 py-1.5 text-center text-xs font-black text-[#05130d] transition"
                    >
                      Купити
                    </button>
                    <Link
                      href="/"
                      onClick={() => handleSelectForUpgrade(skin)}
                      className="rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 py-1.5 text-center text-xs font-bold text-slate-300 transition"
                    >
                      Ціль ⚡
                    </Link>
                  </div>
                </div>
              </article>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
