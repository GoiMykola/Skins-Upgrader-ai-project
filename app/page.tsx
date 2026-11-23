import Link from "next/link";
import { formatCoins, skins } from "./data";
import { LiveDropsTicker } from "@/components/live-drops-ticker";
import { InteractiveUpgrader } from "@/components/interactive-upgrader";
import SkinTile from "./components/skin-tile";

export default function Home() {
  return (
    <div className="min-h-screen pb-20">
      <LiveDropsTicker />
      <main className="mx-auto max-w-7xl px-4 pt-10 sm:px-6 lg:px-8">
        <section className="grid gap-10 lg:grid-cols-[0.9fr_1.1fr] lg:items-center">
          <div>
            <div className="inline-flex items-center gap-2 rounded-full border border-amber-400/20 bg-amber-400/10 px-3.5 py-1.5 text-xs font-bold uppercase tracking-wider text-amber-300">
              <span className="size-2 rounded-full bg-amber-400 shadow-[0_0_8px_#f59e0b]" />
              Сезон 04 · Відкрито Майстерню ШІ
            </div>
            <h1 className="mt-6 text-4xl font-black leading-[1.08] tracking-tight text-white sm:text-5xl lg:text-6xl">
              Твій наступний
              <br />
              <span className="bg-gradient-to-r from-amber-300 via-orange-400 to-rose-500 bg-clip-text text-transparent">
                скін — за крок.
              </span>
            </h1>
            <p className="mt-5 max-w-lg text-base leading-relaxed text-slate-300">
              Покращуй скіни у кібер-рулетці, генеруй моделі за допомогою ШІ та збирай колекцію мрії. Гра без реальних ставок.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Link
                href="/catalog"
                className="rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 px-6 py-3.5 text-sm font-black text-[#1c1206] shadow-lg shadow-orange-500/20 transition hover:brightness-110"
              >
                Каталог скінів ⚡
              </Link>
              <Link
                href="/inventory"
                className="rounded-xl border border-white/10 bg-white/5 px-6 py-3.5 text-sm font-bold text-slate-200 transition hover:bg-white/10"
              >
                Мій інвентар
              </Link>
            </div>
          </div>
          <div>
            <InteractiveUpgrader />
          </div>
        </section>

        <section className="mt-20">
          <div className="mb-6 flex items-end justify-between">
            <div>
              <p className="text-xs font-bold uppercase tracking-wider text-amber-400">Топ колекції</p>
              <h2 className="mt-1 text-2xl font-black text-white">Вибір спільноти</h2>
            </div>
            <Link href="/catalog" className="text-xs font-bold text-slate-400 hover:text-white">
              Увесь каталог →
            </Link>
          </div>
          <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
            {[skins[0], skins[1], skins[3], skins[4]]
              .filter((s): s is NonNullable<typeof s> => Boolean(s))
              .map((skin) => (
                <SkinTile key={skin.finish} skin={skin} action="Апгрейд" href="/" />
              ))}
          </div>
        </section>
      </main>
    </div>
  );
}
