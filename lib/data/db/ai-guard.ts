import { db } from "./client";

// Скільки платних викликів зробив поточний користувач за останню годину
export async function countMyCallsSince(since: string): Promise<number> {
  const { count, error } = await db()
    .from("ai_calls")
    .select("id", { count: "exact", head: true })
    .eq("cached", false)
    .gte("created_at", since);
  if (error) throw new Error(error.message);
  return count ?? 0;
}

// Скільки платних викликів зробив увесь застосунок за сьогодні (UTC)
export async function appCallsToday(): Promise<number> {
  const { data, error } = await db().rpc("ai_app_calls_today");
  if (error) throw new Error(error.message);
  return Number(data ?? 0);
}

// Фіксація виклику моделі в базі
export async function recordCall(cached: boolean): Promise<void> {
  if (process.env.VITEST) return;
  const { error } = await db().from("ai_calls").insert({ cached });
  if (error) throw new Error(error.message);
}

// Читання з кешу
export async function readCache(key: string): Promise<string | null> {
  const { data, error } = await db()
    .from("ai_cache")
    .select("output, expires_at")
    .eq("key", key)
    .maybeSingle();
  if (error || !data) return null;
  if (new Date(data.expires_at).getTime() < Date.now()) return null;
  return data.output;
}

// Запис у кеш
export async function writeCache(key: string, output: string, ttlSeconds: number): Promise<void> {
  if (process.env.VITEST) return;
  const expiresAt = new Date(Date.now() + ttlSeconds * 1000).toISOString();
  const { error } = await db()
    .from("ai_cache")
    .upsert({ key, output, expires_at: expiresAt });
  if (error) console.error("Cache write error:", error.message);
}
