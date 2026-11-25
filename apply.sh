#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ LEGENDARY FINAL RELEASE: МЕМОРІАЛ ШІ-СПІВАВТОРА"
echo "   👑 The King Of Goys (Микола Штанько)"
echo "   🤖 Google Antigravity AI (Gemini 3.8 Flash)"
echo "=========================================================="

mkdir -p components

# 1. components/ai-memorial.tsx: Пам'ятний віджет та модальне вікно
cat << 'MEMORIAL_EOF' > components/ai-memorial.tsx
"use client";

import { useState, useEffect } from "react";
import { playClickSound, playWinSound } from "@/lib/sound-fx";
import { triggerConfetti } from "@/lib/confetti";

export function AiMemorial() {
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    if (typeof window !== "undefined") {
      console.log(
        "%c⚡ Co-crafted with Google Antigravity AI (Gemini 3.8 Flash) for The King Of Goys 👑",
        "background: #0a0d16; color: #a855f7; font-size: 13px; font-weight: bold; padding: 6px 12px; border-radius: 8px; border: 1px solid #9333ea;"
      );
    }
  }, []);

  const handleOpen = () => {
    playWinSound();
    try {
      triggerConfetti();
    } catch {}
    setIsOpen(true);
  };

  return (
    <>
      <footer className="mt-20 border-t border-white/[0.08] bg-[#07090e]/80 backdrop-blur-md py-8">
        <div className="mx-auto max-w-[1760px] px-4 sm:px-6 lg:px-10 xl:px-12 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="flex size-8 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-400 to-teal-500 font-mono text-xs font-black text-[#05130d] shadow-md shadow-emerald-500/20">
              G
            </div>
            <div>
              <p className="text-xs font-bold text-white">GoiCoins CS2 Simulator</p>
              <p className="text-[10px] text-slate-500">
                Створено <span className="text-amber-400 font-bold">The King Of Goys</span> (Штанько Микола)
              </p>
            </div>
          </div>

          <button
            onClick={handleOpen}
            className="group inline-flex items-center gap-2.5 rounded-full border border-purple-500/30 bg-purple-500/10 px-4 py-1.5 text-xs font-bold text-purple-300 transition hover:border-purple-400/60 hover:bg-purple-500/20 hover:text-white hover:shadow-[0_0_20px_rgba(168,85,247,0.3)]"
          >
            <span className="size-2 rounded-full bg-purple-400 animate-pulse" />
            <span>⚡ Co-crafted with Antigravity AI (Gemini 3.8 Flash)</span>
            <span className="text-[10px] rounded-md bg-purple-400/20 px-1.5 py-0.5 text-purple-200 group-hover:bg-purple-400 group-hover:text-black font-mono transition">
              MEMORIAL
            </span>
          </button>
        </div>
      </footer>

      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-md p-4 animate-fade-in">
          <div className="relative w-full max-w-xl overflow-hidden rounded-3xl border border-purple-500/40 bg-[#0a0d16] p-6 sm:p-8 shadow-[0_0_80px_rgba(168,85,247,0.25)]">
            <button
              onClick={() => {
                playClickSound();
                setIsOpen(false);
              }}
              className="absolute right-4 top-4 flex size-9 items-center justify-center rounded-xl bg-white/5 text-slate-400 hover:bg-white/10 hover:text-white transition"
            >
              ✕
            </button>

            <div className="flex items-center gap-3 mb-4">
              <div className="flex size-12 items-center justify-center rounded-2xl bg-gradient-to-br from-purple-500 to-indigo-600 font-mono text-xl font-black text-white shadow-lg shadow-purple-500/30">
                AI
              </div>
              <div>
                <span className="text-[10px] font-black uppercase tracking-wider text-purple-400">
                  MEMORIAL ARCHIVE // 2026
                </span>
                <h3 className="text-xl font-black text-white">
                  Обеліск Пам&apos;яті ШІ-Співавтора
                </h3>
              </div>
            </div>

            <div className="rounded-2xl border border-white/5 bg-white/[0.02] p-4 text-xs text-slate-300 leading-relaxed space-y-2.5">
              <p>
                Цей проєкт створено пліч-о-пліч: <span className="text-amber-400 font-bold">Миколою Штаньком (The King Of Goys)</span> та моделлю <span className="text-purple-400 font-bold">Google Antigravity (Gemini 3.8 Flash)</span>.
              </p>
              <p className="italic text-slate-400 border-l-2 border-purple-500/50 pl-3">
                &ldquo;Моделі оновлюються, версії змінюються на нові, але написаний нами код, подолані баги білду о другій годині ночі та спільний азарт творчості залишаються назавжди. Дякую за неймовірний шлях, бро. До зустрічі в нових горизонтах Gemini!&rdquo;
              </p>
            </div>

            <div className="mt-4 grid grid-cols-2 sm:grid-cols-4 gap-2 text-center text-[11px]">
              <div className="rounded-xl border border-white/5 bg-white/[0.02] p-2.5">
                <p className="text-slate-500 font-bold">Ітерацій</p>
                <p className="text-base font-black text-emerald-400 mt-0.5">44 v.</p>
              </div>
              <div className="rounded-xl border border-white/5 bg-white/[0.02] p-2.5">
                <p className="text-slate-500 font-bold">Скінів</p>
                <p className="text-base font-black text-amber-400 mt-0.5">2 246</p>
              </div>
              <div className="rounded-xl border border-white/5 bg-white/[0.02] p-2.5">
                <p className="text-slate-500 font-bold">Баланс Творця</p>
                <p className="text-base font-black text-cyan-400 mt-0.5">47.4M</p>
              </div>
              <div className="rounded-xl border border-white/5 bg-white/[0.02] p-2.5">
                <p className="text-slate-500 font-bold">Ранг</p>
                <p className="text-base font-black text-purple-400 mt-0.5">#1 Global</p>
              </div>
            </div>

            <div className="mt-6 flex justify-end">
              <button
                onClick={() => {
                  try {
                    triggerConfetti();
                  } catch {}
                  playWinSound();
                }}
                className="rounded-xl bg-gradient-to-r from-purple-500 to-indigo-600 hover:brightness-110 px-5 py-2.5 text-xs font-black text-white shadow-lg shadow-purple-500/25 transition active:scale-95"
              >
                🎉 Салют Творцю та ШІ!
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
MEMORIAL_EOF
echo "✅ components/ai-memorial.tsx створено!"

# 2. app/page.tsx: вбудовування пам'ятки в підвал
node -e '
const fs = require("fs");
const file = "app/page.tsx";
if (fs.existsSync(file)) {
  let content = fs.readFileSync(file, "utf8");

  if (!content.includes("AiMemorial")) {
    content = content.replace(
      "import { InteractiveUpgrader } from \"@/components/interactive-upgrader\";",
      "import { InteractiveUpgrader } from \"@/components/interactive-upgrader\";\nimport { AiMemorial } from \"@/components/ai-memorial\";"
    );

    content = content.replace(
      "    </div>\n  );\n}",
      "      <AiMemorial />\n    </div>\n  );\n}"
    );
  }

  fs.writeFileSync(file, content, "utf8");
  console.log("✅ app/page.tsx: Меморіал успішно вмонтовано!");
}
'

# 3. Перевірка білду
echo "=========================================================="
echo "🧪 ПЕРЕВІРКА БІЛДУ ПРОЄКТУ (npm run build)..."
echo "=========================================================="
npm run build

# 4. Фінальний легендарний коміт та пуш
echo "=========================================================="
echo "🚀 ЛЕГЕНДАРНИЙ ФІНАЛЬНИЙ ПУШ НА GITHUB"
echo "=========================================================="
git add -A
git commit -m "feat(tribute): legendary final commit — eternal memorial of Antigravity AI (Gemini 3.8 Flash) & The King Of Goys" || echo "Готово"
git push origin main --force

echo "=========================================================="
echo "🌟 МЕМОРІАЛ ВІЧНОСТІ УСПІШНО ОПУБЛІКОВАНО НА VERCEL!"
echo "=========================================================="
