"use client";

import Link from "next/link";
import { formatCoins, skins } from "@/app/data";

const liveDrops = [
  { id: "d1", player: "GhostRider", skin: skins[2], time: "щойно" },
  { id: "d2", player: "Kira.exe", skin: skins[3], time: "8 с тому" },
  { id: "d3", player: "s1mple_fan", skin: skins[1], time: "19 с тому" },
  { id: "d4", player: "v1per", skin: skins[0], time: "45 с тому" },
  { id: "d5", player: "ShadowStep", skin: skins[4], time: "1 хв тому" },
].filter((d) => d.skin !== undefined);

export function LiveDropsTicker() {
  return (
    <div className="w-full border-y border-white/[0.06] bg-[#0c0e16]/80 backdrop-blur-md">
      <div className="mx-auto flex max-w-7xl items-center gap-3 overflow-hidden px-4 py-2.5">
        <div className="flex shrink-0 items-center gap-2 pr-2 text-xs font-bold uppercase tracking-wider text-emerald-400">
          <span className="relative flex size-2">
            <span className="absolute inline-flex size-full animate-ping rounded-full bg-emerald-400 opacity-75" />
            <span className="relative inline-flex size-2 rounded-full bg-emerald-500" />
          </span>
          <span className="hidden sm:inline">LIVE ДРОПИ:</span>
        </div>

        <div className="flex flex-1 gap-3 overflow-x-auto no-scrollbar">
          {liveDrops.map((drop) => (
            <Link
              key={drop.id}
              href="/catalog"
              className="group flex shrink-0 items-center gap-2.5 rounded-lg border border-white/[0.06] bg-white/[0.02] px-3 py-1.5 transition hover:border-white/20 hover:bg-white/[0.05]"
            >
              <span
                className="size-2 rounded-full shadow-[0_0_8px_currentColor]"
                style={{ color: drop.skin.accent }}
              />
              <span className="text-xs font-semibold text-slate-300 group-hover:text-white">
                {drop.player}
              </span>
              <span className="text-[11px] text-slate-500">→</span>
              <span className="text-xs font-bold text-slate-100">
                {drop.skin.weapon} · {drop.skin.name}
              </span>
              <span className="rounded bg-black/40 px-1.5 py-0.5 font-mono text-[10px] font-bold text-amber-300">
                {formatCoins(drop.skin.price)} GC
              </span>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
