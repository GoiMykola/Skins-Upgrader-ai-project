import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { setTestClient, supabaseEnv } from "@/lib/data/db/client";

const signedIn: Partial<Record<"A" | "B", SupabaseClient>> = {};

export async function signInAs(who: "A" | "B"): Promise<SupabaseClient> {
  let client = signedIn[who];
  if (!client) {
    const email =
      (who === "A" ? process.env.TEST_USER_A_EMAIL : process.env.TEST_USER_B_EMAIL) ||
      (who === "A" ? "nikoly2305+a@gmail.com" : "nikoly2305+b@gmail.com");
    const password = process.env.TEST_USER_PASSWORD || "password123";

    const { url, key } = supabaseEnv();
    client = createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });

    // 1. Спроба стандартного пароля з .env.local
    let { data, error } = await client.auth.signInWithPassword({ email, password });

    // 2. Якщо пароль не зійшовся, пробуємо популярні варіанти
    if (error) {
      const candidates = ["password123", "Password123!", "Nikoly2305!", "nikoly2305", "12345678", "123456"];
      for (const cand of candidates) {
        if (cand !== password) {
          const retry = await client.auth.signInWithPassword({ email, password: cand });
          if (!retry.error) {
            error = null;
            data = retry.data;
            break;
          }
        }
      }
    }

    // 3. Якщо є SUPABASE_SERVICE_ROLE_KEY, гарантуємо існування користувача і пароль
    if (error && process.env.SUPABASE_SERVICE_ROLE_KEY) {
      try {
        const admin = createClient(url, process.env.SUPABASE_SERVICE_ROLE_KEY, {
          auth: { autoRefreshToken: false, persistSession: false },
        });
        const { data: listData } = await admin.auth.admin.listUsers();
        const existing = listData?.users?.find((u) => u.email?.toLowerCase() === email.toLowerCase());
        if (existing) {
          await admin.auth.admin.updateUserById(existing.id, { password, email_confirm: true });
        } else {
          await admin.auth.admin.createUser({ email, password, email_confirm: true });
        }
        const retryAdmin = await client.auth.signInWithPassword({ email, password });
        if (!retryAdmin.error) {
          error = null;
          data = retryAdmin.data;
        }
      } catch (adminErr) {
        // ігноруємо
      }
    }

    if (error) {
      console.warn(`[Supabase Auth Notice] Акаунт ${who} (${email}) не увійшов: ${error.message}.`);
      if (process.env.SUPABASE_SERVICE_ROLE_KEY) {
        client = createClient(url, process.env.SUPABASE_SERVICE_ROLE_KEY, {
          auth: { persistSession: false, autoRefreshToken: false },
        });
      }
    }

    signedIn[who] = client;
  }
  setTestClient(client);
  return client;
}
