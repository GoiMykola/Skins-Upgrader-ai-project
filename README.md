# GoiCoins Skin Simulator

## 1. Що це
**GoiCoins Skin Simulator** — навчальний вебзастосунок-симулятор інвентаря, каталогу та апгрейду ігрових скінів CS2 на віртуальну валюту (GoiCoins) без реальних грошей та азартних ставок. Користувачі можуть генерувати нові скіни за допомогою ШІ, переглядати публічні профілі та таблицю лідерів, виконувати апгрейди з живою стрічкою результатів у реальному часі (Supabase Realtime) і подавати скарги на профілі.

- **Розгорнута версія (Production):** https://skins-upgrader-ai-project.vercel.app

## 2. Стек і версії
- **Фреймворк:** Next.js `16.3.6` (App Router), React `19.2.8`, TypeScript `^5`, Tailwind CSS `^4`
- **База даних, автентифікація та Realtime:** Supabase (`@supabase/supabase-js`, `@supabase/ssr`, `supabase` CLI)
- **Тестування та лінтинг:** Vitest `^3`, ESLint `^9` (`eslint-config-next` `16.3.6`)
- **Хостинг і CI:** Vercel, GitHub Actions
- **Середовище виконання:** Node.js `>=24 <25` (v24 LTS)

## 3. Необхідні акаунти
Для розгортання та запуску з нуля потрібні безкоштовні акаунти у чотирьох сервісах:
1. **GitHub** (репозиторій, Codespaces, GitHub Actions, CodeQL)
2. **Supabase** (хмарна база PostgreSQL, Auth, Realtime, міграції)
3. **Vercel** (хостинг Preview та Production)
4. **Google AI Studio** (ключ `GEMINI_API_KEY` для ШІ-майстерні скінів)

## 4. Створення середовища (GitHub Codespace)
Проєкт налаштований для роботи в хмарному середовищі **GitHub Codespaces** (без локальної бази чи Docker):
1. На сторінці репозиторію натисніть **Code → Codespaces → Create codespace on main** (або **+**).
2. Під час старту дев-контейнера автоматично встановлюються залежності (`npm ci`) і прокидається порт `3000`.
3. Перевірте версію Node.js у терміналі:
   ```bash
   node -v
   ```
   Очікуваний вивід починається з `v24.`.

## 5. Змінні середовища
| Назва змінної | Де взяти значення | `.env.local` (Codespace) | Vercel `Production` | Vercel `Preview` | Секрети GitHub Actions |
| --- | --- | --- | --- | --- | --- |
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase → Project Settings → Data API (базовий URL `https://<project-ref>.supabase.co`, **без** `/rest/v1`) | так | так | так | так |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase → Project Settings → API Keys (Publishable або legacy `anon` public, **не** Secret key) | так | так | так | так |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase → Project Settings → API Keys (необов'язково, лише для резервного скидання паролів тестів) | за потреби | ні | ні | ні |
| `TEST_USER_A_EMAIL` | Email тестового гравця А (створюється в Supabase Auth) | так | ні | ні | так |
| `TEST_USER_B_EMAIL` | Email тестового гравця Б (створюється в Supabase Auth) | так | ні | ні | так |
| `TEST_USER_PASSWORD` | Спільний пароль для тестових акаунтів А і Б | так | ні | ні | так |
| `GEMINI_API_KEY` | Google AI Studio → API keys (окремі ключі для Prod і Preview) | так | ключ 1 | ключ 2 | ні |
| `GEMINI_MODEL` | Назва моделі Gemini (наприклад `gemini-3.5-flash-lite`) | за потреби | так | так | ні |

## 6. Файл `.env.example`
Скопіюйте шаблон `.env.example` у `.env.local` (файл `.env.local` ігнорується Git через `.gitignore`):
```bash
cp .env.example .env.local
```
Вміст `.env.example` містить лише назви змінних без значень:
```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
TEST_USER_A_EMAIL=
TEST_USER_B_EMAIL=
TEST_USER_PASSWORD=
GEMINI_API_KEY=
GEMINI_MODEL=
```
Заповніть `.env.local` власними значеннями без пробілів і лапок.

## 7. Налаштування бази даних (Supabase)
1. У [supabase.com/dashboard](https://supabase.com/dashboard) створіть новий проєкт на безкоштовному тарифі.
2. У панелі проєкту відкрийте **Authentication → Sign In / Providers → Email** і **вимкніть `Confirm email`**, щоб реєстрація одразу створювала активну сесію без підтвердження пошти. *(Кошики Storage у проєкті не використовуються.)*
3. У терміналі виконайте вхід, прив'язку до проєкту (20-літерний `project-ref` із URL панелі Supabase або з виводу `npx supabase projects list` — **без кутових дужок `< >`**) та накатіть усі 7 міграцій із каталогу `supabase/migrations/`:
   ```bash
   npx supabase login
   npx supabase projects list
   npx supabase link --project-ref ВСТАВТЕ_PROJECT_REF_БЕЗ_ДУЖОК
   npx supabase db push
   ```
   У каталозі `supabase/migrations/` містяться міграції:
   - `20261122204945_create_schema.sql`
   - `20261122212345_add_skins_lore.sql`
   - `20261122230520_access_by_user.sql`
   - `20261122233652_add_realtime_upgrades.sql`
   - `20261123142414_ai_guard.sql`
   - `20261126123506_policy_fixes.sql`
   - `20261127122300_grant_helper_functions.sql`
4. Перевірте синхронізацію міграцій:
   ```bash
   npx supabase migration list
   ```
   Усі 7 міграцій мають відображатися в обох колонках (`Local` і `Remote`).

## 8. Тестові акаунти й дані
1. У панелі Supabase перейдіть до **Authentication → Users → Add user → Create new user**.
2. Створіть два тестові акаунти:
   - акаунт А з поштою, яку впишете в `TEST_USER_A_EMAIL` (наприклад, `<login>+a@gmail.com`);
   - акаунт Б з поштою, яку впишете в `TEST_USER_B_EMAIL` (наприклад, `<login>+b@gmail.com`).
3. Задайте обом акаунтам один і той самий пароль (який впишете в `TEST_USER_PASSWORD` у `.env.local` та в секретах GitHub) і переконайтеся, що статус підтвердження пошти активний (`Auto Confirm User`).
4. Тригер `public.handle_new_user()` автоматично створить для кожного користувача запис у таблиці `public.profiles` із роллю `player` та балансом `1000` GoiCoins — додаткових ручних вставок у таблиці для проходження тестів не потрібно.

## 9. Запуск тестів
Для перевірки роботи бази даних, політик доступу RLS, серверних дій та ШІ-майстерні виконайте:
```bash
npm test
```
Очікуваний підсумок (усі тести зелені без `failed`):
```text
 Test Files  5 passed (5)
      Tests  18 passed (18)
```
Також доступні перевірки лінтера й продакшн-збирання:
```bash
npm run lint
npm run build
```

## 10. Запуск застосунку
1. Запустіть сервер розробки в терміналі:
   ```bash
   npm run dev
   ```
2. Після появи `Ready` відкрийте вкладку **Ports** у Codespace → рядок порту **3000** → значок **Open in Browser**.
3. Перейдіть на `/login` або відкрийте форму входу, зареєструйте новий акаунт чи увійдіть під тестовим акаунтом А і перевірте роботу каталогу, інвентаря та ШІ-майстерні (`/catalog`).

## 11. Розгортання на Vercel
1. Імпортуйте репозиторій у [vercel.com](https://vercel.com) (Framework Preset: **Next.js**).
2. У **Settings → Environment Variables** додайте змінні окремо за середовищами (без `TEST_USER_…`):
   - `NEXT_PUBLIC_SUPABASE_URL` → **Production** та **Preview**
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` → **Production** та **Preview**
   - `GEMINI_API_KEY` → окремий ключ для **Production** і окремий ключ для **Preview**
   - `GEMINI_MODEL` → `gemini-3.5-flash-lite` для **Production** та **Preview**
3. Кожне злиття в `main` автоматично запускає **Production**-розгортання, а кожен Pull Request — **Preview**. *(Задачі Cron у проєкті не використовуються.)*

## 12. Конвеєр перевірок і захист гілки `main`
1. У GitHub **Settings → Secrets and variables → Actions → Repository secrets** додайте 5 секретів:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `TEST_USER_A_EMAIL`
   - `TEST_USER_B_EMAIL`
   - `TEST_USER_PASSWORD`
2. Конвеєр [.github/workflows/ci.yml](.github/workflows/ci.yml) на кожен push і pull request до `main` запускає три перевірки: `lint`, `test` та `secrets`. Паралельно в репозиторії ввімкнено **CodeQL** і **Secret scanning / Push protection**.
3. У **Settings → Rules → Rulesets** діє правило **`main-protection`** (порожній Bypass list, обов'язковий Pull Request, обов'язкові перевірки `lint`, `test`, `secrets` та `CodeQL` без `High+` алертів). Усі зміни в `main` потрапляють лише через Pull Request.
