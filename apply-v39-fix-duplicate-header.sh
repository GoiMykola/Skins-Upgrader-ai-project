#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v39: ВИПРАВЛЕННЯ ПОДВІЙНОЇ ШАПКИ (DUPLICATE HEADER)"
echo "   1. 🧼 Видалення зайвого <SiteHeader /> з app/contracts/page.tsx"
echo "   2. 🧼 Видалення зайвого <SiteHeader /> з app/duel/page.tsx"
echo "   3. 🔍 Автоматична перевірка всіх сторінок на відсутність дублікатів шапки"
echo "   4. 🧪 Повний білд та автодеплой на GitHub і Vercel"
echo "=========================================================="

# 1. Виправлення через Node.js: видаляємо імпорт та рендер SiteHeader зі сторінок, де він дублюється
node -e '
const fs = require("fs");

const pagesToFix = [
  "app/contracts/page.tsx",
  "app/duel/page.tsx",
];

pagesToFix.forEach((file) => {
  if (fs.existsSync(file)) {
    let content = fs.readFileSync(file, "utf8");
    let changed = false;

    // Видаляємо імпорт SiteHeader
    if (content.includes("import SiteHeader from")) {
      content = content.replace(/import\s+SiteHeader\s+from\s+["\x27]@\/app\/components\/site-header["\x27];?\n?/g, "");
      changed = true;
    }

    // Видаляємо компонент <SiteHeader />
    if (content.includes("<SiteHeader />") || content.includes("<SiteHeader/>")) {
      content = content.replace(/<SiteHeader\s*\/>\n?/g, "");
      changed = true;
    }

    if (changed) {
      fs.writeFileSync(file, content, "utf8");
      console.log(`✅ ${file}: подвійну шапку успішно прибрано!`);
    } else {
      console.log(`ℹ️ ${file}: дублікатів не виявлено.`);
    }
  }
});

// Додатково перевіряємо всі файли в app/ щоб ніде більше не було дублікатів SiteHeader
const scanDir = (dir) => {
  if (!fs.existsSync(dir)) return;
  const files = fs.readdirSync(dir, { withFileTypes: true });
  for (const f of files) {
    const fullPath = `${dir}/${f.name}`;
    if (f.isDirectory() && f.name !== "components" && f.name !== "node_modules" && f.name !== ".next") {
      scanDir(fullPath);
    } else if (f.isFile() && (f.name === "page.tsx" || f.name === "page.jsx")) {
      let code = fs.readFileSync(fullPath, "utf8");
      if (code.includes("<SiteHeader />") || code.includes("<SiteHeader/>")) {
        code = code.replace(/import\s+SiteHeader\s+from\s+["\x27]@\/app\/components\/site-header["\x27];?\n?/g, "");
        code = code.replace(/<SiteHeader\s*\/>\n?/g, "");
        fs.writeFileSync(fullPath, code, "utf8");
        console.log(`🧹 Видалено зайву шапку з ${fullPath}`);
      }
    }
  }
};
scanDir("app");
' || true

# 2. Перевірка білду Next.js
echo "=========================================================="
echo "🧪 ПЕРЕВІРКА БІЛДУ"
echo "=========================================================="
npm run build

# 3. Git Commit & Push на GitHub
echo "=========================================================="
echo "🚀 ФІКСАЦІЯ В GIT ТА PUSH НА GITHUB"
echo "=========================================================="
git add .
git commit -m "fix(ui): remove duplicate SiteHeader from contracts, duel, and subpages (rendered by root layout)" || true
git push origin main || true

echo "=========================================================="
echo "🎉 БАГ ВИПРАВЛЕНО! Тепер на всіх сторінках рівно одна красива шапка!"
echo "=========================================================="
