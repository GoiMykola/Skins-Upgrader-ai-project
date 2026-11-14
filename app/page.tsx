import Link from "next/link";
import SkinArt from "./components/skin-art";
import SkinTile from "./components/skin-tile";
import { formatCoins, skins } from "./data";

const recentDrops = [
  { player: "demo-player", skin: skins[2], time: "щойно", gradient: "from-rose-400 to-orange-400" },
  { player: "Kira.exe", skin: skins[3], time: "12 с тому", gradient: "from-violet-400 to-fuchsia-400" },
  { player: "n0va", skin: skins[1], time: "28 с тому", gradient: "from-sky-400 to-indigo-400" },
  { player: "v1per", skin: skins[0], time: "1 хв тому", gradient: "from-amber-300 to-orange-400" },
  { player: "pixel_king", skin: skins[4], time: "2 хв тому", gradient: "from-cyan-300 to-blue-400" },
].filter((drop) => drop.skin !== undefined);

export default function Home() {
  const sourceSkin = skins[0];
  const targetSkin = skins[2];

  if (!sourceSkin || !targetSkin) return null;

  return (
    <div className="mx-auto max-w-7xl px-5 pb-16 pt-10 lg:px-8 lg:pt-14">
      <section className="grid gap-8 lg:grid-cols-[1fr_0.92fr] lg:items-center">
        <div className="py-4">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/15 bg-emerald-400/[0.05] px-3 py-1.5 text-[10px] font-bold uppercase tracking-[0.16em] text-emerald-300">
            <span className="size-1.5 rounded-full bg-emerald-300 shadow-[0_0_10px_#6ee7b7]" />
            Сезон 04 · майстерня відкрита
          </div>
          <h1 className="mt-6 max-w-2xl text-4xl font-black leading-[1.08] tracking-tight text-white sm:text-5xl lg:text-6xl">
            Твій наступний
            <br />
            <span className="bg-gradient-to-r from-amber-200 via-orange-400 to-rose-400 bg-clip-text text-transparent">
              скін — за крок.
            </span>
          </h1>
          <p className="mt-5 max-w-xl text-base leading-7 text-slate-400">
            Збирай колекцію, тестуй удачу та покращуй улюблені скіни. Жодних ставок — лише гра з GoiCoins.
          </p>
          <div className="mt-7 flex flex-wrap gap-3">
            <Link
              href="/catalog"
              className="rounded-xl bg-gradient-to-r from-amber-300 to-orange-400 px-5 py-3 text-sm font-extrabold text-[#211407] shadow-lg shadow-orange-500/10 transition hover:brightness-110"
            >
              Дослідити каталог <span aria-hidden="true">↗</span>
            </Link>
            <Link
              href="/inventory"
              className="rounded-xl border border-white/10 bg-white/[0.03] px-5 py-3 text-sm font-semibold text-slate-200 transition hover:bg-white/[0.07]"
            >
              Мій інвентар
            </Link>
          </div>
          <div className="mt-10 flex items-center gap-6 border-t border-white/[0.07] pt-6">
            <div>
              <p className="text-xl font-black text-white">2 481</p>
              <p className="mt-1 text-[10px] uppercase tracking-[0.15em] text-slate-500">гравців онлайн</p>
            </div>
            <div className="h-9 w-px bg-white/10" />
            <div>
              <p className="text-xl font-black text-white">18.6k</p>
              <p className="mt-1 text-[10px] uppercase tracking-[0.15em] text-slate-500">дропів сьогодні</p>
            </div>
            <Link href="/leaderboard" className="ml-auto text-xs font-semibold text-violet-300 hover:text-violet-200">
              Рейтинг гравців →
            </Link>
          </div>
        </div>

        <section className="relative overflow-hidden rounded-3xl border border-white/[0.08] bg-[#11141c] p-5 shadow-2xl shadow-black/30 sm:p-7">
          <div className="absolute -right-20 -top-32 size-72 rounded-full bg-violet-500/[0.07] blur-3xl" />
          <div className="relative flex items-center justify-between">
            <div>
              <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-amber-300">Модуль апгрейду</p>
              <h2 className="mt-1 text-lg font-bold text-white">Влуч у ціль</h2>
            </div>
            <span className="rounded-lg border border-white/[0.07] bg-black/20 px-2.5 py-1.5 font-mono text-[10px] text-slate-500">
              #UP-004
            </span>
          </div>
          <div className="relative mt-6 grid grid-cols-[1fr_auto_1fr] items-center gap-3">
            <div>
              <SkinArt skin={sourceSkin} className="h-32" />
              <p className="mt-3 text-[10px] font-semibold uppercase tracking-[0.12em] text-slate-500">Твій скін</p>
              <p className="mt-1 text-sm font-bold text-slate-100">{sourceSkin.weapon} · {sourceSkin.name}</p>
              <p className="mt-1 font-mono text-xs text-amber-300">{formatCoins(sourceSkin.price)} GC</p>
            </div>
            <div className="flex size-9 items-center justify-center rounded-full border border-violet-300/20 bg-violet-300/[0.07] text-violet-200">
              →
            </div>
            <div>
              <SkinArt skin={targetSkin} className="h-32" />
              <p className="mt-3 text-[10px] font-semibold uppercase tracking-[0.12em] text-slate-500">Бажана ціль</p>
              <p className="mt-1 text-sm font-bold text-slate-100">{targetSkin.weapon} · {targetSkin.name}</p>
              <p className="mt-1 font-mono text-xs text-amber-300">{formatCoins(targetSkin.price)} GC</p>
            </div>
          </div>
          <div className="relative mt-6 flex items-center justify-between rounded-xl border border-white/[0.06] bg-black/20 px-4 py-3">
            <div>
              <p className="text-[10px] uppercase tracking-[0.16em] text-slate-500">Шанс апгрейду</p>
              <p className="mt-1 text-lg font-black text-violet-200">25.1%</p>
            </div>
            <div className="h-8 w-px bg-white/10" />
            <div>
              <p className="text-right text-[10px] uppercase tracking-[0.16em] text-slate-500">Множник</p>
              <p className="mt-1 text-right text-lg font-black text-white">×3.98</p>
            </div>
          </div>
          <Link
            href="/inventory"
            className="relative mt-4 flex w-full items-center justify-center gap-2 rounded-xl bg-gradient-to-r from-violet-400 to-fuchsia-400 py-3.5 text-sm font-extrabold text-[#160e21] transition hover:brightness-110"
          >
            Покращити <span aria-hidden="true">✦</span>
          </Link>
          <p className="relative mt-3 text-center text-[10px] text-slate-600">
            Демо-симуляція · без реальних ставок
          </p>
        </section>
      </section>

      <section className="mt-14">
        <div className="mb-5 flex items-end justify-between">
          <div>
            <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-emerald-300">В реальному часі</p>
            <h2 className="mt-2 text-2xl font-extrabold text-white">Свіжі дропи</h2>
          </div>
          <Link href="/leaderboard" className="text-xs font-semibold text-slate-400 transition hover:text-white">
            Усі гравці →
          </Link>
        </div>
        <div className="flex gap-4 overflow-x-auto pb-3">
          {recentDrops.map((drop) => (
            <Link
              key={drop.player}
              href="/users/demo-player"
              className="group min-w-[250px] flex-1 rounded-2xl border border-white/[0.07] bg-[#11141c] p-3 transition hover:border-white/15"
            >
              <div className={`flex items-center gap-3 rounded-xl bg-gradient-to-r ${drop.gradient} p-px`}>
                <div className="flex w-full items-center gap-3 rounded-[11px] bg-[#11141c] p-3">
                  <span className={`flex size-9 items-center justify-center rounded-full bg-gradient-to-br ${drop.gradient} text-xs font-black text-[#15131a]`}>
                    {drop.player.slice(0, 1).toUpperCase()}
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block truncate text-xs font-bold text-slate-100">{drop.player}</span>
                    <span className="mt-1 block text-[10px] text-slate-500">{drop.time}</span>
                  </span>
                  <span className="text-[10px] text-emerald-300">●</span>
                </div>
              </div>
              {drop.skin && (
                <div className="mt-3 flex items-center gap-3">
                  <SkinArt skin={drop.skin} className="h-16 w-24 shrink-0" />
                  <div className="min-w-0">
                    <p className="text-[10px] uppercase tracking-[0.12em] text-slate-500">{drop.skin.weapon}</p>
                    <p className="mt-1 truncate text-sm font-bold text-white">{drop.skin.name}</p>
                    <p className="mt-1 font-mono text-xs text-amber-300">{formatCoins(drop.skin.price)} GC</p>
                  </div>
                </div>
              )}
            </Link>
          ))}
        </div>
      </section>

      <section className="mt-12">
        <div className="mb-5 flex items-end justify-between">
          <div>
            <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-amber-300">Твій наступний дроп</p>
            <h2 className="mt-2 text-2xl font-extrabold text-white">Вибір спільноти</h2>
          </div>
          <Link href="/catalog" className="text-xs font-semibold text-slate-400 transition hover:text-white">
            Весь каталог →
          </Link>
        </div>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {[skins[0], skins[1], skins[3], skins[4]].filter((skin): skin is NonNullable<typeof skin> => Boolean(skin)).map((skin) => (
            <SkinTile key={skin.finish} skin={skin} action="Відкрити" href="/catalog" />
          ))}
        </div>
      </section>
    </div>
  );
}
