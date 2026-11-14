import Link from "next/link";
import { formatCoins, players } from "../data";

const medals = ["text-amber-200", "text-slate-300", "text-orange-300", "text-slate-500", "text-slate-500"];
const avatarColors = [
  "from-amber-300 to-orange-400",
  "from-violet-300 to-fuchsia-400",
  "from-sky-300 to-blue-500",
  "from-emerald-300 to-teal-500",
  "from-rose-300 to-pink-500",
];

export default function LeaderboardPage() {
  return (
    <div className="mx-auto max-w-7xl px-5 pb-16 pt-10 lg:px-8">
      <div className="flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
        <div>
          <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-amber-300">Сезонний рейтинг · сезон 04</p>
          <h1 className="mt-3 text-3xl font-black tracking-tight text-white sm:text-4xl">Таблиця лідерів</h1>
          <p className="mt-2 text-sm leading-6 text-slate-400">Найкращі колекції спільноти за сумарною вартістю скінів.</p>
        </div>
        <Link href="/" className="text-sm font-semibold text-slate-300 transition hover:text-amber-200">
          ← Повернутися до апгрейдера
        </Link>
      </div>
      <div className="mt-8 grid gap-3 sm:grid-cols-3">
        {players.slice(0, 3).map((player, index) => (
          <Link
            href="/users/demo-player"
            key={player.rank}
            className={`rounded-2xl border bg-[#11141c] p-5 transition hover:-translate-y-1 hover:border-white/15 ${
              index === 0 ? "border-amber-300/20 sm:-translate-y-2" : "border-white/[0.07]"
            }`}
          >
            <div className="flex items-center justify-between">
              <span className={`font-mono text-xs font-bold ${medals[index]}`}>#{player.rank}</span>
              <span className="rounded-full bg-white/[0.05] px-2.5 py-1 text-[10px] text-slate-400">{player.level}</span>
            </div>
            <div className="mt-5 flex items-center gap-3">
              <span className={`flex size-12 items-center justify-center rounded-2xl bg-gradient-to-br ${avatarColors[index]} text-base font-black text-[#15131a]`}>
                {player.name.slice(0, 1).toUpperCase()}
              </span>
              <div>
                <p className="font-bold text-white">{player.name}</p>
                <p className="mt-1 text-xs text-slate-500">{player.skins} предметів</p>
              </div>
            </div>
            <div className="mt-5 border-t border-white/[0.07] pt-4">
              <p className="text-[10px] uppercase tracking-[0.16em] text-slate-500">Вартість колекції</p>
              <p className={`mt-1 font-mono text-xl font-black ${index === 0 ? "text-amber-200" : "text-white"}`}>
                {formatCoins(player.value)} <span className="text-xs font-semibold text-slate-500">GC</span>
              </p>
            </div>
          </Link>
        ))}
      </div>
      <section className="mt-8 overflow-hidden rounded-2xl border border-white/[0.07] bg-[#11141c]">
        <div className="flex items-center justify-between border-b border-white/[0.07] px-5 py-4">
          <h2 className="font-bold text-white">Топ гравців</h2>
          <span className="text-xs text-slate-500">Оновлено щойно</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full min-w-[600px] text-left">
            <thead>
              <tr className="text-[10px] uppercase tracking-[0.15em] text-slate-500">
                <th className="px-5 py-3 font-semibold">Місце</th>
                <th className="px-5 py-3 font-semibold">Гравець</th>
                <th className="px-5 py-3 font-semibold">Рівень</th>
                <th className="px-5 py-3 text-right font-semibold">Скіни</th>
                <th className="px-5 py-3 text-right font-semibold">Вартість</th>
              </tr>
            </thead>
            <tbody>
              {players.map((player, index) => (
                <tr key={player.rank} className="border-t border-white/[0.05] transition hover:bg-white/[0.025]">
                  <td className={`px-5 py-4 font-mono text-sm font-bold ${medals[index] ?? "text-slate-500"}`}>#{player.rank}</td>
                  <td className="px-5 py-4">
                    <Link href="/users/demo-player" className="font-semibold text-slate-200 hover:text-amber-200">
                      {player.name} <span aria-hidden="true" className="text-slate-600">↗</span>
                    </Link>
                  </td>
                  <td className="px-5 py-4 text-sm text-slate-400">{player.level}</td>
                  <td className="px-5 py-4 text-right font-mono text-sm text-slate-400">{player.skins}</td>
                  <td className="px-5 py-4 text-right font-mono text-sm font-semibold text-amber-200">{formatCoins(player.value)} GC</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
