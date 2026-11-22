-- Міграція 3: користувачі, власники записів і доступ за роллю (практична робота 5).
-- Тема: «GoiCoins Skin Simulator». Ролі: гравець (player) та адміністратор (admin).

-- 1. Профіль прив'язується до облікового запису входу auth.users.
alter table public.profiles
  add column if not exists user_id uuid unique references auth.users (id) on delete cascade;

-- 2. Профіль створюється автоматично під час реєстрації.
create or replace function public.handle_new_user() returns trigger
  language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (user_id, username, balance_coins, role)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''), split_part(new.email, '@', 1)),
    1000,
    'player'
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- Дозаповнення профілів для вже створених акаунтів (А, Б, В).
insert into public.profiles (user_id, username, balance_coins, role)
select u.id, coalesce(nullif(trim(u.raw_user_meta_data ->> 'full_name'), ''), split_part(u.email, '@', 1)), 1000, 'player'
from auth.users u
where not exists (select 1 from public.profiles p where p.user_id = u.id)
on conflict do nothing;

-- 3. Допоміжні функції «хто зараз увійшов» (security definer усуває infinite recursion).
create or replace function public.my_profile_id() returns uuid
  language sql stable security definer set search_path = '' as $$
  select id from public.profiles where user_id = auth.uid() limit 1;
$$;

create or replace function public.my_role() returns text
  language sql stable security definer set search_path = '' as $$
  select role from public.profiles where user_id = auth.uid() limit 1;
$$;

-- 4. Власник скіна (для користувацьких скінів).
alter table public.skins
  add column if not exists owner_id uuid default public.my_profile_id() references public.profiles (id) on delete cascade;

-- 5. Прибираємо всі тимчасові політики ПР 4 (pr4_temp_all).
drop policy if exists "pr4_temp_all" on public.profiles;
drop policy if exists "pr4_temp_all" on public.skins;
drop policy if exists "pr4_temp_all" on public.user_inventory;
drop policy if exists "pr4_temp_all" on public.upgrades;
drop policy if exists "pr4_temp_all" on public.reports;

-- 6. Відкликаємо права зміни від ролі anon на всіх таблицях.
revoke insert, update, delete on public.profiles, public.skins, public.user_inventory, public.upgrades, public.reports from anon;

-- 7. Захист ролі: authenticated може оновлювати лише свій нікнейм/баланс.
revoke update on public.profiles from authenticated;
grant update (username, balance_coins) on public.profiles to authenticated;

-- 8. Справжні політики RLS за користувачем і роллю.

-- PROFILES
create policy "profiles_select" on public.profiles
  for select to authenticated using (true);
create policy "profiles_update_own" on public.profiles
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- SKINS: системні скіни (owner_id is null) бачать усі, створені користувачем — лише їх власник або адмін
create policy "skins_select" on public.skins
  for select to authenticated using (
    owner_id is null or owner_id = public.my_profile_id() or public.my_role() = 'admin'
  );
create policy "skins_insert" on public.skins
  for insert to authenticated with check (
    owner_id = public.my_profile_id() or public.my_role() = 'admin'
  );
create policy "skins_update_own" on public.skins
  for update to authenticated using (
    owner_id = public.my_profile_id() or public.my_role() = 'admin'
  );
create policy "skins_delete_own" on public.skins
  for delete to authenticated using (
    owner_id = public.my_profile_id() or public.my_role() = 'admin'
  );

-- USER_INVENTORY: кожен бачить і змінює лише власний інвентар
create policy "user_inventory_select" on public.user_inventory
  for select to authenticated using (user_id = public.my_profile_id());
create policy "user_inventory_insert" on public.user_inventory
  for insert to authenticated with check (user_id = public.my_profile_id());
create policy "user_inventory_delete" on public.user_inventory
  for delete to authenticated using (user_id = public.my_profile_id());

-- UPGRADES: гравець бачить свої апгрейди, адмін — усі
create policy "upgrades_select" on public.upgrades
  for select to authenticated using (
    user_id = public.my_profile_id() or public.my_role() = 'admin'
  );
create policy "upgrades_insert" on public.upgrades
  for insert to authenticated with check (user_id = public.my_profile_id());

-- REPORTS: користувач бачить свої подані скарги (author_id), адмін — усі
create policy "reports_select" on public.reports
  for select to authenticated using (
    author_id = public.my_profile_id() or public.my_role() = 'admin'
  );
create policy "reports_insert" on public.reports
  for insert to authenticated with check (author_id = public.my_profile_id());
create policy "reports_delete_admin" on public.reports
  for delete to authenticated using (public.my_role() = 'admin');
