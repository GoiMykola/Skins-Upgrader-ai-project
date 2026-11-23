import { skins } from "@/app/data";
import { AiSkinWorkshop } from "@/components/ai-skin-workshop";
import SkinTile from "@/app/components/skin-tile";

export default function CatalogPage() {
  return (
    <div className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
      <div className="mb-8">
        <h1 className="text-3xl font-black text-white sm:text-4xl">Каталог скінів</h1>
        <p className="mt-2 text-sm text-slate-400">
          Обирай скіни для своєї колекції або генеруй власні через штучний інтелект.
        </p>
      </div>

      <AiSkinWorkshop isConfigured={true} />

      <section className="mt-12">
        <div className="mb-6 flex items-center justify-between border-b border-white/[0.08] pb-4">
          <h2 className="text-xl font-bold text-white">Доступні скіни ({skins.length})</h2>
          <span className="text-xs font-mono text-slate-400">Сортування: За популярністю</span>
        </div>
        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {skins.map((skin) => (
            <SkinTile key={skin.finish} skin={skin} action="В інвентар" href="/inventory" />
          ))}
        </div>
      </section>
    </div>
  );
}
