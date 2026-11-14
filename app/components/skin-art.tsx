import type { Skin } from "../data";

export default function SkinArt({
  skin,
  className = "",
}: {
  skin: Skin;
  className?: string;
}) {
  const isKnife = skin.kind === "knife";
  const isSniper = skin.kind === "sniper";

  return (
    <div
      className={`relative flex h-36 items-center justify-center overflow-hidden rounded-xl border border-white/[0.06] bg-[#10131b] ${className}`}
      style={{
        backgroundImage: `radial-gradient(ellipse at 50% 75%, ${skin.accent}22, transparent 62%)`,
      }}
      aria-label={`${skin.weapon} ${skin.name}`}
      role="img"
    >
      <span className="absolute left-3 top-3 font-mono text-[10px] uppercase tracking-[0.2em] text-white/30">
        {skin.finish}
      </span>
      <svg
        viewBox="0 0 360 150"
        className={`w-[88%] drop-shadow-[0_12px_18px_rgba(0,0,0,0.65)] transition-transform duration-300 group-hover:scale-105 ${
          isKnife ? "h-[82%]" : "h-[72%]"
        }`}
        fill="none"
        aria-hidden="true"
      >
        {isKnife ? (
          <>
            <path
              d="M56 77 236 52l65 12-61 25-174 3-10-15Z"
              fill={skin.accent}
              fillOpacity=".87"
              stroke="#fff"
              strokeOpacity=".44"
              strokeWidth="2"
            />
            <path d="m75 89 6 25 43 2 15-27" fill="#171923" stroke="#fff" strokeOpacity=".24" strokeWidth="2" />
            <path d="m252 62 34 3-39 16" stroke="#fff" strokeOpacity=".65" strokeWidth="2" />
            <circle cx="92" cy="99" r="3" fill={skin.accent} />
            <circle cx="110" cy="100" r="3" fill={skin.accent} />
          </>
        ) : (
          <>
            <path
              d={`M29 70h${isSniper ? "69" : "52"}l18-15h${isSniper ? "52" : "43"}l12 12h${isSniper ? "31" : "26"}v12h-31l-12 16h-${isSniper ? "53" : "42"}l-12-13H29V70Z`}
              fill={skin.accent}
              fillOpacity=".82"
              stroke="#fff"
              strokeOpacity=".46"
              strokeWidth="2"
            />
            <path d="M157 66h133l17 5v8H157" fill="#242734" stroke="#fff" strokeOpacity=".45" strokeWidth="2" />
            <path d="m109 96 10 34h27l7-34" fill="#171923" stroke="#fff" strokeOpacity=".3" strokeWidth="2" />
            <path d="m60 66 8-17h39l5 8M49 95h32l8 13H52" fill="#20232c" stroke="#fff" strokeOpacity=".28" strokeWidth="2" />
            <path d="M178 66v13m14-13v13m14-13v13" stroke="#fff" strokeOpacity=".52" strokeWidth="3" />
            {isSniper && <path d="M91 53V38h55v15m-48-15h41" stroke={skin.accent} strokeWidth="5" />}
            <path d="M39 82h17m13-27 21 5" stroke="#fff" strokeOpacity=".6" strokeWidth="2" />
          </>
        )}
      </svg>
      <span className="absolute bottom-2 right-3 text-[9px] font-semibold uppercase tracking-[0.18em] text-white/25">
        GoiCoins · skin lab
      </span>
    </div>
  );
}
