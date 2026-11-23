import Link from "next/link";
import { skins } from "./data";
import { LiveDropsTicker } from "@/components/live-drops-ticker";
import { InteractiveUpgrader } from "@/components/interactive-upgrader";
import SkinTile from "./components/skin-tile";

export default function Home() {
  return (
    <div className="min-h-screen pb-20">
      <LiveDropsTicker />

      <main className="mx-auto max-w-[1760px] px-4 pt-8 sm:px-6 lg:px-10 xl:px-12">
        {/* Заголовок у смарагдовому стилі */}
        <div className="text-center max-w-4xl mx-auto mb-8">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-3.5 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-300">
            <span className="size-2 rounded-full bg-emerald-400 shadow-[0_0_8px_#10b981]" />
            Сезон 04 · Симулятор апгрейду скінів CS2
          </div>

          <h1 className="mt-4 text-4xl font-black tracking-tight text-white sm:text-5xl lg:text-6xl">
            Твій наступний скін —{" "}
            <span className="text-emerald-400 drop-shadow-[0_0_25px_rgba(52,211,153,0.35)]">
              за крок від тебе.
            </span>
          </h1>

          <p className="mt-3 text-sm sm:text-base text-slate-400">
            Обирай скін з інвентаря, вказуй бажану ціль та випробовуй удачу в кібер-рулетці.
          </p>
        </div>

        {/* Інтерактивний Апгрейдер Widescreen */}
        <InteractiveUpgrader />

        {/* Популярні скіни каталогу на всю ширину */}
        <section className="mt-16">
          <div className="flex items-center justify-between border-b border-white/[0.08] pb-4 mb-6">
            <div>
              <h2 className="text-xl font-bold text-white">Трендові скіни каталогу</h2>
              <p className="text-xs text-slate-400 mt-0.5">Найпопулярніші предмети серед гравців</p>
            </div>
            <Link
              href="/market"
              className="text-xs font-bold text-emerald-400 hover:text-emerald-300 transition"
            >
              Всі 2 246 скінів на Ринку →
            </Link>
          </div>
          <div className="grid gap-5 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
            {skins.slice(0, 8).map((skin, idx) => (
              <SkinTile key={`trending-skin-${skin.finish}-${idx}`} skin={skin} action="Апгрейдити" href="/" />
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}
