# Схема даних від потреб екранів: GoiCoins Skin Simulator

## 1. Таблиці та поля

### Таблиця 1: `profiles`
Таблиця профілів гравців (відображається в шапці, інвентарі, лідерборді та на сторінці `/users/[id]`).
- `id` (uuid, primary key, default `gen_random_uuid()`): ідентифікатор користувача.
- `username` (text, not null, check `length(trim(username)) > 0`): нікнейм гравця.
- `balance_coins` (integer, not null, default 1000, check `balance_coins >= 0`): баланс віртуальних GoiCoins.
- `role` (text, not null, default `'player'`): роль користувача (`player` або `admin`).
- `created_at` (timestamptz, not null, default `now()`): дата приєднання до спільноти.

### Таблиця 2: `skins`
Каталог скінів для вибору та купівлі (відображається на `/catalog` та в слотах апгрейду на `/`).
- `id` (uuid, primary key, default `gen_random_uuid()`): ідентифікатор скіна.
- `name` (text, not null, check `length(trim(name)) > 0`): назва скіна (наприклад, "Неонова гонка").
- `weapon` (text, not null): тип зброї (AK-47, AWP, M4A4, Ніж-метелик).
- `category` (text, not null): категорія зброї.
- `rarity` (text, not null): рівень рідкісності.
- `price_coins` (integer, not null, check `price_coins > 0`): базова ціна в GoiCoins.
- `image_url` (text, not null): ідентифікатор або шлях до зображення.

### Таблиця 3: `user_inventory` (Таблиця зв'язку M:N)
Зв'язок «багато до багатьох» між `profiles` та `skins` (відображається на `/inventory` та у вітрині `/users/[id]`).
- `id` (uuid, primary key, default `gen_random_uuid()`): ідентифікатор екземпляра скіна.
- `user_id` (uuid, not null, references `public.profiles(id)` on delete cascade): власник предмета.
- `skin_id` (uuid, not null, references `public.skins(id)` on delete cascade): скін із каталогу.
- `status` (text, not null, default `'active'`): статус предмета (`active`, `upgraded`, `destroyed`).
- `acquired_at` (timestamptz, not null, default `now()`): час отримання.

### Таблиця 4: `upgrades`
Транзакції покращення предметів та жива стрічка дропів (відображається на `/`).
- `id` (uuid, primary key, default `gen_random_uuid()`): ідентифікатор спроби.
- `user_id` (uuid, not null, references `public.profiles(id)` on delete cascade): гравець.
- `input_skin_id` (uuid, not null, references `public.skins(id)` on delete cascade): використаний скін.
- `target_skin_id` (uuid, not null, references `public.skins(id)` on delete cascade): бажаний скін.
- `chance` (numeric(5,2), not null, check `chance > 0 and chance <= 100`): математичний шанс успіху.
- `is_success` (boolean, not null): результат спроби (`true` — виграв, `false` — спалив).
- `created_at` (timestamptz, not null, default `now()`): час апгрейду.

### Таблиця 5: `reports`
Скарги на користувацький контент (відображається у модальному вікні на `/users/[id]`).
- `id` (uuid, primary key, default `gen_random_uuid()`): ідентифікатор скарги.
- `author_id` (uuid, not null, references `public.profiles(id)` on delete cascade): хто поскаржився.
- `target_user_id` (uuid, not null, references `public.profiles(id)` on delete cascade): на кого скарга.
- `reason` (text, not null, check `length(trim(reason)) > 0`): причина репорту.
- `created_at` (timestamptz, not null, default `now()`): час подання скарги.

---

## 2. Зв'язки між таблицями

| Таблиця А | Таблиця Б | Тип зв'язку | Як зроблено | Чому саме такий |
|---|---|:---:|---|---|
| `profiles` | `skins` | **M:N** | Таблиця `user_inventory` з полями `user_id` та `skin_id` | Один користувач володіє багатьма скінами, і один тип скіна з каталогу може бути в інвентарях багатьох користувачів. |
| `profiles` | `upgrades` | 1:N | Поле `user_id` у таблиці `upgrades` | Один користувач може здійснювати багато спроб покращення скінів. |
| `profiles` | `reports` | 1:N | Поле `target_user_id` у таблиці `reports` | На один профіль користувача може бути подано кілька скарг різними гравцями. |

---

## 3. Відповідність «поле → екран» та видалені надлишкові поля

| Таблиця | Поле | Екран, на якому з'являється | Рішення | Причина |
|---|---|---|:---:|---|
| `profiles` | `username`, `balance_coins` | Шапка, `/inventory`, `/leaderboard`, `/users/[id]` | лишити | Відображаються в основному інтерфейсі |
| `profiles` | `email`, `phone_number` | жоден | **видалити** | Аутентифікація в ПР 4 не налаштовується, жоден екран не показує контакти |
| `skins` | `name`, `weapon`, `rarity`, `price_coins` | `/catalog`, `/`, `/inventory` | лишити | Основні характеристики скінів на вітрині |
| `skins` | `float_value`, `pattern_template` | жоден | **видалити** | Надлишкові числові параметри зносу, які не вимагаються MVP |
| `upgrades` | `chance`, `is_success` | `/` (модуль та стрічка Live Drop) | лишити | Необхідні для показу результату апгрейду |
| `upgrades` | `server_seed`, `nonce` | жоден | **видалити** | Криптографічні хеші генератора, які інтерфейс не показує |
| `reports` | `reason` | Модальне вікно скарги на `/users/[id]` | лишити | Текст скарги вводиться користувачем |
| `reports` | `admin_decision`, `resolved_at` | жоден | **видалити** | Панель адміна відкладена, рішення приймаються в панелі Supabase |
