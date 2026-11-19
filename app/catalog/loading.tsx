export default function Loading() {
  return (
    <div className="min-h-[50vh] flex flex-col items-center justify-center text-center p-8">
      <div className="w-12 h-12 border-4 border-amber-500 border-t-transparent rounded-full animate-spin mb-4" />
      <p className="text-gray-400 font-medium">Завантаження каталогу зброї...</p>
    </div>
  );
}
