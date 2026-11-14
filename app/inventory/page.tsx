import Link from "next/link";
import SkinTile from "../components/skin-tile";
import { formatCoins, inventorySkins } from "../data";

const inventoryValue = inventorySkins.reduce((total, skin) => total + skin.price, 0);

export default function InventoryPage() {
  return (
    <div className="mx-auto max-w-7xl px-5 pb-16 pt-10 lg:px-8">
      <div className="flex flex-col justify-between gap-6 sm:flex-row sm:items-end">
        <div>
          <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-violet-300">Особиста колекція</p>
          <h1 className="mt-3 text-3xl font-black tracking-tight text-white sm:text-4xl">Мій інвентар</h1>
          <p className="mt-2 text-sm text-slate-400">Предмети, які вже є у твоєму сховищі.</p>
        </div>
        <div className="flex gap-3">
          <div className="rounded-2xl border border-amber-300/15 bg-amber-300/[0.05] px-5 py-3">
            <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-amber-200/60">Баланс</p>
            <p className="mt-1 font-mono text-xl font-bold text-amber-200">1 000 <span className="text-xs">GC</span></p>
          </div>
          <div className="rounded-2xl border border-white/[0.07] bg-white/[0.025] px-5 py-3">
            <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-slate-500">Вартість скінів</p>
            <p className="mt-1 font-mono text-xl font-bold text-white">{formatCoins(inventoryValue)} <span className="text-xs text-slate-400">GC</span></p>
          </div>
        </div>
      </div>
      <div className="mt-7 flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-white/[0.06] bg-[#11141c] px-5 py-4">
        <p className="text-sm text-slate-300"><strong className="text-white">{inventorySkins.length}</strong> предмети у сховищі</p>
        <div className="flex gap-2">
          <Link href="/catalog" className="rounded-lg border border-white/10 px-3 py-2 text-xs font-semibold text-slate-300 hover:bg-white/[0.06]">
            До каталогу
          </Link>
          <Link href="/leaderboard" className="rounded-lg bg-violet-300/[0.12] px-3 py-2 text-xs font-semibold text-violet-200 hover:bg-violet-300/20">
            Рейтинг гравців
          </Link>
        </div>
      </div>
      <div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {inventorySkins.map((skin) => (
          <SkinTile key={skin.finish} skin={skin} action="В апгрейдер" href="/" />
        ))}
      </div>
    </div>
  );
}
