import Link from "next/link";
import { formatCoins } from "@/app/data";

const MARKET_PREVIEW_ITEMS = [
  {
    name: "AK-47 | Neon Rider",
    priceUah: 4200,
    priceGc: 4200,
    discount: "-18%",
    wear: "Factory New",
    rarity: "Covert",
    color: "#eb4b4b",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwlcK3wiFO0POlV6poL_6sHG6UxPxJvOhuRz39xkQhsTnVzoygdy7Ea1UoCZQkRe9bs0brl9TvN-m0tVHYjY5CyS35jjQJsHhk4o5zcA",
  },
  {
    name: "AWP | Hyper Beast",
    priceUah: 2800,
    priceGc: 2800,
    discount: "-15%",
    wear: "Field-Tested",
    rarity: "Covert",
    color: "#eb4b4b",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyLwiYbf_jdk7uW-V6x0MPWBMWWVwP1ij-1gSCGn20pxtm_WzNuoeHKeaFAnCZUiTe5bt0HqxofmZOrm5Q2IjoMQzS_5iShXrnE8NzWs__c",
  },
  {
    name: "M4A4 | Howl",
    priceUah: 185000,
    priceGc: 185000,
    discount: "-10%",
    wear: "Minimal Wear",
    rarity: "Contraband",
    color: "#e4ae39",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL8ypexwiFO0P_6afVSKP-EAm6extF6ueZhW2exwkl2tmTXwt39eCiUPQR2DMN4TOVetUK8xoLgM-K341eM2otDnC6okGoXufBz_TAB",
  },
  {
    name: "★ Butterfly Knife | Gamma Doppler",
    priceUah: 420000,
    priceGc: 420000,
    discount: "-22%",
    wear: "Factory New",
    rarity: "Extraordinary",
    color: "#34d399",
    image: "https://community.akamai.steamstatic.com/economy/image/i0CoZ81Ui0m-9KwlBY1L_18myuGuq1wfhWSaZgMttyVfPaERSR0Wqmu7LAocGIGz3UqlXOLrxM-vMGmW8VNxu5Dx60noTyL6kJ_m-B1Z-ua6bbZrLOmsD2qvxONzouBlSxa-lA8lvziMgIr9HifOOV5kFJp2Ee9b4Rntm4GxY7_ntQHc2o1DmH6r3Hgcv3w4t-pXU6ZzrPHQjQnfcepq0dwfRJw",
  },
];

export default function MarketPage() {
  return (
    <div className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
      <div className="mb-8">
        <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/20 bg-emerald-400/10 px-3.5 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-300">
          <span className="size-2 rounded-full bg-emerald-400 shadow-[0_0_8px_#34d399]" />
          КУРС: 1 ГРН = 1 GOICOIN (GC) · LIS-SKINS & STEAM API
        </div>

        <h1 className="mt-4 text-3xl font-black text-white sm:text-5xl">
          Ринок скінів CS2{" "}
          <span className="bg-gradient-to-r from-amber-300 via-orange-400 to-rose-500 bg-clip-text text-transparent">
            (Marketplace)
          </span>
        </h1>

        <p className="mt-3 max-w-2xl text-sm sm:text-base text-slate-400">
          Офіційний внутрішній маркетплейс симулятора. Ціни синхронізуються з найбільшими торговими майданчиками (Lis-Skins, Buff163, Steam Market).
        </p>
      </div>

      <div className="relative mb-12 overflow-hidden rounded-3xl border border-amber-500/30 bg-[#0e111a] p-6 shadow-2xl backdrop-blur-xl sm:p-8">
        <div className="absolute -right-20 -top-20 size-72 rounded-full bg-amber-500/10 blur-3xl pointer-events-none" />

        <div className="flex flex-wrap items-center justify-between gap-4 border-b border-white/[0.08] pb-6">
          <div>
            <span className="rounded-md bg-amber-400/20 px-2.5 py-1 text-xs font-black uppercase tracking-wider text-amber-300">
              МОДУЛЬ У РОЗРОБЦІ
            </span>
            <h2 className="mt-2 text-2xl font-black text-white">
              Скоро: понад 1 500+ скінів із ринку CS2
            </h2>
            <p className="mt-1 text-xs sm:text-sm text-slate-300">
              У наступному оновленні кожен скін буде доступний для миттєвої купівлі за курсом 1 грн = 1 GC.
            </p>
          </div>

          <Link
            href="/"
            className="rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 px-6 py-3 text-sm font-black text-[#1a1104] shadow-lg shadow-orange-500/20 hover:brightness-110 transition"
          >
            До Апгрейдера ⚡
          </Link>
        </div>

        <div className="mt-6 grid gap-4 sm:grid-cols-3">
          <div className="rounded-2xl border border-white/[0.06] bg-black/40 p-4">
            <p className="text-xs font-bold uppercase tracking-wider text-amber-300">01 · Курс 1 до 1</p>
            <h3 className="mt-1 text-base font-bold text-white">1 грн = 1 GoiCoin</h3>
            <p className="mt-1 text-xs text-slate-400">
              Прозоре ціноутворення, еквівалентне реальним гривням на ринку України.
            </p>
          </div>

          <div className="rounded-2xl border border-white/[0.06] bg-black/40 p-4">
            <p className="text-xs font-bold uppercase tracking-wider text-emerald-400">02 · Lis-Skins API</p>
            <h3 className="mt-1 text-base font-bold text-white">Реальні знижки до -25%</h3>
            <p className="mt-1 text-xs text-slate-400">
              Ціни зі знижками від світових P2P-майданчиків для максимальної вигоди.
            </p>
          </div>

          <div className="rounded-2xl border border-white/[0.06] bg-black/40 p-4">
            <p className="text-xs font-bold uppercase tracking-wider text-violet-400">03 · Всі категорії</p>
            <h3 className="mt-1 text-base font-bold text-white">Ножі, Рукавички, Кейси</h3>
            <p className="mt-1 text-xs text-slate-400">
              Автоматичний імпорт усіх ножів-метеликів, керамбітів та скінів CS2.
            </p>
          </div>
        </div>
      </div>

      <div>
        <div className="mb-6 flex items-center justify-between border-b border-white/[0.08] pb-4">
          <h2 className="text-xl font-bold text-white">Попередній перегляд пропозицій ринку</h2>
          <span className="text-xs font-mono text-emerald-400">Статус: Синхронізовано з CDN</span>
        </div>

        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {MARKET_PREVIEW_ITEMS.map((item) => (
            <div
              key={item.name}
              className="relative rounded-2xl border border-white/[0.08] bg-[#0e111a] p-4 transition hover:-translate-y-1 hover:border-white/20 hover:shadow-xl"
            >
              <span className="absolute top-3 left-3 rounded-md bg-emerald-500/20 px-2 py-0.5 text-[10px] font-bold text-emerald-300 border border-emerald-500/30">
                {item.discount} LIS-SKINS
              </span>

              <div className="my-6 flex h-36 items-center justify-center">
                <img
                  src={item.image}
                  alt={item.name}
                  className="max-h-full max-w-full object-contain drop-shadow-[0_12px_20px_rgba(0,0,0,0.85)]"
                />
              </div>

              <div className="border-t border-white/[0.06] pt-3">
                <p className="text-sm font-bold text-white truncate">{item.name}</p>
                <p className="text-xs text-slate-400 mt-0.5">{item.wear}</p>

                <div className="mt-3 flex items-center justify-between">
                  <div>
                    <span className="font-mono text-base font-black text-amber-300">
                      {formatCoins(item.priceGc)} GC
                    </span>
                    <span className="block text-[10px] text-slate-500">
                      ≈ {formatCoins(item.priceUah)} грн
                    </span>
                  </div>

                  <span className="rounded-lg border border-white/10 bg-white/5 px-2.5 py-1 text-xs font-bold text-slate-400">
                    Незабаром
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
