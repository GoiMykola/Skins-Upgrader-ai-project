"use client";

import { useState } from "react";
import { ActionForm } from "@/components/action-form";
import { createAiSkinAction } from "@/app/catalog/ai-actions";
import { playClickSound } from "@/lib/sound-fx";

const PRESET_IDEAS = [
  "⚡ Неоновий кібер-дракон AWP у синіх тонах",
  "🔥 Вулкан у лаві AK-47 із золотим сяйвом",
  "🌌 Галактичний фантом M4A4 з туманністю",
  "🧊 Крижаний клинок Керамбіт прямо із заводу",
  "👑 Імператорський Desert Eagle з гравіюванням",
];

export function AiSkinWorkshop({ isConfigured = true }: { isConfigured?: boolean }) {
  const [promptText, setPromptText] = useState("");

  if (!isConfigured) {
    return (
      <div className="mb-8 rounded-3xl border border-amber-500/30 bg-amber-950/20 p-6 text-zinc-300 backdrop-blur-md">
        <h3 className="text-lg font-bold text-white">ШІ-Майстерня тимчасово недоступна</h3>
        <p className="mt-1 text-sm text-zinc-400">
          Ключ API або модель не налаштовані на сервері. Каталог працює в штатному режимі.
        </p>
      </div>
    );
  }

  return (
    <div className="relative mb-10 overflow-hidden rounded-3xl border border-amber-500/30 bg-[#0e111a]/95 p-6 shadow-2xl shadow-amber-500/5 backdrop-blur-xl sm:p-8">
      <div className="flex items-center gap-3 border-b border-white/[0.06] pb-4">
        <span className="size-3 rounded-full bg-amber-400 shadow-[0_0_10px_#f59e0b]" />
        <div>
          <span className="rounded-md bg-amber-400/20 px-2 py-0.5 text-[10px] font-black uppercase tracking-wider text-amber-300">
            AI WORKSHOP v1.0
          </span>
          <h2 className="mt-1 text-xl font-black text-white">ШІ-Майстерня створення скінів</h2>
        </div>
      </div>

      <p className="mt-4 text-sm text-slate-300">
        Опиши концепт скіна — штучний інтелект згенерує характеристики та запише його в каталог!
      </p>

      <div className="mt-4">
        <p className="text-[11px] font-bold uppercase tracking-wider text-slate-400 mb-2">
          Швидкі ідеї:
        </p>
        <div className="flex flex-wrap gap-2">
          {PRESET_IDEAS.map((idea) => (
            <button
              key={idea}
              type="button"
              onClick={() => {
                playClickSound();
                setPromptText(idea);
              }}
              className="rounded-lg border border-white/10 bg-white/5 px-2.5 py-1 text-xs text-slate-300 transition hover:border-amber-400/50 hover:bg-amber-400/10 hover:text-white"
            >
              {idea}
            </button>
          ))}
        </div>
      </div>

      <div className="mt-6">
        <ActionForm action={createAiSkinAction} successMessage="Скін згенеровано та додано!">
          <div className="flex flex-col sm:flex-row gap-3">
            <input
              name="prompt"
              type="text"
              required
              value={promptText}
              onChange={(e) => setPromptText(e.target.value)}
              placeholder="Наприклад: Кібернетичний фантом у неонових тонах для AWP"
              className="w-full rounded-xl border border-white/10 bg-black/40 px-4 py-3.5 text-sm text-white placeholder-slate-500 focus:border-amber-400 focus:outline-none"
            />
            <button
              type="submit"
              onClick={() => playClickSound()}
              className="shrink-0 rounded-xl bg-gradient-to-r from-amber-400 to-orange-500 px-6 py-3.5 text-sm font-black text-[#1a1104] shadow-lg shadow-orange-500/20 transition hover:brightness-110 active:scale-[0.99]"
            >
              Згенерувати скін ⚡
            </button>
          </div>
        </ActionForm>
      </div>
    </div>
  );
}
