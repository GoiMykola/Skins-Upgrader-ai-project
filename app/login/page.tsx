// Сторінка входу й реєстрації (практична робота 5). Не змінюйте цей файл.
import { ActionForm } from "@/components/action-form";
import { db } from "@/lib/data/db/client";
import { signInAction, signOutAction, signUpAction } from "./actions";

const field = "w-full rounded border border-zinc-700 bg-zinc-900 px-3 py-2 text-white placeholder-zinc-400 focus:outline-none focus:ring-1 focus:ring-amber-500";
const button = "w-full rounded bg-amber-500 px-4 py-2 font-medium text-black hover:bg-amber-400 transition";

export default async function LoginPage({ searchParams }: { searchParams: Promise<{ next?: string }> }) {
  const { next = "/" } = await searchParams;
  const { data } = await db().auth.getUser();
  return (
    <main className="mx-auto w-full max-w-md space-y-8 p-6 text-white">
      {data.user ? (
        <section className="space-y-2 rounded border border-zinc-800 bg-zinc-900/50 p-4">
          <p>
            Ви увійшли як <strong>{data.user.email}</strong>.
          </p>
          <form action={signOutAction}>
            <button className="rounded border border-zinc-700 px-3 py-1 text-sm hover:bg-zinc-800">Вийти</button>
          </form>
        </section>
      ) : null}
      <section className="rounded-xl border border-zinc-800 bg-zinc-900/60 p-6 shadow-xl">
        <h1 className="mb-4 text-xl font-bold text-amber-400">Вхід</h1>
        <ActionForm action={signInAction} className="space-y-4">
          <input type="hidden" name="next" value={next} />
          <div>
            <label className="block text-xs uppercase tracking-wider text-zinc-400 mb-1">Пошта</label>
            <input name="email" type="email" required placeholder="name@example.com" className={field} />
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wider text-zinc-400 mb-1">Пароль</label>
            <input name="password" type="password" required placeholder="••••••••" className={field} />
          </div>
          <button className={button}>Увійти</button>
        </ActionForm>
      </section>
      <section className="rounded-xl border border-zinc-800 bg-zinc-900/60 p-6 shadow-xl">
        <h2 className="mb-4 text-xl font-bold text-zinc-200">Реєстрація</h2>
        <ActionForm action={signUpAction} className="space-y-4">
          <input type="hidden" name="next" value={next} />
          <div>
            <label className="block text-xs uppercase tracking-wider text-zinc-400 mb-1">Ім'я та прізвище</label>
            <input name="full_name" required placeholder="Користувач" className={field} />
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wider text-zinc-400 mb-1">Пошта</label>
            <input name="email" type="email" required placeholder="name+c@example.com" className={field} />
          </div>
          <div>
            <label className="block text-xs uppercase tracking-wider text-zinc-400 mb-1">Пароль (від 6 символів)</label>
            <input name="password" type="password" required minLength={6} placeholder="••••••••" className={field} />
          </div>
          <button className={button}>Зареєструватися</button>
        </ActionForm>
      </section>
    </main>
  );
}
