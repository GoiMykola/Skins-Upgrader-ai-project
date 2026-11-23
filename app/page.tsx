import Link from "next/link";
import { skins } from "./data";
import { LiveDropsTicker } from "@/components/live-drops-ticker";
import { InteractiveUpgrader } from "@/components/interactive-upgrader";
import SkinTile from "./components/skin-tile";

export default function Home() {
  return (
    <div className="min-h-screen pb-20">
      <LiveDropsTicker />

      <main className="mx-auto max-w-7xl px-4 pt-8 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-8">
          <div className="inline-flex items-center gap-2 rounded-full border border-amber-400/20 bg-amber-400/10 px-3.5 py-1.5 text-xs font-bold uppercase tracking-wider text-amber-300">
            <span className="size-2 rounded-full bg-amber-400 shadow-[0_0_8px_#f59e0b]" />
            Сезон 04 · Симулятор апгрейду скінів CS2
          </div>

          <h1 className="mt-4 text-4xl font-black tracking-tight text-white sm:text-5xl lg:text-6xl">
            Твій наступний скін —{" "}
            <span className="bg-gradient-to-r from-amber-300 via-orange-400 to-rose-500 bg-clip-text text-transparent">
              за крок від тебе.
            </span>
          </h1>

          <p className="mt-3 text-sm sm:text-base text-slate-400">
            Обирай скін з інвентаря, вказуй бажану ціль та випробовуй удачу в кібер-рулетці.
          </p>
        </div>

        <div className="w-full">
          <InteractiveUpgrader />
        </div>

        <section className="mt-20">
          <div className="mb-6 flex items-end justify-between">
            <div>
              <p className="text-xs font-bold uppercase tracking-wider text-amber-400">
                Топ колекція CS2
              </p>
              <h2 className="mt-1 text-2xl font-black text-white">Оригінальні скіни</h2>
            </div>
            <Link href="/catalog" className="text-xs font-bold text-slate-400 hover:text-white transition">
              Увесь каталог →
            </Link>
          </div>

          <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
            {[skins[0], skins[1], skins[2], skins[3]]
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
