"use client";

/* eslint-disable @next/next/no-img-element */
import { useState, useEffect, useMemo } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import type { MarketSkin } from "@/app/data";
import { formatCoins, marketSkinToSkin } from "@/app/data";
import {
  getStoredBalance,
  updateStoredBalance,
  addSkinToInventory,
} from "@/lib/inventory-storage";
import { playClickSound, playWinSound, playLossSound } from "@/lib/sound-fx";

type CategoryFilter = "all" | "knives" | "gloves" | "snipers" | "rifles" | "pistols" | "smgs" | "heavy";
type RarityFilter = "all" | "gold" | "covert" | "classified" | "restricted" | "milspec" | "industrial";
type PriceTierFilter = "all" | "under500" | "500-5000" | "5000-50000" | "over50000";
type SortOption = "price-desc" | "price-asc" | "name-asc" | "rarity";

export default function MarketPage() {
  const router = useRouter();
  const [allSkins, setAllSkins] = useState<MarketSkin[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [balance, setBalance] = useState(1500);

  // Фільтри та пошук
  const [searchQuery, setSearchQuery] = useState("");
  const [category, setCategory] = useState<CategoryFilter>("all");
  const [rarity, setRarity] = useState<RarityFilter>("all");
  const [priceTier, setPriceTier] = useState<PriceTierFilter>("all");
  const [sortBy, setSortBy] = useState<SortOption>("price-desc");

  // Пагінація
  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 24;

  // Модалка огляду та сповіщення
  const [inspectSkin, setInspectSkin] = useState<MarketSkin | null>(null);
  const [toastMessage, setToastMessage] = useState<{ text: string; type: "success" | "error" } | null>(null);

  useEffect(() => {
    setBalance(getStoredBalance());

    const handleBal = (e: CustomEvent<number>) => {
      if (typeof e.detail === "number") setBalance(e.detail);
    };
    window.addEventListener("goi-balance-updated", handleBal as EventListener);

    async function loadMarket() {
      try {
        const res = await fetch("/data/cs2-market.json");
        if (!res.ok) throw new Error("HTTP error " + res.status);
        const data = await res.json();
        setAllSkins(data);
      } catch (err) {
        console.warn("Помилка завантаження cs2-market.json, використовуємо резервну базу:", err);
      } finally {
        setIsLoading(false);
      }
    }

    loadMarket();

    return () => {
      window.removeEventListener("goi-balance-updated", handleBal as EventListener);
    };
  }, []);

  const showToast = (text: string, type: "success" | "error") => {
    setToastMessage({ text, type });
    setTimeout(() => {
      setToastMessage(null);
    }, 3800);
  };

  const handleFaucet = () => {
    playWinSound();
    const updated = updateStoredBalance(100);
    setBalance(updated);
    showToast("Отримано +100 GC з крана балансу!", "success");
  };

  // Фільтрація та сортування
  const filteredSkins = useMemo(() => {
    return allSkins.filter((s) => {
      // Пошук
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase().trim();
        const matchName = s.name.toLowerCase().includes(q);
        const matchWeapon = s.weapon.toLowerCase().includes(q);
        const matchFull = s.fullName.toLowerCase().includes(q);
        if (!matchName && !matchWeapon && !matchFull) return false;
      }

      // Категорія
      if (category !== "all") {
        if (category === "smgs" && s.category !== "smgs") return false;
        else if (category === "heavy" && s.category !== "heavy") return false;
        else if (category !== "smgs" && category !== "heavy" && s.category !== category) return false;
      }

      // Рідкість
      if (rarity !== "all") {
        if (rarity === "gold") {
          const isGold =
            s.rarity === "Contraband" ||
            s.rarity === "Extraordinary" ||
            s.category === "knives" ||
            s.category === "gloves";
          if (!isGold) return false;
        } else if (rarity === "covert" && s.rarity !== "Covert") return false;
        else if (rarity === "classified" && s.rarity !== "Classified") return false;
        else if (rarity === "restricted" && s.rarity !== "Restricted") return false;
        else if (rarity === "milspec" && s.rarity !== "Mil-Spec Grade") return false;
        else if (rarity === "industrial" && (s.rarity !== "Industrial Grade" && s.rarity !== "Consumer Grade")) return false;
      }

      // Ціновий діапазон
      if (priceTier === "under500" && s.price >= 500) return false;
      if (priceTier === "500-5000" && (s.price < 500 || s.price > 5000)) return false;
      if (priceTier === "5000-50000" && (s.price < 5000 || s.price > 50000)) return false;
      if (priceTier === "over50000" && s.price <= 50000) return false;

      return true;
    }).sort((a, b) => {
      if (sortBy === "price-desc") return b.price - a.price;
      if (sortBy === "price-asc") return a.price - b.price;
      if (sortBy === "name-asc") return a.fullName.localeCompare(b.fullName);
      if (sortBy === "rarity") {
        const rarityScore = (r: string) => {
          if (r === "Contraband" || r === "Extraordinary") return 7;
          if (r === "Covert") return 6;
          if (r === "Classified") return 5;
          if (r === "Restricted") return 4;
          if (r === "Mil-Spec Grade") return 3;
          if (r === "Industrial Grade") return 2;
          return 1;
        };
        return rarityScore(b.rarity) - rarityScore(a.rarity);
      }
      return 0;
    });
  }, [allSkins, searchQuery, category, rarity, priceTier, sortBy]);

  // Пагінація
  const totalPages = Math.max(1, Math.ceil(filteredSkins.length / pageSize));
  const currentPageSafe = Math.min(currentPage, totalPages);
  const paginatedSkins = useMemo(() => {
    const start = (currentPageSafe - 1) * pageSize;
    return filteredSkins.slice(start, start + pageSize);
  }, [filteredSkins, currentPageSafe, pageSize]);

  const handlePageChange = (p: number) => {
    playClickSound();
    setCurrentPage(p);
    window.scrollTo({ top: 380, behavior: "smooth" });
  };

  // Дії: Купити
  const handleBuy = (skin: MarketSkin) => {
    playClickSound();
    const currentBal = getStoredBalance();
    if (currentBal < skin.price) {
      playLossSound();
      showToast(
        `⚠️ Недостатньо GC! Твій баланс: ${currentBal.toLocaleString("uk-UA")} GC. Потрібно: ${skin.price.toLocaleString("uk-UA")} GC. Скористайся краном +100 GC.`,
        "error"
      );
      return;
    }

    const updated = updateStoredBalance(-skin.price);
    setBalance(updated);
    addSkinToInventory(marketSkinToSkin(skin));
    playWinSound();
    showToast(`🎉 Придбано ${skin.fullName} за ${formatCoins(skin.price)} GC! Додано до інвентаря.`, "success");
  };

  // Дія: В Апгрейдер
  const handleUpgradeTarget = (skin: MarketSkin) => {
    playClickSound();
    localStorage.setItem("goicoins_selected_target", JSON.stringify(marketSkinToSkin(skin)));
    router.push("/");
  };

  return (
    <div className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
      {/* Тост сповіщення */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 max-w-md animate-bounce rounded-2xl border border-white/10 bg-[#0e121d] p-4 shadow-2xl backdrop-blur-xl">
          <div className="flex items-center gap-3">
            <span className="text-2xl">{toastMessage.type === "success" ? "🎁" : "⚠️"}</span>
            <p className={`text-sm font-bold ${toastMessage.type === "success" ? "text-emerald-300" : "text-amber-300"}`}>
              {toastMessage.text}
            </p>
          </div>
        </div>
      )}

      {/* Головний банер ринку */}
      <div className="relative overflow-hidden rounded-3xl border border-white/[0.08] bg-gradient-to-br from-[#0c0f18] via-[#101422] to-[#18110b] p-6 shadow-2xl sm:p-10">
        <div className="absolute right-0 top-0 -mr-16 -mt-16 size-80 rounded-full bg-amber-500/10 blur-3xl pointer-events-none" />
        
        <div className="flex flex-wrap items-center justify-between gap-6">
          <div className="max-w-2xl">
            <div className="inline-flex items-center gap-2 rounded-full border border-amber-500/30 bg-amber-500/10 px-3 py-1 text-xs font-black uppercase tracking-wider text-amber-400">
              <span>🔥 CS2 OFFICIAL MARKET</span>
              <span>•</span>
              <span>2 246 СКІНІВ В БАЗІ</span>
            </div>
            <h1 className="mt-3 text-3xl font-black text-white sm:text-5xl">
              Офіційний ринок скінів CS2
            </h1>
            <p className="mt-2 text-sm text-slate-400 sm:text-base">
              Повний каталог скінів Counter-Strike 2 з офіційними зображеннями Steam. 
              Курс симулятора суворо калібровано: <span className="font-bold text-amber-300">1 грн = 1 GoiCoin (GC)</span> за даними Lis-Skins та Steam Market.
            </p>
          </div>

          {/* Плашка балансу та швидкі кнопки */}
          <div className="flex flex-col gap-3 rounded-2xl border border-white/[0.08] bg-black/40 p-5">
            <div className="flex items-center justify-between gap-4">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-400">Твій баланс</span>
              <button
                onClick={handleFaucet}
                className="rounded-lg bg-emerald-500/20 px-2 py-0.5 text-xs font-black text-emerald-300 hover:bg-emerald-500/30 transition"
              >
                +100 GC Кран
              </button>
            </div>
            <p className="font-mono text-2xl font-black text-amber-300">
              {balance.toLocaleString("uk-UA")} <span className="text-sm">GC</span>
            </p>
            <div className="flex gap-2">
              <Link
                href="/"
                className="rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 px-3 py-1.5 text-xs font-black text-[#1a1005] hover:brightness-110 text-center flex-1"
              >
                До Апгрейдера ⚡
              </Link>
              <Link
                href="/inventory"
                className="rounded-xl border border-white/10 bg-white/5 px-3 py-1.5 text-xs font-bold text-slate-300 hover:bg-white/10 text-center flex-1"
              >
                Інвентар 🎒
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* Панель фільтрів та пошуку */}
      <div className="mt-8 space-y-4 rounded-3xl border border-white/[0.08] bg-[#0c0f17] p-6">
        {/* Пошуковий рядок */}
        <div className="relative">
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => {
              setSearchQuery(e.target.value);
              setCurrentPage(1);
            }}
            placeholder="Пошук за назвою скіна або зброї (наприклад: Dragon Lore, Doppler, AK-47, Printstream, Howl)..."
            className="w-full rounded-2xl border border-white/10 bg-black/50 px-5 py-3.5 pl-11 text-sm text-white placeholder-slate-500 outline-none transition focus:border-amber-400 focus:ring-1 focus:ring-amber-400"
          />
          <span className="absolute left-4 top-3.5 text-slate-400 text-lg">🔍</span>
          {searchQuery && (
            <button
              onClick={() => {
                setSearchQuery("");
                setCurrentPage(1);
              }}
              className="absolute right-4 top-3.5 text-xs font-bold text-slate-400 hover:text-white"
            >
              ✕ Очистити
            </button>
          )}
        </div>

        {/* Категорії */}
        <div className="flex gap-1.5 overflow-x-auto pb-1 no-scrollbar">
          {[
            { id: "all", label: "Усі скіни" },
            { id: "knives", label: "Ножі ★" },
            { id: "gloves", label: "Рукавички ★" },
            { id: "snipers", label: "Снайперки" },
            { id: "rifles", label: "Гвинтівки" },
            { id: "pistols", label: "Пістолети" },
            { id: "smgs", label: "Пістолети-кулемети" },
            { id: "heavy", label: "Важке" },
          ].map((cat) => (
            <button
              key={cat.id}
              onClick={() => {
                playClickSound();
                setCategory(cat.id as CategoryFilter);
                setCurrentPage(1);
              }}
              className={`shrink-0 rounded-xl px-3.5 py-2 text-xs font-bold transition ${
                category === cat.id
                  ? "bg-amber-400 text-[#1a1005] shadow-lg shadow-amber-400/20"
                  : "border border-white/5 bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white"
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Додаткові фільтри: Рідкість, Ціна, Сортування */}
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-3 pt-2 border-t border-white/[0.06]">
          {/* Фільтр рідкості */}
          <div>
            <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1">
              Рідкість
            </label>
            <select
              value={rarity}
              onChange={(e) => {
                setRarity(e.target.value as RarityFilter);
                setCurrentPage(1);
              }}
              className="w-full rounded-xl border border-white/10 bg-black/40 px-3 py-2 text-xs font-bold text-slate-300 outline-none"
            >
              <option value="all">Усі рідкості</option>
              <option value="gold">★ Надзвичайне / Контрабанда (Ножі, Рукавички)</option>
              <option value="covert">Таємне (Червоне)</option>
              <option value="classified">Засекречене (Рожеве)</option>
              <option value="restricted">Заборонене (Фіолетове)</option>
              <option value="milspec">Армійська якість (Синє)</option>
              <option value="industrial">Промислова якість / Ширпотреб</option>
            </select>
          </div>

          {/* Фільтр ціни */}
          <div>
            <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1">
              Діапазон цін (GC)
            </label>
            <select
              value={priceTier}
              onChange={(e) => {
                setPriceTier(e.target.value as PriceTierFilter);
                setCurrentPage(1);
              }}
              className="w-full rounded-xl border border-white/10 bg-black/40 px-3 py-2 text-xs font-bold text-slate-300 outline-none"
            >
              <option value="all">Усі ціни</option>
              <option value="under500">Бюджетні (&lt; 500 GC)</option>
              <option value="500-5000">Середні (500 - 5 000 GC)</option>
              <option value="5000-50000">Преміум (5 000 - 50 000 GC)</option>
              <option value="over50000">Елітні / Рідкісні (&gt; 50 000 GC)</option>
            </select>
          </div>

          {/* Сортування */}
          <div>
            <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1">
              Сортувати за
            </label>
            <select
              value={sortBy}
              onChange={(e) => {
                setSortBy(e.target.value as SortOption);
                setCurrentPage(1);
              }}
              className="w-full rounded-xl border border-white/10 bg-black/40 px-3 py-2 text-xs font-bold text-slate-300 outline-none"
            >
              <option value="price-desc">Ціна: від дорогих до дешевих</option>
              <option value="price-asc">Ціна: від дешевих до дорогих</option>
              <option value="name-asc">За назвою (А-Я / A-Z)</option>
              <option value="rarity">За рідкістю</option>
            </select>
          </div>
        </div>
      </div>

      {/* Статистика та лічильник результатів */}
      <div className="mt-6 flex items-center justify-between border-b border-white/[0.06] pb-3 text-xs text-slate-400">
        <div>
          {isLoading ? (
            <span>Завантаження бази скінів CS2...</span>
          ) : (
            <span>
              Знайдено: <strong className="text-white">{filteredSkins.length}</strong> скінів CS2
            </span>
          )}
        </div>
        <div>
          Сторінка <strong className="text-amber-400">{currentPageSafe}</strong> з {totalPages}
        </div>
      </div>

      {/* Сітка скінів ринку */}
      {isLoading ? (
        <div className="mt-8 grid grid-cols-1 gap-5 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={`skeleton-${i}`} className="h-72 animate-pulse rounded-2xl bg-white/5" />
          ))}
        </div>
      ) : filteredSkins.length === 0 ? (
        <div className="mt-16 text-center">
          <div className="text-5xl">🔍</div>
          <h3 className="mt-4 text-xl font-bold text-white">Нічого не знайдено</h3>
          <p className="mt-1 text-sm text-slate-400">Спробуйте змінити фільтри або пошуковий запит.</p>
          <button
            onClick={() => {
              setSearchQuery("");
              setCategory("all");
              setRarity("all");
              setPriceTier("all");
            }}
            className="mt-4 rounded-xl bg-white/10 px-4 py-2 text-xs font-bold text-white hover:bg-white/20"
          >
            Скинути всі фільтри
          </button>
        </div>
      ) : (
        <div className="mt-6 grid grid-cols-1 gap-5 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
          {paginatedSkins.map((skin) => (
            <div
              key={skin.id}
              className="group relative flex flex-col justify-between overflow-hidden rounded-2xl border border-white/[0.08] bg-[#0d1018] p-4 transition duration-200 hover:-translate-y-1 hover:border-white/20 hover:shadow-2xl hover:shadow-black/70"
            >
              {/* Фоновий контур кольору рідкості */}
              <div
                className="absolute inset-0 opacity-0 transition duration-300 group-hover:opacity-100 pointer-events-none rounded-2xl"
                style={{
                  boxShadow: `inset 0 0 20px ${skin.rarityColor}20`,
                  border: `1px solid ${skin.rarityColor}35`,
                }}
              />

              <div>
                {/* Зображення скіна */}
                <div
                  className="relative flex h-40 items-center justify-center overflow-hidden rounded-xl border border-white/[0.04] bg-[#080a10]"
                  style={{
                    backgroundImage: `radial-gradient(circle at center, ${skin.rarityColor}20, transparent 75%)`,
                  }}
                >
                  <img
                    src={skin.image}
                    alt={skin.fullName}
                    className="max-h-[85%] max-w-[90%] object-contain drop-shadow-[0_10px_16px_rgba(0,0,0,0.85)] transition-transform duration-300 group-hover:scale-110"
                    loading="lazy"
                  />
                  <span
                    className="absolute top-2 right-2 rounded-full px-2 py-0.5 text-[9px] font-black uppercase tracking-wide"
                    style={{
                      backgroundColor: `${skin.rarityColor}25`,
                      color: skin.rarityColor,
                      border: `1px solid ${skin.rarityColor}40`,
                    }}
                  >
                    {skin.rarityUk}
                  </span>
                </div>

                {/* Назва та зброя */}
                <div className="mt-3">
                  <p className="text-[11px] font-bold uppercase tracking-wider text-slate-500">
                    {skin.weapon}
                  </p>
                  <h3 className="font-bold text-white text-base truncate" title={skin.name}>
                    {skin.name}
                  </h3>
                </div>

                {/* Ціна */}
                <div className="mt-2 flex items-baseline justify-between border-t border-white/[0.06] pt-2">
                  <div>
                    <span className="font-mono text-lg font-black text-amber-300">
                      {formatCoins(skin.price)} GC
                    </span>
                    <p className="text-[10px] text-slate-500">
                      ≈ {skin.price.toLocaleString("uk-UA")} грн
                    </p>
                  </div>
                  <button
                    onClick={() => {
                      playClickSound();
                      setInspectSkin(skin);
                    }}
                    className="text-[11px] font-bold text-slate-400 hover:text-white underline"
                  >
                    Оглянути
                  </button>
                </div>
              </div>

              {/* Кнопки дій */}
              <div className="mt-4 flex gap-2">
                <button
                  onClick={() => handleBuy(skin)}
                  className="flex-1 rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 py-2 text-xs font-black text-[#1a1005] hover:brightness-110 transition shadow-md shadow-orange-500/15"
                >
                  Купити
                </button>
                <button
                  onClick={() => handleUpgradeTarget(skin)}
                  title="Обрати цей скін як ціль в Апгрейдері"
                  className="rounded-xl border border-white/10 bg-white/5 px-2.5 py-2 text-xs font-black text-amber-300 hover:bg-white/10 transition"
                >
                  ⚡
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Пагінація */}
      {totalPages > 1 && (
        <div className="mt-10 flex flex-wrap items-center justify-center gap-1.5">
          <button
            onClick={() => handlePageChange(Math.max(1, currentPageSafe - 1))}
            disabled={currentPageSafe === 1}
            className="rounded-xl border border-white/10 bg-white/5 px-3 py-2 text-xs font-bold text-slate-300 hover:bg-white/10 disabled:opacity-30"
          >
            ← Попередня
          </button>

          {Array.from({ length: Math.min(7, totalPages) }).map((_, idx) => {
            let pageNum = idx + 1;
            if (totalPages > 7) {
              if (currentPageSafe > 4) pageNum = currentPageSafe - 3 + idx;
              if (pageNum > totalPages) pageNum = totalPages - (6 - idx);
            }
            return (
              <button
                key={`page-btn-${pageNum}`}
                onClick={() => handlePageChange(pageNum)}
                className={`size-9 rounded-xl text-xs font-black transition ${
                  currentPageSafe === pageNum
                    ? "bg-amber-400 text-[#1a1005] shadow-lg shadow-amber-400/25"
                    : "border border-white/5 bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white"
                }`}
              >
                {pageNum}
              </button>
            );
          })}

          <button
            onClick={() => handlePageChange(Math.min(totalPages, currentPageSafe + 1))}
            disabled={currentPageSafe === totalPages}
            className="rounded-xl border border-white/10 bg-white/5 px-3 py-2 text-xs font-bold text-slate-300 hover:bg-white/10 disabled:opacity-30"
          >
            Наступна →
          </button>
        </div>
      )}

      {/* Модальне вікно огляду скіна */}
      {inspectSkin && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
          <div className="w-full max-w-lg rounded-3xl border border-white/10 bg-[#0e111a] p-6 shadow-2xl">
            <div className="flex items-center justify-between border-b border-white/[0.06] pb-3">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-slate-500">
                  {inspectSkin.weapon}
                </span>
                <h3 className="text-xl font-black text-white">{inspectSkin.name}</h3>
              </div>
              <button
                onClick={() => setInspectSkin(null)}
                className="size-8 rounded-full border border-white/10 bg-white/5 text-sm font-bold text-slate-400 hover:text-white"
              >
                ✕
              </button>
            </div>

            {/* Велике зображення */}
            <div
              className="my-5 relative flex h-60 items-center justify-center rounded-2xl border border-white/[0.06] bg-[#07090e]"
              style={{
                backgroundImage: `radial-gradient(circle at center, ${inspectSkin.rarityColor}25, transparent 70%)`,
              }}
            >
              <img
                src={inspectSkin.image}
                alt={inspectSkin.fullName}
                className="max-h-[85%] max-w-[85%] object-contain drop-shadow-[0_16px_28px_rgba(0,0,0,0.9)]"
              />
            </div>

            {/* Характеристики */}
            <div className="grid grid-cols-2 gap-3">
              <div className="rounded-xl border border-white/[0.06] bg-black/40 p-3">
                <span className="text-[10px] uppercase font-bold text-slate-400">Рідкість</span>
                <p className="mt-0.5 text-xs font-bold" style={{ color: inspectSkin.rarityColor }}>
                  {inspectSkin.rarityUk}
                </p>
              </div>
              <div className="rounded-xl border border-white/[0.06] bg-black/40 p-3">
                <span className="text-[10px] uppercase font-bold text-slate-400">Ціна (Lis-Skins)</span>
                <p className="mt-0.5 font-mono text-sm font-black text-amber-300">
                  {inspectSkin.price.toLocaleString("uk-UA")} GC (грн)
                </p>
              </div>
            </div>

            {/* Float шкала */}
            <div className="mt-4 rounded-xl border border-white/[0.06] bg-black/40 p-3">
              <div className="flex justify-between text-[10px] font-bold text-slate-400 uppercase">
                <span>Діапазон Float</span>
                <span>{inspectSkin.minFloat ?? 0.0} — {inspectSkin.maxFloat ?? 1.0}</span>
              </div>
              <div className="mt-2 h-2 w-full rounded-full bg-gradient-to-r from-emerald-500 via-amber-400 to-rose-600 relative">
                <div className="absolute top-1/2 left-[15%] size-3 -translate-y-1/2 rounded-full border-2 border-white bg-amber-400 shadow-md" />
              </div>
            </div>

            {/* Кнопки в модалці */}
            <div className="mt-6 flex gap-3">
              <button
                onClick={() => {
                  handleBuy(inspectSkin);
                  setInspectSkin(null);
                }}
                className="flex-1 rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 py-3 text-xs font-black text-[#1a1005] hover:brightness-110 shadow-lg"
              >
                Купити за {formatCoins(inspectSkin.price)} GC
              </button>
              <button
                onClick={() => {
                  handleUpgradeTarget(inspectSkin);
                }}
                className="rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-xs font-black text-amber-300 hover:bg-white/10"
              >
                В Апгрейдер ⚡
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
