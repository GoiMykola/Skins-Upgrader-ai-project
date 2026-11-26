-- Виправлення за аудитом політик і Security Advisor (практична робота 7, крок 9).

-- 1. Відкликаємо прямий виклик функцій SECURITY DEFINER від незалогінених (anon / public).
-- Тригерну функцію handle_new_user() закриваємо також від authenticated (викликається лише тригером auth.users).
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.my_profile_id() from public, anon;
revoke execute on function public.my_role() from public, anon;

-- Вбудовану тригерну функцію Supabase (якщо доступна нашому власнику) теж обмежуємо.
do $$
begin
  execute 'revoke execute on function public.rls_auto_enable() from public, anon, authenticated';
exception
  when others then null;
end $$;

-- 2. Відкликаємо право SELECT у ролі anon на таблицях, де всі політики лише для authenticated.
revoke select on public.profiles, public.reports, public.skins, public.upgrades, public.user_inventory from anon;
