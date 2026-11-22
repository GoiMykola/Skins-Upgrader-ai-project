import Link from "next/link";
import { LiveRefresh } from "@/components/live-refresh";
import { listSkins } from "@/lib/data/skins";

export default async function HomePage() {
  const skins = await listSkins();
  const inputSkin = skins[0] ?? { name: "AK-47 | Неонова гонка", price: 1250, rarity: "Засекречена", image: "neon" };
  const targetSkin = skins[1] ?? { name: "AWP | Гіперзвір", price: 3480, rarity: "Засекречена", image: "hyper" };
  const chance = Math.min(95, Math.max(5, ((inputSkin.price / targetSkin.price) * 100))).toFixed(1);

  return (
    <main className="min-h-screen bg-zinc-950 text-white pb-16">
      {/* Підключення складної складової Realtime */}
      <LiveRefresh table="upgrades" />

      {/* Hero Section / Upgrader Arena */}
      <section className="mx-auto max-w-5xl px-4 pt-10">
        <div className="text-center mb-8">
          <span className="inline-block px-3 py-1 text-xs font-semibold uppercase tracking-wider text-amber-400 bg-amber-500/10 rounded-full border border-amber-500/20 mb-2">
            Realtime Engine
          </span>
          <h1 className="text-4xl font-extrabold tracking-tight">GoiCoins Skin Upgrader</h1>
          <p className="text-zinc-400 text-sm mt-1">
            Обирай скін зі сховища, ціль для апгрейду та крути барабан
          </p>
        </div>

        {/* Circular Upgrader Hub */}
        <div className="relative rounded-2xl border border-zinc-800 bg-gradient-to-b from-zinc-900/90 to-zinc-950 p-8 shadow-2xl flex flex-col md:flex-row items-center justify-between gap-8">
          
          {/* Left Slot: Your Skin */}
          <div className="w-full md:w-64 rounded-xl border border-zinc-800 bg-zinc-900/50 p-5 text-center flex flex-col items-center">
            <span className="text-xs font-medium uppercase tracking-wider text-zinc-500 mb-3">Твій скін</span>
            <div className="w-28 h-28 rounded-lg bg-zinc-800/80 border border-zinc-700/50 flex items-center justify-center mb-3 shadow-inner">
              <span className="text-3xl font-black text-amber-500">{inputSkin.name.slice(0, 2)}</span>
            </div>
            <h3 className="font-bold text-sm text-zinc-200">{inputSkin.name}</h3>
            <span className="text-xs text-amber-400 font-semibold mt-1">{inputSkin.price} GC</span>
            <Link href="/inventory" className="mt-4 text-xs font-medium text-zinc-400 hover:text-white underline">
              Змінити з інвентарю
            </Link>
          </div>

          {/* Center: Circular Gauge Wheel */}
          <div className="relative flex flex-col items-center justify-center">
            <div className="relative w-56 h-56 flex items-center justify-center">
              {/* Outer Glow Ring */}
              <div className="absolute inset-0 rounded-full bg-amber-500/10 blur-xl"></div>
              
              {/* SVG Circular Progress */}
              <svg className="w-full h-full transform -rotate-90" viewBox="0 0 100 100">
                <circle
                  cx="50"
                  cy="50"
                  r="42"
                  stroke="currentColor"
                  strokeWidth="8"
                  fill="transparent"
                  className="text-zinc-800"
                />
                <circle
                  cx="50"
                  cy="50"
                  r="42"
                  stroke="currentColor"
                  strokeWidth="8"
                  strokeDasharray="264"
                  strokeDashoffset={264 - (264 * Number(chance)) / 100}
                  strokeLinecap="round"
                  fill="transparent"
                  className="text-amber-500 transition-all duration-1000 ease-out"
                />
              </svg>

              {/* Center Content */}
              <div className="absolute flex flex-col items-center text-center">
                <span className="text-3xl font-black tracking-tight text-white">{chance}%</span>
                <span className="text-[10px] font-semibold uppercase tracking-wider text-zinc-400 mt-0.5">Шанс успіху</span>
              </div>
            </div>

            {/* Action Button */}
            <button className="mt-6 px-8 py-3 rounded-xl bg-gradient-to-r from-amber-500 to-amber-600 font-bold text-black text-sm uppercase tracking-wider shadow-lg hover:brightness-110 active:scale-95 transition">
              Виконати апгрейд
            </button>
          </div>

          {/* Right Slot: Target Skin */}
          <div className="w-full md:w-64 rounded-xl border border-zinc-800 bg-zinc-900/50 p-5 text-center flex flex-col items-center">
            <span className="text-xs font-medium uppercase tracking-wider text-zinc-500 mb-3">Бажаний скін</span>
            <div className="w-28 h-28 rounded-lg bg-zinc-800/80 border border-amber-500/30 flex items-center justify-center mb-3 shadow-inner">
              <span className="text-3xl font-black text-purple-400">{targetSkin.name.slice(0, 2)}</span>
            </div>
            <h3 className="font-bold text-sm text-zinc-200">{targetSkin.name}</h3>
            <span className="text-xs text-amber-400 font-semibold mt-1">{targetSkin.price} GC</span>
            <Link href="/catalog" className="mt-4 text-xs font-medium text-zinc-400 hover:text-white underline">
              Обрати з каталогу
            </Link>
          </div>

        </div>

        {/* Live Drops Strip (Realtime Feed) */}
        <div className="mt-10 rounded-xl border border-zinc-800/80 bg-zinc-900/40 p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
              </span>
              <h2 className="text-xs font-bold uppercase tracking-wider text-zinc-300">Live Апгрейди (Realtime)</h2>
            </div>
            <span className="text-[11px] text-zinc-500">Оновлюється наживо</span>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {[
              { name: "AWP | Hyper Beast", user: "GoiPlayer", chance: "35.9%", won: true },
              { name: "M4A4 | Howl", user: "NightHawk", chance: "12.4%", won: false },
              { name: "AK-47 | Redline", user: "S1mple_pro", chance: "68.2%", won: true },
              { name: "Butterfly | Fade", user: "Kira.cs", chance: "8.5%", won: true },
            ].map((drop, i) => (
              <div key={i} className="rounded-lg border border-zinc-800 bg-zinc-900/80 p-2.5 flex items-center justify-between">
                <div>
                  <p className="text-xs font-semibold text-zinc-200 truncate">{drop.name}</p>
                  <p className="text-[10px] text-zinc-500">{drop.user} • {drop.chance}</p>
                </div>
                <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded ${drop.won ? "bg-green-500/20 text-green-400 border border-green-500/30" : "bg-red-500/20 text-red-400 border border-red-500/30"}`}>
                  {drop.won ? "УСПІХ" : "НЕВДАЧА"}
                </span>
              </div>
            ))}
          </div>
        </div>

      </section>
    </main>
  );
}
