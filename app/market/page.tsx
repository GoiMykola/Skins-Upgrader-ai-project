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

    async function loadMarket() {
      try {
        let text = "";
        let res = await fetch("/data/cs2-market.json");
        if (res.ok) {
          text = await res.text();
        }

        // Якщо повернувся HTML (редирект) або помилка, звертаємось до API
        if (!text || text.trim().startsWith("<")) {
          res = await fetch("/api/market");
          if (res.ok) {
            text = await res.text();
          }
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
        <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
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

          <div className="flex items-center gap-2">
            <button
              onClick={() => setPriceSort(priceSort === "desc" ? "asc" : "desc")}
              className="flex items-center gap-1.5 rounded-xl border border-white/10 bg-black/40 px-3.5 py-2 text-xs font-bold text-slate-300 hover:bg-white/5 transition"
            >
              Ціна: {priceSort === "desc" ? "від дорогих ↓" : "від дешевих ↑"}
            </button>
          </div>
        </div>

        {/* Категорії */}
        <div className="mt-4 flex flex-wrap gap-1.5 border-t border-white/5 pt-4">
          {categories.map((c) => (
            <button
              key={c.id}
              onClick={() => setSelectedCategory(c.id)}
              className={`rounded-xl px-3 py-1.5 text-xs font-bold transition ${
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
              onClick={() => setSelectedRarity(r.id)}
              className={`rounded-xl px-2.5 py-1 text-[11px] font-medium transition ${
                selectedRarity === r.id
                  ? "bg-emerald-500/20 text-emerald-300 border border-emerald-500/40"
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
          <span>
            Знайдено: <strong className="text-white">{filteredSkins.length}</strong> скінів
          </span>
          {loading && <span className="text-emerald-400 animate-pulse">Завантаження бази скінів...</span>}
        </div>

        {filteredSkins.length === 0 && !loading && (
          <div className="rounded-3xl border border-white/5 bg-[#0c0f17] p-16 text-center text-slate-400">
            <p className="text-base font-bold text-white mb-1">Скінів за вашим запитом не знайдено.</p>
            <p className="text-xs">Спробуйте змінити фільтри категорії або пошуковий запит.</p>
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
                    className="flex-1 rounded-xl bg-emerald-500 hover:bg-emerald-400 py-1.5 text-center text-[10px] font-black text-[#05130d] shadow-sm transition active:scale-95"
                  >
                    Купити 🛒
                  </button>
                  <Link
                    href="/"
                    onClick={() => handleSelectForUpgrade(skin)}
                    title="Вибрати як ціль в Апгрейдері"
                    className="flex size-7 items-center justify-center rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 text-xs text-slate-300 hover:text-white transition"
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
