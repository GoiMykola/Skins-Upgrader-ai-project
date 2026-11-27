# Журнал взаємодії з ШІ (ПР 7)
## Практична робота № 7: Безпека, конвеєр і продакшн
**Студент:** Штанько Микола  
**Група:** 1П-24(Б)  
**Тема проєкту:** GoiCoins Skin Simulator (Власна тема)  
**Репозиторій:** https://github.com/GoiMykola/Skins-Upgrader-ai-project  

---

### [№ 01] AI Studio · Первинний запит · Крок 3 (Пояснення знахідок за заготовкою 1)
**Користувач:**
Ось знахідка статичного аналізу:
1. CodeQL — `Clear text storage of sensitive information` (19 попереджень) у `lib/auth-storage.ts`, `lib/inventory-storage.ts`, `lib/admin-vault-storage.ts`, `app/inventory/page.tsx:92`.
2. CodeQL — `DOM text reinterpreted as HTML` (5 попереджень) у `app/components/skin-art.tsx:81`, `app/contracts/page.tsx:121,170`, `app/duel/page.tsx:106,163` при передачі URL зображення в `<img>`.
3. Supabase Security Advisor — `Public Can Execute SECURITY DEFINER Function` (4 функції) і `Leaked Password Protection Disabled`.
Поясни, що саме тут небезпечно і як це може бути використано. Потім запропонуй виправлення, яке не змінює поведінки для добросовісного користувача.
Контекст: Next.js 16 (App Router) + Supabase з RLS; правило: приватні профілі, інвентар і налаштування доступні лише власнику, без додавання нових npm-пакетів; формат відповіді: небезпека / як використати / виправлення.

**AI Studio:**
1. **`Clear text storage of sensitive information`:**
   - *Небезпека та як використати:* збереження паролів і чутливих полів у `localStorage` або тестових об'єктах клієнтського коду робить їх доступними будь-якому скрипту в браузері (XSS або інспектор DevTools).
   - *Виправлення:* прибрати збереження паролів у `localStorage` та в клієнтських масивах, перенести тимчасову перевірку в оперативну пам'ять (`Map` на час сесії) і очищати застарілі поля при завантаженні.
2. **`DOM text reinterpreted as HTML`:**
   - *Небезпека та як використати:* передача неперевіреного рядка URL напряму в `src` атрибута `<img>` дозволяє підставити `javascript:`, `data:` або небажані зовнішні схеми.
   - *Виправлення:* створити власну функцію санітизації `sanitizeImageUrl()` з білим списком дозволених доменів CDN і локальних шляхів без сторонніх пакетів.
3. **`SECURITY DEFINER` та `Leaked Password Protection`:**
   - *Виправлення:* відкликати `EXECUTE` від `public` і `anon` окремою міграцією; `Leaked Password Protection` недоступне на безкоштовному тарифі Supabase — обґрунтувати в розділі 5.2 звіту.

---

### [№ 02] Copilot · Первинний запит · Крок 4 (Виправлення знахідок високої критичності)
**Користувач:**
Виправ знахідки CodeQL високої критичності без зміни поведінки для добросовісного користувача і без нових пакетів:
1. У `lib/auth-storage.ts` та `components/auth-modal.tsx` прибери збереження паролів у `localStorage` та `SUPABASE_TEST_ACCOUNTS`, використай `sessionPassStore` у пам'яті.
2. Створи `lib/safe-url.ts` (`sanitizeImageUrl`) із білим списком хостів (`steamstatic`, `githubusercontent`) і локальних шляхів та застосуй у `app/components/skin-art.tsx`, `app/contracts/page.tsx`, `app/duel/page.tsx`, `lib/inventory-storage.ts`.

**Copilot:**
Змінено `lib/auth-storage.ts`, `components/auth-modal.tsx` (`[код у коміті b1cdd0e]`), створено `lib/safe-url.ts` та оновлено відображення скінів (`[код у коміті 655e4eb]`). Перевірка `npm run lint` і `npm test` (18 тестів) проходить.

---

### [№ 03] Copilot · Уточнення · Крок 4 (Усунення повторного маркування CodeQL у `safe-url.ts`)
**Користувач:**
Після коміту `655e4eb` GitHub CodeQL знову позначив частину алертів `DOM text reinterpreted as HTML`, бо функція `sanitizeImageUrl` конструювала результат через `encodeURI` із вхідного `url.href`. Перероби `lib/safe-url.ts` так, щоб фінальний URL будувався виключно з фіксованого `https://` + значення зі словника `IMAGE_HOST_MAP` + сегментів через `encodeURIComponent`, без повернення сирого вхідного рядка.

**Copilot:**
Оновлено `lib/safe-url.ts` (`[код у коміті 45ca360]`): використано словник `IMAGE_HOST_MAP`, визначення `cdnHost` і покомпонентне кодування шляху через `encodeURIComponent`. Після прогону CodeQL на GitHub усі алерти закрито: `0 Open / 29 Closed`.

---

### [№ 04] Copilot · Первинний запит · Крок 9 (Виправлення помилок ESLint і міграція `policy_fixes`)
**Користувач:**
Виправ усі 34 помилки лінтера `npm run lint` (без додавання `eslint-disable`), не змінюючи файли викладача (`lib/ai/model.ts`, `lib/ai/fault-mode.ts`, `tests/`), і створи нову міграцію `supabase/migrations/20261126123506_policy_fixes.sql`, яка відкликає `EXECUTE` від `public, anon` для `handle_new_user()`, `my_profile_id()`, `my_role()`, `rls_auto_enable()` (а для `handle_new_user()` також від `authenticated`) та відкликає `SELECT` у `anon` на таблицях, де всі політики лише для `authenticated`.

**Copilot:**
Усунено всі помилки типізації `any`, `prefer-const`, неекранованих апострофів та викликів `setState` в `useEffect` у 25 файлах `app/`, `components/`, `lib/`, а також створено міграцію `supabase/migrations/20261126123506_policy_fixes.sql` (`[код у коміті 513e82d]`). Після `npx supabase db push` лінтер видає `0 errors, 24 warnings`, а `npm test` — `18 passed`.

---

### [№ 05] AI Studio · Первинний запит · Крок 16 (Написання `README.md` з нуля)
**Користувач:**
Контекст: навчальний проєкт «GoiCoins Skin Simulator» (Next.js `16.3.6`, React `19.2.8`, TypeScript, Supabase, Vitest `3`, ESLint `9`, Vercel, GitHub Actions, Node.js `v24`, без Docker і без локальної БД).
Вхідні дані:
- Змінні середовища з `.env.example`: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `TEST_USER_A_EMAIL`, `TEST_USER_B_EMAIL`, `TEST_USER_PASSWORD`, `GEMINI_API_KEY`, `GEMINI_MODEL`.
- Міграції в `supabase/migrations/`: 6 міграцій (`create_schema`, `add_skins_lore`, `access_by_user`, `add_realtime_upgrades`, `ai_guard`, `policy_fixes`).
- Скрипти `package.json`: `dev`, `build`, `start`, `lint`, `test`.
- Ручні кроки: вимкнути `Confirm email`, створити 2 тестових користувачів у Supabase Auth, налаштувати Vercel і 5 секретів Actions.
Завдання: склади `README.md` українською за 12 пунктами контрольного списку у форматі Markdown із таблицею змінних без жодних значень ключів, паролів або пошт, і тільки з командами проєкту.

**AI Studio:**
Підготовлено проєкт `README.md` із 12 розділів: опис, стек, акаунти, запуск Codespace, таблиця 8 змінних середовища, шаблон `.env.example`, накатування міграцій через `npx supabase db push`, створення тестових акаунтів, запуск `npm test`, старт `npm run dev`, налаштування Vercel та опис CI/CD-конвеєра й правила `main-protection`.

---

### [№ 06] AI Studio · Уточнення · Крок 16 (Усунення неточних команд і уточнення під середовище)
**Користувач:**
Перевір `README.md` проти контрольного списку: прибери будь-які згадки про альтернативні локальні команди чи зайві прапори CLI, які не використовуються в курсі, залиш винятково послідовність під Codespaces, хмарний Supabase (`Confirm email` вимкнено, кошики Storage не використовуються) і Vercel, та чітко вкажи очікуваний результат `18 passed` для `npm test`.

**AI Studio:**
Оновлено `README.md` без локального встановлення БД чи сторонніх команд; звірено кожну команду зі скриптами `package.json` та інструкцією `.env.example` (оформлено в PR #3 `pr7-readme`, коміт `a355cfb` → злито `d1bdb6d`; після перевірки кроку 17 також уточнено базовий URL без `/rest/v1` та без кутових дужок у PR #4 `pr7-readme-fix`).
