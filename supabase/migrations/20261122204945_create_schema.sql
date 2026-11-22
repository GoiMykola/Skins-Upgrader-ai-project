-- Міграція 1: схема даних від екранів (практична робота 4).
-- Проєкт: GoiCoins Skin Simulator.

create table public.profiles (
  id uuid primary key default gen_random_uuid(),
  username text not null check (length(trim(username)) > 0),
  balance_coins integer not null default 1000 check (balance_coins >= 0),
  role text not null default 'player',
  created_at timestamptz not null default now()
);

create table public.skins (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  weapon text not null check (length(trim(weapon)) > 0),
  category text not null check (length(trim(category)) > 0),
  rarity text not null check (length(trim(rarity)) > 0),
  price_coins integer not null check (price_coins > 0),
  image_url text not null
);

create table public.user_inventory (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  skin_id uuid not null references public.skins(id) on delete cascade,
  status text not null default 'active',
  acquired_at timestamptz not null default now()
);

create table public.upgrades (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  input_skin_id uuid not null references public.skins(id) on delete cascade,
  target_skin_id uuid not null references public.skins(id) on delete cascade,
  chance numeric(5,2) not null check (chance > 0 and chance <= 100),
  is_success boolean not null,
  created_at timestamptz not null default now()
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  target_user_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null check (length(trim(reason)) > 0),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.skins enable row level security;
alter table public.user_inventory enable row level security;
alter table public.upgrades enable row level security;
alter table public.reports enable row level security;

create policy "pr4_temp_all" on public.profiles for all to anon, authenticated using (true) with check (true);
create policy "pr4_temp_all" on public.skins for all to anon, authenticated using (true) with check (true);
create policy "pr4_temp_all" on public.user_inventory for all to anon, authenticated using (true) with check (true);
create policy "pr4_temp_all" on public.upgrades for all to anon, authenticated using (true) with check (true);
create policy "pr4_temp_all" on public.reports for all to anon, authenticated using (true) with check (true);

grant select, insert, update, delete on public.profiles to anon, authenticated, service_role;
grant select, insert, update, delete on public.skins to anon, authenticated, service_role;
grant select, insert, update, delete on public.user_inventory to anon, authenticated, service_role;
grant select, insert, update, delete on public.upgrades to anon, authenticated, service_role;
grant select, insert, update, delete on public.reports to anon, authenticated, service_role;
