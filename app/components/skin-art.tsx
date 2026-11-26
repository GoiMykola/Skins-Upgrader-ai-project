/* eslint-disable @next/next/no-img-element */
"use client";

import { useState, useEffect } from "react";
import type { Skin } from "../data";
import { OFFICIAL_SKIN_IMAGES } from "@/lib/inventory-storage";
import { sanitizeImageUrl } from "@/lib/safe-url";

export interface SkinArtProps {
  skin?: Partial<Skin>;
  item?: Partial<Skin>;
  image?: string;
  name?: string;
  weapon?: string;
  accent?: string;
  finish?: string;
  className?: string;
}

export default function SkinArt(props: SkinArtProps = {}) {
  const s = props?.skin || props?.item || {};
  const currentWeapon = s?.weapon || props?.weapon || "CS2";
  const currentName = s?.name || props?.name || "Skin";
  const fullTitle = `${currentWeapon} | ${currentName}`.trim();
  const currentAccent = s?.accent || props?.accent || "#eb4b4b";

  const preferredImage = sanitizeImageUrl(
    (OFFICIAL_SKIN_IMAGES && OFFICIAL_SKIN_IMAGES[fullTitle]) ||
      s?.image ||
      props?.image ||
      "",
  );

  const [imgSrc, setImgSrc] = useState<string>(preferredImage);
  const [hasError, setHasError] = useState(false);

  useEffect(() => {
    let active = true;
    const updated = sanitizeImageUrl(
      (OFFICIAL_SKIN_IMAGES && OFFICIAL_SKIN_IMAGES[fullTitle]) ||
        s?.image ||
        props?.image ||
        "",
    );
    queueMicrotask(() => {
      if (!active) return;
      setImgSrc(updated);
      setHasError(false);
    });
    return () => {
      active = false;
    };
  }, [fullTitle, s?.image, props?.image]);

  const handleImageError = () => {
    const fallback = sanitizeImageUrl(OFFICIAL_SKIN_IMAGES && OFFICIAL_SKIN_IMAGES[fullTitle]);
    if (fallback && imgSrc !== fallback) {
      setImgSrc(fallback);
    } else {
      setHasError(true);
    }
  };

  const safeImgSrc = sanitizeImageUrl(imgSrc);

  return (
    <div
      className={`relative flex h-36 items-center justify-center overflow-hidden rounded-2xl border border-white/[0.06] bg-[#0c0e15] ${props?.className || ""}`}
      style={{
        backgroundImage: `radial-gradient(ellipse at 50% 60%, ${currentAccent}25, transparent 70%)`,
      }}
      aria-label={fullTitle}
      role="img"
    >
      <div
        className="absolute inset-0 opacity-15 pointer-events-none"
        style={{
          background: `radial-gradient(circle at center, ${currentAccent}, transparent 70%)`,
        }}
      />

      <span className="absolute left-3 top-2.5 font-mono text-[9px] uppercase tracking-[0.2em] text-white/30">
        CS2 OFFICIAL
      </span>

      {safeImgSrc && !hasError ? (
        <img
          src={safeImgSrc}
          alt={fullTitle}
          onError={handleImageError}
          className="relative z-10 max-h-[82%] max-w-[85%] object-contain drop-shadow-[0_12px_22px_rgba(0,0,0,0.85)] transition-transform duration-300 group-hover:scale-110"
          loading="lazy"
        />
      ) : (
        <div className="relative z-10 flex flex-col items-center justify-center p-2 text-center">
          <div
            className="flex size-10 items-center justify-center rounded-xl font-black text-xs shadow-lg mb-1"
            style={{
              backgroundColor: `${currentAccent}30`,
              color: currentAccent,
              border: `1px solid ${currentAccent}50`,
            }}
          >
            {currentWeapon.substring(0, 3).toUpperCase()}
          </div>
          <span className="font-mono text-xs font-bold text-slate-300 truncate max-w-[120px]">
            {currentName}
          </span>
        </div>
      )}

      <span className="absolute bottom-2 right-3 text-[9px] font-semibold uppercase tracking-[0.18em] text-white/20">
        GOICONS · SKIN LAB
      </span>
    </div>
  );
}
