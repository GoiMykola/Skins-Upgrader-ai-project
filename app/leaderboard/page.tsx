import { formatCoins, players } from "@/app/data";

export default function LeaderboardPage() {
  return (
    <div className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
      <div className="mb-8">
        <h1 className="text-3xl font-black text-white sm:text-4xl">Таблиця лідерів</h1>
        <p className="mt-2 text-sm text-slate-400">
          Найуспішніші гравці за вартістю зібраної колекції скінів.
        </p>
      </div>

      <div className="overflow-hidden rounded-3xl border border-white/[0.08] bg-[#0e111a] shadow-2xl">
        <table className="w-full text-left">
          <thead>
            <tr className="border-b border-white/[0.08] bg-white/[0.02] text-[11px] font-bold uppercase tracking-wider text-slate-400">
              <th className="py-4 px-6">Місце</th>
              <th className="py-4 px-6">Гравець</th>
              <th className="py-4 px-6">Ранг</th>
              <th className="py-4 px-6 text-center">Скінів</th>
              <th className="py-4 px-6 text-right">Вартість</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-white/[0.06] text-sm">
            {players.map((p, index) => (
              <tr key={p.name} className="hover:bg-white/[0.02]">
                <td className="py-4 px-6 font-mono font-bold">
                  <span className="inline-flex size-7 items-center justify-center rounded-lg border text-xs font-black border-amber-400/30 text-amber-300 bg-amber-400/10">
                    {p.rank}
                  </span>
                </td>
                <td className="py-4 px-6 font-bold text-white">{p.name}</td>
                <td className="py-4 px-6">
                  <span className="rounded-md border border-white/10 bg-white/5 px-2.5 py-1 text-xs font-semibold text-slate-300">
                    {p.level}
                  </span>
                </td>
                <td className="py-4 px-6 text-center font-mono text-slate-300">{p.skins}</td>
                <td className="py-4 px-6 text-right font-mono font-black text-amber-300">
                  {formatCoins(p.value)} GC
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
