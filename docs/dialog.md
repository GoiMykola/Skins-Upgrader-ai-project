# Копія діалогу з ШІ (Google AI Studio / GitHub Copilot)
## Практична робота № 3: Структура інтерфейсу застосунку
### Проєкт: GoiCoins Skin Simulator
### Виконавець: Штанько Микола

---

### [№ 01] Google AI Studio
Запит мінімального набору екранів для покриття специфікації MVP (5 екранів у MVP: Головна, Каталог, Інвентар, Лідерборд, Профіль).

### [№ 02] Google AI Studio
Пошук пропущених крайових станів (Live Drop при відсутності активності, порожній лідерборд, retry при помилках).

### [№ 03] Google AI Studio
Аудит ізоляції шару даних: перевірка коду app/ на відсутність прямих імпортів макетів чи mock-mode. Порушень не виявлено.

### [№ 04] GitHub Copilot Chat (Codespaces)
Створення асинхронних заглушок і типів у каталозі lib/data/ (skins, inventory, upgrades, leaderboard). Коміт: 928cbed.

### [№ 05] GitHub Copilot Chat (Codespaces)
Створення 4 тестів на критерії приймання в tests/upgrader.test.ts. Червоний прогін: 4 failed, 1 passed. Коміт: 946c25c.

### [№ 06] GitHub Copilot Chat (Codespaces)
Створення mock-mode.ts, додавання loading.tsx та error.tsx для всіх маршрутів, підключення макетів. Тести зелені: 5 passed. Коміти: a119a2e та 5fe93da.
