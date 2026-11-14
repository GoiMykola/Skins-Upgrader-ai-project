import Link from "next/link";
import type { Skin } from "../data";
import { formatCoins } from "../data";
import SkinArt from "./skin-art";

export default function SkinTile({
  skin,
  action,
  href = "/inventory",
}: {
  skin: Skin;
  action: string;
  href?: string;
}) {
  return (
    <article className="group rounded-2xl border border-white/[0.07] bg-[#11141c] p-3 transition hover:-translate-y-1 hover:border-white/15">
      <SkinArt skin={skin} />
      <div className="px-1 pb-1 pt-4">
        <div className="flex items-start justify-between gap-3">
          <div>
            <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500">
              {skin.weapon}
            </p>
            <h3 className="mt-1 font-semibold text-slate-100">{skin.name}</h3>
          </div>
          <span className="rounded-full border border-white/[0.08] px-2 py-1 text-[9px] font-semibold uppercase tracking-wide text-slate-400">
            {skin.rarity}
          </span>
        </div>
        <p className="mt-2 text-xs text-slate-500">{skin.wear}</p>
        <div className="mt-4 flex items-center justify-between border-t border-white/[0.06] pt-3">
          <span className="font-mono text-sm font-semibold text-amber-300">
            {formatCoins(skin.price)} <span className="text-[10px]">GC</span>
          </span>
          <Link
            href={href}
            className="rounded-lg bg-white/[0.07] px-3 py-2 text-xs font-semibold text-slate-200 transition hover:bg-amber-400 hover:text-[#17120a]"
          >
            {action}
          </Link>
        </div>
      </div>
    </article>
  );
}
