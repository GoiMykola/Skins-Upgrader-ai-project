# Аудит безпеки ПР 7

## Таблиця 1. Знахідки безпеки (5.1)

| № | Джерело | Назва знахідки | Критичність | Файл і рядок або об'єкт бази | Що зроблено | Доказ |
| --- | --- | --- | --- | --- | --- | --- |
| З1 | CodeQL | Clear text storage of sensitive information (19 шт.) | висока | `lib/auth-storage.ts`, `lib/inventory-storage.ts`, `lib/admin-vault-storage.ts`, `app/inventory/page.tsx:92` | Виправлено: прибрано збереження паролів і чутливих полів із `localStorage` та `SUPABASE_TEST_ACCOUNTS`, перевірку перенесено в оперативну пам'ять | `b1cdd0e` + коміт кроку 9 |
| З2 | CodeQL | DOM text reinterpreted as HTML (5 шт.) | висока | `app/components/skin-art.tsx:81`, `app/contracts/page.tsx:121,170`, `app/duel/page.tsx:106,163` | Виправлено: санітизація URL зображень через `sanitizeImageUrl()` (`lib/safe-url.ts`) із білим списком доменів та `encodeURIComponent` | `655e4eb`; CodeQL — 10 Closed as fixed |
| З3 | Advisor | Public Can Execute SECURITY DEFINER Function (4 шт.) | середня | `public.handle_new_user()`, `public.my_profile_id()`, `public.my_role()`, `public.rls_auto_enable()` | Виправлено: у міграції `policy_fixes` відкликано `EXECUTE` від `public, anon` | `20261126123506_policy_fixes.sql` |
| З4 | Advisor | Signed-In Users Can Execute SECURITY DEFINER Function (5 шт.) | середня | `public.ai_app_calls_today()`, `public.my_profile_id()`, `public.my_role()`, `public.handle_new_user()`, `public.rls_auto_enable()` | Для тригерної `handle_new_user()` відкликано `EXECUTE` від `authenticated`; для `my_profile_id()`, `my_role()`, `ai_app_calls_today()` обґрунтовано в 5.2 (потрібні для RLS та ліміту ШІ) | `20261126123506_policy_fixes.sql`; звіт 5.2 |
| З5 | Advisor | Leaked Password Protection Disabled | середня | `Auth` | Обґрунтовано в 5.2 (функція доступна лише на платному тарифі Supabase; паролі перевіряються за довжиною, реальних платіжних даних немає) | Звіт 5.2 |
| З6 | npm audit | Вразливості у залежностях (`sharp`, `source-map-js`, `next`) | висока | `package-lock.json` (`next@16.3.6`) | `sharp` і `source-map-js` оновлено через `npm audit fix`; `next` залишено (оновлення потребує `--force`, що заборонено правилами курсу) | `a1f1670` |
| З7 | ручна перевірка | Помилки лінтера `npm run lint` (35 errors, 25 warnings) | середня | `app/`, `components/`, `lib/` | Виправлено всі `errors`: прибрано `any`, `prefer-const`, неекранований апостроф і синхронний `setState` в `useEffect` (`0 errors` після виправлення) | `npm run lint` → `0 errors`; коміт кроку 9 |

## Таблиця 2. Політики доступу (5.6)

| Таблиця | Політика | Дія | Кому | Умова своїми словами | Позначка запиту 2 | Що змінилося з ПР 5 |
| --- | --- | --- | --- | --- | --- | --- |
| `ai_cache` | `ai_cache_insert_own` | INSERT | `{authenticated}` | Користувач додає кеш лише зі своїм `user_id = auth.uid()` | — | додано в ПР 6 |
| `ai_cache` | `ai_cache_select_own` | SELECT | `{authenticated}` | Користувач читає лише власні записи кешу | — | додано в ПР 6 |
| `ai_cache` | `ai_cache_update_own` | UPDATE | `{authenticated}` | Користувач оновлює лише власні записи кешу | — | додано в ПР 6 |
| `ai_calls` | `ai_calls_insert_own` | INSERT | `{authenticated}` | Користувач фіксує виклик лише для свого `user_id = auth.uid()` | — | додано в ПР 6 |
| `ai_calls` | `ai_calls_select_own` | SELECT | `{authenticated}` | Користувач читає лише власну історію лічильника викликів | — | додано в ПР 6 |
| `profiles` | `profiles_select` | SELECT | `{authenticated}` | Усі авторизовані користувачі можуть переглядати профілі (для лідерборду та публічних сторінок) | `ДОЗВОЛЯЄ ВСЕ` | без змін |
| `profiles` | `profiles_update_own` | UPDATE | `{authenticated}` | Користувач оновлює лише власний профіль (`username`, `balance_coins`) | — | без змін |
| `reports` | `reports_delete_admin` | DELETE | `{authenticated}` | Видаляти скарги може лише користувач із роллю `admin` | — | без змін |
| `reports` | `reports_insert` | INSERT | `{authenticated}` | Гравець може створити скаргу лише від свого імені (`author_id = my_profile_id()`) | — | без змін |
| `reports` | `reports_select` | SELECT | `{authenticated}` | Гравець бачить лише подані ним скарги, адміністратор бачить усі | — | без змін |
| `skins` | `skins_delete_own` | DELETE | `{authenticated}` | Видаляти скін може лише його власник або адміністратор | — | без змін |
| `skins` | `skins_insert` | INSERT | `{authenticated}` | Додавати скін може авторизований гравець як власник або адміністратор | — | без змін |
| `skins` | `skins_select` | SELECT | `{authenticated}` | Системні скіни (`owner_id is null`) бачать усі; авторські — власник або адміністратор | — | без змін |
| `skins` | `skins_update_own` | UPDATE | `{authenticated}` | Оновлювати скін може лише його власник або адміністратор | — | без змін |
| `upgrades` | `upgrades_insert` | INSERT | `{authenticated}` | Запис апгрейду може додати лише його автор (`user_id = my_profile_id()`) | — | без змін |
| `upgrades` | `upgrades_select` | SELECT | `{authenticated}` | Гравець бачить свої апгрейди, адміністратор — усі | — | без змін |
| `user_inventory` | `user_inventory_delete` | DELETE | `{authenticated}` | Видаляти предмети можна лише зі свого інвентаря | — | без змін |
| `user_inventory` | `user_inventory_insert` | INSERT | `{authenticated}` | Додавати предмети можна лише у свій інвентар | — | без змін |
| `user_inventory` | `user_inventory_select` | SELECT | `{authenticated}` | Переглядати можна лише власний інвентар | — | без змін |

- **Функції `security definer` (запит 3):** `ai_app_calls_today()` (`anon` не викликає); `handle_new_user()`, `my_profile_id()`, `my_role()` — `EXECUTE` відкликано від `public, anon` у міграції `20261126123506_policy_fixes.sql`; `rls_auto_enable()` — системний обробник тригера подій Supabase.
- **Кошики Storage (запит 4):** не застосовно (Storage у проєкті не використовується).
- **Службовий ключ:** у коді застосунку (`app/`, `lib/`, `components/`, `proxy.ts`) не використовується; згадується лише в тестовому помічнику `tests/helpers/users.ts` для підготовки тестових акаунтів.
