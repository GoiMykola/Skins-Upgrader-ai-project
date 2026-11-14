import Link from "next/link";
import ReportProfileButton from "../../components/report-profile-button";
import SkinTile from "../../components/skin-tile";
import { formatCoins, skins } from "../../data";

export function generateStaticParams() {
  return [{ id: "demo-player" }];
}

export default async function PublicProfilePage({
  params,
}: PageProps<"/users/[id]">) {
  const { id } = await params;
  const showcaseSkins = [skins[2], skins[3], skins[1], skins[0]].filter(
    (skin): skin is NonNullable<typeof skin> => Boolean(skin),
  );
  const displayedName = id === "demo-player" ? "demo-player" : id;

  return (
    <div className="mx-auto max-w-7xl px-5 pb-16 pt-10 lg:px-8">
      <div className="mb-6 flex items-center gap-2 text-xs text-slate-500">
        <Link href="/" className="hover:text-white">Головна</Link>
        <span>/</span>
        <Link href="/leaderboard" className="hover:text-white">Лідери</Link>
        <span>/</span>
        <span className="text-slate-300">{displayedName}</span>
      </div>
      <section className="relative overflow-hidden rounded-3xl border border-white/[0.08] bg-[#11141c] p-6 sm:p-9">
        <div className="absolute -right-12 -top-28 size-80 rounded-full bg-violet-500/[0.08] blur-3xl" />
        <div className="relative flex flex-col justify-between gap-7 md:flex-row md:items-center">
          <div className="flex items-center gap-5">
            <div className="flex size-20 shrink-0 items-center justify-center rounded-3xl border border-amber-200/20 bg-gradient-to-br from-amber-300 to-orange-500 text-3xl font-black text-[#251508] shadow-xl shadow-orange-500/10">
              D
            </div>
            <div>
              <div className="flex flex-wrap items-center gap-2">
                <h1 className="text-2xl font-black text-white sm:text-3xl">{displayedName}</h1>
                <span className="rounded-full border border-emerald-300/15 bg-emerald-300/[0.06] px-2.5 py-1 text-[10px] font-bold text-emerald-300">ONLINE</span>
              </div>
              <p className="mt-2 text-sm text-slate-400">Колекціонер · у спільноті з березня 2024</p>
              <p className="mt-2 text-xs text-slate-500">ID гравця <span className="font-mono text-slate-400">#GC-048291</span></p>
            </div>
          </div>
          <ReportProfileButton />
        </div>
        <div className="relative mt-8 grid gap-3 border-t border-white/[0.07] pt-6 sm:grid-cols-3">
          {[
            { label: "Вартість колекції", value: `${formatCoins(24860)} GC`, tone: "text-amber-200" },
            { label: "Скінів у колекції", value: "18", tone: "text-white" },
            { label: "Апгрейдів успішно", value: "42", tone: "text-violet-200" },
          ].map((stat) => (
            <div key={stat.label} className="rounded-xl border border-white/[0.05] bg-black/15 px-4 py-3">
              <p className="text-[10px] font-semibold uppercase tracking-[0.14em] text-slate-500">{stat.label}</p>
              <p className={`mt-1.5 font-mono text-xl font-black ${stat.tone}`}>{stat.value}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="mt-10">
        <div className="mb-5 flex items-end justify-between">
          <div>
            <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-violet-300">Публічна вітрина</p>
            <h2 className="mt-2 text-2xl font-extrabold text-white">Скіни гравця</h2>
          </div>
          <span className="text-xs text-slate-500">4 з 18 предметів</span>
        </div>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {showcaseSkins.map((skin) => (
            <SkinTile key={skin.finish} skin={skin} action="У каталог" href="/catalog" />
          ))}
        </div>
      </section>
      <div className="mt-9 flex flex-wrap gap-3">
        <Link href="/" className="rounded-xl bg-white/[0.06] px-4 py-3 text-sm font-semibold text-slate-200 transition hover:bg-white/10">
          ← На головну
        </Link>
        <Link href="/leaderboard" className="rounded-xl border border-white/[0.08] px-4 py-3 text-sm font-semibold text-slate-300 transition hover:bg-white/[0.04]">
          Таблиця лідерів
        </Link>
      </div>
    </div>
  );
}
