# Копія діалогу з ШІ (Google AI Studio / GitHub Copilot)
## Практична робота № 4: Модель даних під інтерфейс
### Проєкт: GoiCoins Skin Simulator
### Виконавець: Штанько Микола

---

### [№ 01] Google AI Studio
Запит схеми даних PostgreSQL під потреби 5 екранів проєкту. Створено 5 таблиць, виділено 8 надлишкових полів для видалення.

### [№ 02] Google AI Studio
Запит SQL першої міграції 20261122204945_create_schema.sql з RLS-політиками pr4_temp_all та роздачею прав grant на 5 таблиць.

### [№ 03] Google AI Studio
Запит другої міграції 20261122212345_add_skins_lore.sql для додавання поля lore_description без втрати наявних даних (NULL).

### [№ 04] GitHub Copilot Chat (Codespaces)
Створення заглушок операцій з базою у lib/data/db/skins.ts. Коміт: 2539419.

### [№ 05] GitHub Copilot Chat (Codespaces)
Генерація 3 обов'язкових тестів до реальної бази Supabase у tests/db-skins.test.ts. Червоний стан: 3 failed, 5 passed. Коміт: d6bfcc0.

### [№ 06] GitHub Copilot Chat (Codespaces)
Реалізація CRUD-запитів через db() до таблиці skins. Усі тести стали зеленими: 8 passed. Коміти: c86f77f та 97af402.
