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
  const [minPrice, setMinPrice] = useState("");
  const [maxPrice, setMaxPrice] = useState("");
  const [balance, setBalance] = useState(1500);
  const [toastMessage, setToastMessage] = useState<string | null>(null);
  const [purchasedSkin, setPurchasedSkin] = useState<MarketSkin | null>(null);

  useEffect(() => {
    let active = true;
    queueMicrotask(() => {
      if (active) setBalance(getStoredBalance());
    });

    async function loadMarket() {
      try {
        let text = "";
        let res = await fetch("/data/cs2-market.json");
        if (res.ok) text = await res.text();

        if (!text || text.trim().startsWith("<")) {
          res = await fetch("/api/market");
          if (res.ok) text = await res.text();
        }

        if (text && !text.trim().startsWith("<")) {
          const data = JSON.parse(text) as MarketSkin[];
          if (Array.isArray(data) && data.length > 0) {
            setMarketSkins(data);
          }
        }
      } catch (err) {
        console.error("Помилка завантаження ринку:", err);
      } finally {
        setLoading(false);
      }
    }

    loadMarket();

    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    window.addEventListener("goi-balance-updated", handleBal as EventListener);
    return () => {
      active = false;
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

    setPurchasedSkin(skin);
    setTimeout(() => {
      setPurchasedSkin((prev) => (prev?.id === skin.id ? null : prev));
    }, 10000);
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

  const pricePresets = [
    { label: "Всі ціни", min: "", max: "" },
    { label: "< 500 GC", min: "", max: "500" },
    { label: "500 - 5 000 GC", min: "500", max: "5000" },
    { label: "5k - 25k GC", min: "5000", max: "25000" },
    { label: "25k - 100k GC", min: "25000", max: "100000" },
    { label: "> 100k GC ★", min: "100000", max: "" },
  ];

  const filteredSkins = useMemo(() => {
    const min = minPrice.trim() !== "" ? parseFloat(minPrice) : null;
    const max = maxPrice.trim() !== "" ? parseFloat(maxPrice) : null;

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

        const p = Number(skin.price) || 0;
        if (min !== null && !isNaN(min) && p < min) return false;
        if (max !== null && !isNaN(max) && p > max) return false;

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
  }, [marketSkins, selectedCategory, selectedRarity, search, priceSort, minPrice, maxPrice]);

  return (
    <div className="mx-auto max-w-[1760px] px-4 py-8 sm:px-6 lg:px-10 xl:px-12 min-h-screen">
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 max-w-md rounded-2xl border border-rose-500/40 bg-[#160c0e]/95 p-4 text-xs font-bold text-rose-300 shadow-2xl backdrop-blur-md animate-fade-in flex items-center gap-2">
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Інтерактивне вікно після покупки з кнопками переходу */}
      {purchasedSkin && (
        <div className="fixed bottom-6 right-6 z-50 w-full max-w-md overflow-hidden rounded-3xl border border-emerald-500/50 bg-[#0a0d14]/98 p-5 shadow-[0_0_60px_rgba(16,185,129,0.3)] backdrop-blur-xl animate-fade-in">
          <div className="flex items-start justify-between gap-3">
            <div className="flex items-center gap-3.5">
              <div
                className="relative flex size-14 shrink-0 items-center justify-center overflow-hidden rounded-2xl bg-black/60 border border-white/10"
                style={{
                  backgroundImage: `radial-gradient(circle at center, ${purchasedSkin.rarityColor || "#eb4b4b"}25, transparent 75%)`,
                }}
              >
                <img
                  src={purchasedSkin.image}
                  alt={purchasedSkin.fullName}
                  className="max-h-12 max-w-full object-contain drop-shadow"
                />
              </div>
              <div>
                <span className="text-xs font-black uppercase tracking-wider text-emerald-400">
                  🎉 УСПІШНА ПОКУПКА!
                </span>
                <h4 className="text-sm font-bold text-white truncate max-w-[240px]">
                  {purchasedSkin.fullName}
                </h4>
                <p className="text-xs font-mono font-black text-emerald-400 mt-0.5">
                  -{formatCoins(purchasedSkin.price)} GC · Додано в Інвентар
                </p>
              </div>
            </div>

            <button
              onClick={() => setPurchasedSkin(null)}
              className="flex size-9 items-center justify-center rounded-xl text-sm bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white text-xs font-bold transition"
              title="Закрити"
            >
              ✕
            </button>
          </div>

          <div className="mt-4 flex items-center gap-2">
            <Link
              href="/inventory"
              className="flex-1 rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 py-2.5 px-3 text-center text-xs font-bold text-slate-200 hover:text-white transition flex items-center justify-center gap-1.5"
            >
              <span>🎒</span>
              <span>В Інвентар</span>
            </Link>

            <Link
              href="/"
              onClick={() => handleSelectForUpgrade(purchasedSkin)}
              className="flex-1 rounded-xl bg-gradient-to-r from-emerald-400 to-teal-500 hover:brightness-110 py-2.5 px-3 text-center text-xs font-black text-[#05130d] shadow-lg shadow-emerald-500/25 transition flex items-center justify-center gap-1.5"
            >
              <span>⚡</span>
              <span>В Апгрейдер</span>
            </Link>
          </div>
        </div>
      )}

      {/* Верхній банер ринку Widescreen */}
      <div className="overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0c0f17] p-6 sm:p-8">
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div>
            <div className="flex items-center gap-2">
              <span className="rounded-md bg-emerald-400/20 px-2 py-0.5 text-xs font-bold text-emerald-300">
                LIVE MARKETPLACE
              </span>
              <span className="text-xs text-slate-400">Понад 2 200 офіційних скінів CS2</span>
            </div>
            <h1 className="mt-2 text-3xl font-black text-white sm:text-4xl">
              Ринок скінів Counter-Strike 2
            </h1>
            <p className="mt-1 text-xs text-slate-400">
              Купуй будь-який ніж, рукавички чи снайперку за GoiCoins або вибирай як ціль для апгрейдера. Курс
              симулятора суворо калібровано: <span className="font-bold text-emerald-400">1 грн = 1 GoiCoin (GC)</span>.
            </p>
          </div>

          <div className="flex items-center gap-4">
            <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 px-5 py-3 text-right">
              <p className="text-[10px] font-bold uppercase tracking-wider text-emerald-300">Твій баланс</p>
              <p className="mt-0.5 font-mono text-2xl font-black text-white">
                {formatCoins(balance)} <span className="text-sm font-bold text-emerald-400">GC</span>
              </p>
            </div>
            <Link
              href="/inventory"
              className="rounded-2xl border border-white/10 bg-white/5 hover:bg-white/10 px-5 py-3 text-xs font-bold text-slate-300 hover:text-white transition"
            >
              Мій інвентар 🎒
            </Link>
          </div>
        </div>
      </div>

      {/* Панель фільтрів та пошуку */}
      <div className="mt-6 rounded-3xl border border-white/[0.08] bg-[#0c0f17] p-5 shadow-lg">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
          <div className="relative flex-1">
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Пошук скіна: AWP | Dragon Lore, AK-47, Printstream, Doppler..."
              className="w-full rounded-2xl border border-white/10 bg-black/50 px-4 py-2.5 text-xs text-white placeholder-slate-500 focus:border-emerald-500 focus:outline-none transition"
            />
            {search && (
              <button
                onClick={() => setSearch("")}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-slate-400 hover:text-white"
              >
                ✕
              </button>
            )}
          </div>

          <div className="flex flex-wrap items-center gap-2.5">
            <div className="flex items-center gap-2 rounded-2xl border border-white/10 bg-black/40 px-3 py-1.5 shadow-inner">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
                Ціна (GC):
              </span>
              <div className="flex items-center gap-1.5">
                <input
                  type="number"
                  min="0"
                  placeholder="Від"
                  value={minPrice}
                  onChange={(e) => setMinPrice(e.target.value)}
                  className="w-20 sm:w-24 rounded-xl border border-white/10 bg-black/70 px-2.5 py-1 text-xs font-mono font-bold text-emerald-400 placeholder-slate-600 focus:border-emerald-400 focus:outline-none transition"
                />
                <span className="text-slate-500 font-bold text-xs">—</span>
                <input
                  type="number"
                  min="0"
                  placeholder="До"
                  value={maxPrice}
                  onChange={(e) => setMaxPrice(e.target.value)}
                  className="w-20 sm:w-24 rounded-xl border border-white/10 bg-black/70 px-2.5 py-1 text-xs font-mono font-bold text-emerald-400 placeholder-slate-600 focus:border-emerald-400 focus:outline-none transition"
                />
              </div>

              {(minPrice || maxPrice) && (
                <button
                  onClick={() => {
                    playClickSound();
                    setMinPrice("");
                    setMaxPrice("");
                  }}
                  title="Очистити фільтр цін"
                  className="flex size-5 items-center justify-center rounded-lg bg-rose-500/20 text-rose-300 hover:bg-rose-500/30 text-[10px] font-black transition"
                >
                  ✕
                </button>
              )}
            </div>

            <button
              onClick={() => {
                playClickSound();
                setPriceSort(priceSort === "desc" ? "asc" : "desc");
              }}
              className="flex items-center gap-1.5 rounded-2xl border border-white/10 bg-black/40 px-3.5 py-2 text-xs font-bold text-slate-300 hover:bg-white/5 hover:text-white transition shrink-0"
            >
              Ціна: {priceSort === "desc" ? "від дорогих ↓" : "від дешевих ↑"}
            </button>
          </div>
        </div>

        {/* Швидкі пресети цін */}
        <div className="mt-3.5 flex flex-wrap items-center gap-1.5 border-t border-white/5 pt-3">
          <span className="text-[10px] font-bold uppercase tracking-wider text-slate-500 mr-1">
            Швидка ціна:
          </span>
          {pricePresets.map((preset, idx) => {
            const isActive = minPrice === preset.min && maxPrice === preset.max;
            return (
              <button
                key={`preset-${idx}`}
                onClick={() => {
                  playClickSound();
                  setMinPrice(preset.min);
                  setMaxPrice(preset.max);
                }}
                className={`rounded-xl px-2.5 py-1 text-[11px] font-bold transition ${
                  isActive
                    ? "bg-emerald-500 text-[#05130d] shadow-sm shadow-emerald-500/20 font-black"
                    : "bg-white/[0.04] text-slate-400 hover:bg-white/[0.08] hover:text-slate-200"
                }`}
              >
                {preset.label}
              </button>
            );
          })}
        </div>

        {/* Категорії */}
        <div className="mt-3 flex flex-wrap gap-1.5 border-t border-white/5 pt-3">
          {categories.map((c) => (
            <button
              key={c.id}
              onClick={() => {
                playClickSound();
                setSelectedCategory(c.id);
              }}
              className={`rounded-xl px-4 sm:px-5 py-2.5 text-xs sm:text-sm font-bold transition ${
                selectedCategory === c.id
                  ? "bg-emerald-500 text-[#05130d] shadow-md shadow-emerald-500/20"
                  : "bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white"
              }`}
            >
              {c.label}
            </button>
          ))}
        </div>

        {/* Рідкості */}
        <div className="mt-3 flex flex-wrap gap-1.5">
          {rarities.map((r) => (
            <button
              key={r.id}
              onClick={() => {
                playClickSound();
                setSelectedRarity(r.id);
              }}
              className={`rounded-xl px-3.5 py-1.5 text-xs font-semibold transition ${
                selectedRarity === r.id
                  ? "bg-emerald-500/20 text-emerald-300 border border-emerald-500/40 font-bold"
                  : "bg-white/[0.03] text-slate-400 hover:bg-white/[0.08] hover:text-slate-200"
              }`}
            >
              {r.label}
            </button>
          ))}
        </div>
      </div>

      {/* Список скінів */}
      <div className="mt-6">
        <div className="mb-4 flex items-center justify-between text-xs text-slate-400">
          <div className="flex items-center gap-2">
            <span>
              Знайдено: <strong className="text-white font-mono text-sm">{filteredSkins.length}</strong> скінів
            </span>
            {(minPrice || maxPrice) && (
              <span className="rounded-full bg-emerald-500/10 px-2 py-0.5 text-[10px] font-bold text-emerald-300 border border-emerald-500/20">
                Ціна: {minPrice ? `від ${Number(minPrice).toLocaleString("uk-UA")} GC` : "від 0 GC"}{" "}
                {maxPrice ? `до ${Number(maxPrice).toLocaleString("uk-UA")} GC` : ""}
              </span>
            )}
          </div>
          {loading && <span className="text-emerald-400 animate-pulse font-bold">Завантаження бази скінів...</span>}
        </div>

        {filteredSkins.length === 0 && !loading && (
          <div className="rounded-3xl border border-white/5 bg-[#0c0f17] p-16 text-center text-slate-400 shadow-xl">
            <div className="text-4xl mb-3">🔍</div>
            <p className="text-base font-bold text-white mb-1">Скінів за вашим запитом не знайдено.</p>
            <p className="text-xs max-w-md mx-auto text-slate-400">
              Спробуйте змінити фільтри категорії або діапазон цін.
            </p>
          </div>
        )}

        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-7">
          {filteredSkins.map((skin) => (
            <div
              key={skin.id}
              className="group relative flex flex-col justify-between overflow-hidden rounded-2xl border border-white/10 bg-[#0e111a] p-3 transition hover:-translate-y-1 hover:border-emerald-500/40 hover:shadow-xl hover:shadow-emerald-500/10"
            >
              <div className="flex items-center justify-between">
                <span
                  className="rounded-md px-1.5 py-0.5 text-[9px] font-bold"
                  style={{
                    backgroundColor: `${skin.rarityColor}20`,
                    color: skin.rarityColor,
                  }}
                >
                  {skin.rarityUk}
                </span>
                <span className="font-mono text-xs font-black text-emerald-400">
                  {formatCoins(skin.price)} GC
                </span>
              </div>

              <div className="my-2 flex h-28 items-center justify-center">
                <img
                  src={skin.image}
                  alt={skin.fullName}
                  loading="lazy"
                  className="max-h-24 max-w-full object-contain transition group-hover:scale-105"
                  onError={(e) => {
                    (e.target as HTMLImageElement).src =
                      "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwhFQyvj8V7p8POXfDWadweB-Xxa_nRwvpnfSwNv7IHiQPFp1DYVyEbZY5xnrxtPjM7vnsgH_2o1A3t3x73z9yF-xW-I";
                  }}
                />
              </div>

              <div>
                <p className="text-[10px] text-slate-400 truncate">{skin.weapon}</p>
                <p className="font-bold text-white text-xs truncate" title={skin.name}>
                  {skin.name}
                </p>

                <div className="mt-2.5 flex gap-1.5">
                  <button
                    onClick={() => handleBuySkin(skin)}
                    className="flex-1 rounded-xl bg-emerald-500 hover:bg-emerald-400 py-2.5 text-center text-xs font-black text-[#05130d] shadow-sm transition active:scale-95"
                  >
                    Купити 🛒
                  </button>
                  <Link
                    href="/"
                    onClick={() => handleSelectForUpgrade(skin)}
                    title="Вибрати як ціль в Апгрейдері"
                    className="flex size-9 items-center justify-center rounded-xl text-sm border border-white/10 bg-white/5 hover:bg-white/10 text-xs text-slate-300 hover:text-white transition"
                  >
                    ⚡
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
