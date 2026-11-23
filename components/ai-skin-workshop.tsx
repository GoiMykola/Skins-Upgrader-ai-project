"use client";

import { ActionForm } from "@/components/action-form";
import { createAiSkinAction } from "@/app/catalog/ai-actions";

export function AiSkinWorkshop({ isConfigured = true }: { isConfigured?: boolean }) {
  if (!isConfigured) {
    return (
      <div className="mb-8 rounded-2xl border border-amber-500/30 bg-amber-950/20 p-6 text-zinc-300 backdrop-blur-md">
        <div className="flex items-center gap-2 mb-2">
          <span className="rounded-full bg-amber-500/20 px-2.5 py-0.5 text-xs font-semibold text-amber-400">
            AI WORKSHOP ENGINE
          </span>
          <span className="text-xs text-amber-400/80">• Тимчасово вимкнено</span>
        </div>
        <h2 className="text-xl font-bold text-white mb-1">ШІ-Майстерня створення скінів</h2>
        <p className="text-sm text-zinc-400">
          Функція створення скінів на базі ШІ тимчасово недоступна: ключ моделі не налаштовано або вимкнено адміністратором. Решта функцій каталогу працює стабільно.
        </p>
      </div>
    );
  }

  return (
    <div className="mb-8 rounded-2xl border border-amber-500/20 bg-zinc-950/80 p-6 backdrop-blur-md shadow-lg shadow-amber-950/10">
      <div className="flex items-center gap-2 mb-2">
        <span className="rounded-full bg-amber-500/20 px-2.5 py-0.5 text-xs font-semibold text-amber-400">
          AI WORKSHOP ENGINE
        </span>
      </div>
      <h2 className="text-xl font-bold text-white mb-1">ШІ-Майстерня створення скінів</h2>
      <p className="text-sm text-zinc-400 mb-4">
        Опиши концепт, візуал чи тематику скіна — штучний інтелект згенерує характеристики та запише його в каталог!
      </p>

      <ActionForm action={createAiSkinAction} className="space-y-4">
        <div>
          <label htmlFor="prompt" className="block text-xs font-medium text-zinc-400 uppercase tracking-wider mb-1.5">
            Опис або ідея скіна
          </label>
          <input
            id="prompt"
            name="prompt"
            type="text"
            placeholder="Наприклад: Кібернетичний дракон у неонових синіх тонах для AWP"
            maxLength={300}
            className="w-full rounded-xl border border-zinc-800 bg-zinc-900/90 px-4 py-2.5 text-sm text-white placeholder-zinc-500 focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
          />
        </div>

        <div className="flex items-center justify-between pt-1">
          <span className="text-xs text-zinc-500">
            Генерація на базі моделі Gemini Flash
          </span>
          <button
            type="submit"
            className="rounded-xl bg-gradient-to-r from-amber-500 to-amber-600 px-5 py-2 text-sm font-semibold text-zinc-950 shadow-md hover:from-amber-400 hover:to-amber-500 transition-all active:scale-[0.98]"
          >
            Згенерувати скін (ШІ)
          </button>
        </div>
      </ActionForm>
    </div>
  );
}
