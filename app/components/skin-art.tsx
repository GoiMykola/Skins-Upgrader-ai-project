import type { Skin } from "../data";

export default function SkinArt({
  skin,
  className = "",
}: {
  skin: Skin;
  className?: string;
}) {
  return (
    <div
      className={`relative flex h-36 items-center justify-center overflow-hidden rounded-2xl border border-white/[0.06] bg-[#0c0e15] ${className}`}
      style={{
        backgroundImage: `radial-gradient(ellipse at 50% 60%, ${skin.accent}20, transparent 70%)`,
      }}
      aria-label={`${skin.weapon} | ${skin.name}`}
      role="img"
    >
      <div
        className="absolute inset-0 opacity-15 pointer-events-none"
        style={{
          background: `radial-gradient(circle at center, ${skin.accent}, transparent 70%)`,
        }}
      />

      <span className="absolute left-3 top-2.5 font-mono text-[9px] uppercase tracking-[0.2em] text-white/30">
        CS2 OFFICIAL
      </span>

      {skin.image ? (
        <img
          src={skin.image}
          alt={`${skin.weapon} | ${skin.name}`}
          className="relative z-10 max-h-[82%] max-w-[85%] object-contain drop-shadow-[0_12px_22px_rgba(0,0,0,0.85)] transition-transform duration-300 group-hover:scale-110"
          loading="lazy"
        />
      ) : (
        <span className="font-mono text-sm text-slate-400">{skin.name}</span>
      )}

      <span className="absolute bottom-2 right-3 text-[9px] font-semibold uppercase tracking-[0.18em] text-white/20">
        GoiCoins · Skin Lab
      </span>
    </div>
  );
}
