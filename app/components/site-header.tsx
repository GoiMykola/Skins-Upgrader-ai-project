import Link from "next/link";

const navigation = [
  { href: "/", label: "Апгрейдер" },
  { href: "/catalog", label: "Каталог" },
  { href: "/inventory", label: "Інвентар" },
  { href: "/leaderboard", label: "Лідери" },
  { href: "/users/demo-player", label: "Гравець" },
];

export default function SiteHeader() {
  return (
    <header className="sticky top-0 z-40 border-b border-white/[0.06] bg-[#090b10]/90 backdrop-blur-xl">
      <div className="mx-auto flex max-w-7xl items-center justify-between gap-5 px-5 py-4 lg:px-8">
        <Link href="/" className="flex shrink-0 items-center gap-3" aria-label="GoiCoins Skin Simulator — головна">
          <span className="flex size-10 items-center justify-center rounded-xl bg-gradient-to-br from-amber-300 to-orange-500 text-lg font-black text-[#241507] shadow-lg shadow-amber-500/10">
            G
          </span>
          <span className="hidden leading-tight sm:block">
            <span className="block text-sm font-extrabold tracking-wide text-white">GOICOINS</span>
            <span className="mt-1 block text-[9px] font-semibold uppercase tracking-[0.2em] text-slate-500">
              Skin simulator
            </span>
          </span>
        </Link>
        <nav
          aria-label="Головна навігація"
          className="flex min-w-0 items-center gap-1 overflow-x-auto rounded-xl border border-white/[0.06] bg-white/[0.025] p-1"
        >
          {navigation.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="whitespace-nowrap rounded-lg px-3 py-2 text-xs font-semibold text-slate-400 transition hover:bg-white/[0.07] hover:text-white sm:px-4 sm:text-sm"
            >
              {item.label}
            </Link>
          ))}
        </nav>
        <Link
          href="/inventory"
          className="hidden shrink-0 items-center gap-2 rounded-xl border border-amber-300/15 bg-amber-300/[0.06] px-3 py-2 text-sm font-semibold text-amber-200 sm:flex"
        >
          <span className="text-amber-300">◆</span> 1 000 GC
        </Link>
      </div>
    </header>
  );
}
