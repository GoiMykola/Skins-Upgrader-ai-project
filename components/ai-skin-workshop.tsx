"use client";

import { ActionForm } from "@/components/action-form";
import { createAiSkinAction } from "@/app/catalog/ai-actions";

export function AiSkinWorkshop() {
  return (
    <div className="mb-10 rounded-2xl border border-amber-500/20 bg-gradient-to-b from-amber-500/10 via-zinc-900/60 to-zinc-950 p-6 shadow-xl backdrop-blur-md">
      <div className="mb-4 flex items-center justify-between">
        <div>
          <span className="inline-block rounded-full bg-amber-500/20 px-3 py-1 text-xs font-semibold uppercase tracking-wider text-amber-400 border border-amber-500/30">
            AI Workshop Engine
          </span>
          <h2 className="mt-2 text-2xl font-bold tracking-tight text-white">
            ШІ-Майстерня створення скінів
          </h2>
          <p className="text-sm text-zinc-400">
            Опиши концепт, віжуал чи тематику скіна — штучний інтелект згенерує характеристики та запише його в каталог!
          </p>
        </div>
      </div>

      <ActionForm action={createAiSkinAction} className="space-y-4">
        <div>
          <label htmlFor="prompt" className="block text-xs font-medium uppercase text-zinc-400 mb-1">
            Опис або ідея скіна
          </label>
          <input
            id="prompt"
            name="prompt"
            type="text"
            placeholder="Наприклад: Кібернетичний дракон у неонових синіх тонах для AWP"
            required
            maxLength={300}
            className="w-full rounded-xl border border-zinc-800 bg-zinc-900/80 px-4 py-3 text-sm text-white placeholder-zinc-500 focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
          />
        </div>

        <div className="flex items-center justify-between pt-2">
          <span className="text-xs text-zinc-500">
            Генерація на базі моделі Gemini Flash
          </span>
          <button
            type="submit"
            className="rounded-xl bg-amber-500 px-6 py-2.5 text-sm font-semibold text-black transition-all hover:bg-amber-400 active:scale-95 cursor-pointer shadow-lg shadow-amber-500/20"
          >
            Згенерувати скін (ШІ)
          </button>
        </div>
      </ActionForm>
    </div>
  );
}
