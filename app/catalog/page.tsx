import Link from "next/link";
import SkinTile from "../components/skin-tile";
import { skins } from "../data";

export default function CatalogPage() {
  return (
    <div className="mx-auto max-w-7xl px-5 pb-16 pt-10 lg:px-8">
      <div className="flex flex-col justify-between gap-5 border-b border-white/[0.07] pb-7 sm:flex-row sm:items-end">
        <div>
          <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-amber-300">Armory · 06 предметів</p>
          <h1 className="mt-3 text-3xl font-black tracking-tight text-white sm:text-4xl">Каталог скінів</h1>
          <p className="mt-2 max-w-xl text-sm leading-6 text-slate-400">
            Вибирай наступний предмет для колекції. Ціни та залишки — демонстраційні.
          </p>
        </div>
        <Link href="/inventory" className="text-sm font-semibold text-slate-300 transition hover:text-amber-200">
          Перейти до інвентаря <span aria-hidden="true">→</span>
        </Link>
      </div>
      <div className="mt-6 flex flex-wrap items-center gap-2">
        <span className="rounded-lg bg-amber-300 px-3 py-2 text-xs font-bold text-[#211407]">Усі предмети</span>
        {["Штурмові гвинтівки", "Снайперські", "Ножі"].map((filter) => (
          <span key={filter} className="rounded-lg border border-white/[0.07] px-3 py-2 text-xs font-medium text-slate-500">
            {filter}
          </span>
        ))}
        <span className="ml-auto rounded-lg border border-white/[0.07] bg-white/[0.025] px-3 py-2 text-xs text-slate-400">
          Баланс: <strong className="font-mono text-amber-200">1 000 GC</strong>
        </span>
      </div>
      <div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {skins.map((skin) => (
          <SkinTile key={skin.finish} skin={skin} action="Отримати" />
        ))}
      </div>
      <div className="mt-8 rounded-2xl border border-violet-300/10 bg-violet-300/[0.04] p-5 text-sm text-slate-400">
        <span className="font-semibold text-violet-200">Порада:</span> спершу поповни колекцію, а потім переходь до апгрейду.
        {" "}
        <Link href="/" className="font-semibold text-violet-200 hover:text-white">Спробувати апгрейдер →</Link>
      </div>
    </div>
  );
}
