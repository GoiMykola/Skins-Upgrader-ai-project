"use client";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="min-h-[50vh] flex flex-col items-center justify-center text-center p-8">
      <div className="bg-red-500/10 border border-red-500/30 rounded-2xl p-6 max-w-md w-full">
        <div className="text-red-400 text-3xl mb-2">⚠</div>
        <h2 className="text-xl font-bold text-white mb-2">Помилка завантаження</h2>
        <p className="text-gray-400 text-sm mb-6">Користувача не знайдено або сталася помилка</p>
        <button
          onClick={() => reset()}
          className="px-6 py-2.5 bg-amber-500 hover:bg-amber-400 text-black font-semibold rounded-xl transition"
        >
          Спробувати ще раз
        </button>
      </div>
    </div>
  );
}
