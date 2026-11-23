"use client";

import Link from "next/link";
import type { Skin } from "../data";
import { formatCoins } from "../data";
import SkinArt from "./skin-art";

export default function SkinTile({
  skin,
  action = "Виграти в апгрейді ⚡",
  href = "/",
}: {
  skin: Skin;
  action?: string;
  href?: string;
}) {
  const accent = skin.accent || "#eb4b4b";

  // Скіни каталогу встановлюються виключно як БАЖАНА ЦІЛЬ (target), а не як твій скін
  const handleSelectAsTarget = () => {
    try {
      localStorage.setItem("goicoins_selected_target", JSON.stringify(skin));
    } catch {}
  };

  return (
    <article className="group relative rounded-2xl border border-white/[0.08] bg-[#0e111a] p-3.5 transition duration-200 hover:-translate-y-1 hover:border-emerald-500/30 hover:shadow-xl hover:shadow-black/50">
      <div
        className="absolute inset-0 rounded-2xl opacity-0 transition duration-300 group-hover:opacity-100 pointer-events-none"
        style={{
          boxShadow: `0 0 24px ${accent}25`,
          border: `1px solid ${accent}40`,
        }}
      />
      <SkinArt skin={skin} />
      <div className="px-1 pb-1 pt-4">
        <div className="flex items-start justify-between gap-2">
          <div>
            <p className="text-[11px] font-bold uppercase tracking-wider text-slate-500">
              {skin.weapon}
            </p>
            <h3 className="mt-0.5 font-bold text-slate-100 truncate">{skin.name}</h3>
          </div>
          <span
            className="rounded-full px-2 py-0.5 text-[9px] font-bold uppercase tracking-wide shrink-0"
            style={{
              backgroundColor: `${accent}15`,
              color: accent,
              border: `1px solid ${accent}30`,
            }}
          >
            {skin.rarity}
          </span>
        </div>
        <p className="mt-1.5 text-xs text-slate-500">{skin.wear}</p>
        <div className="mt-4 flex items-center justify-between border-t border-white/[0.06] pt-3">
          <span className="font-mono text-sm font-bold text-emerald-400">
            {formatCoins(skin.price)} <span className="text-[10px]">GC</span>
          </span>
          <Link
            href={href}
            onClick={handleSelectAsTarget}
            className="rounded-xl bg-emerald-500 hover:bg-emerald-400 px-3 py-1.5 text-xs font-black text-[#05130d] transition"
          >
            {action}
          </Link>
        </div>
      </div>
    </article>
  );
}
