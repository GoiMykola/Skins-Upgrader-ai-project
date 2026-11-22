import { createServerClient } from "@supabase/ssr";
import type { SupabaseClient } from "@supabase/supabase-js";
import { cookies } from "next/headers";
import { faultFetch } from "./fault-mode";

let testClient: SupabaseClient | undefined;

export function setTestClient(client: SupabaseClient): void {
  testClient = client;
}

export function supabaseEnv(): { url: string; key: string } {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) {
    throw new Error(
      "Немає NEXT_PUBLIC_SUPABASE_URL або NEXT_PUBLIC_SUPABASE_ANON_KEY: перевірте файл .env.local",
    );
  }
  return { url, key };
}

export function db(): SupabaseClient {
  if (process.env.VITEST) {
    if (!testClient) {
      throw new Error("Тест не увійшов: перевірте tests/setup.ts і змінні TEST_USER_… у .env.local");
    }
    return testClient;
  }
  const { url, key } = supabaseEnv();
  const cookieStore = cookies();
  return createServerClient(url, key, {
    cookies: {
      async getAll() {
        return (await cookieStore).getAll();
      },
      async setAll(cookiesToSet) {
        try {
          const store = await cookieStore;
          for (const { name, value, options } of cookiesToSet) store.set(name, value, options);
        } catch {}
      },
    },
    global: { fetch: faultFetch },
  });
}
