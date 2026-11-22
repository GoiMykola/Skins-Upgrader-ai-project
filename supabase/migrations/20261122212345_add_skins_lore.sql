-- Міграція 2: лор та передісторія скінів (відкладена функція Ф8).
-- Нове поле додається без NOT NULL, тому наявні записи зберігаються і набувають значення NULL.
alter table public.skins add column lore_description text;
