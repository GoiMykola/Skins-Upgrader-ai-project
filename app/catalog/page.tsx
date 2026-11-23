import { listSkins } from "@/lib/data/skins";
import { AiSkinWorkshop } from "@/components/ai-skin-workshop";

export const dynamic = "force-dynamic";

export default async function CatalogPage() {
  const skins = await listSkins();

  return (
    <main className="min-h-screen bg-black text-white px-4 py-10 sm:px-8">
      <div className="mx-auto max-w-6xl">
        {/* Заголовок */}
        <div className="mb-8 text-center sm:text-left">
          <h1 className="text-3xl font-extrabold tracking-tight sm:text-4xl text-white">
            Каталог скінів
          </h1>
          <p className="mt-2 text-sm text-zinc-400">
            Обирай скіни для своєї колекції або створюй власні за допомогою штучного інтелекту.
          </p>
        </div>

        {/* ШІ-Майстерня */}
        <AiSkinWorkshop />

        {/* Сітка скінів */}
        <h3 className="mb-4 text-xl font-bold text-white">Доступні скіни ({skins.length})</h3>
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
          {skins.map((skin) => (
            <div
              key={skin.id}
              className="group relative overflow-hidden rounded-2xl border border-zinc-800 bg-zinc-900/50 p-4 transition-all hover:border-zinc-700 hover:bg-zinc-900"
            >
              <div className="aspect-video w-full overflow-hidden rounded-xl bg-zinc-800 flex items-center justify-center">
                <span className="text-3xl font-black text-zinc-700 uppercase group-hover:scale-110 transition-transform">
                  {skin.weapon.slice(0, 3)}
                </span>
              </div>
              <div className="mt-4">
                <span className="text-xs font-semibold text-amber-400">{skin.rarity}</span>
                <h4 className="font-bold text-white">{skin.name}</h4>
                <p className="text-xs text-zinc-400">{skin.weapon} · {skin.category}</p>
                <div className="mt-3 flex items-center justify-between">
                  <span className="font-extrabold text-amber-500">{skin.price} GC</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </main>
  );
}
