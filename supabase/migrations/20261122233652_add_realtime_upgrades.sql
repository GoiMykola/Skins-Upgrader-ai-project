-- Складна складова «оновлення в реальному часі» (Supabase Realtime, вимога В4).
-- Будь-який новий апгрейд транслюється через сокети браузерам гравців.
alter publication supabase_realtime add table public.upgrades;
