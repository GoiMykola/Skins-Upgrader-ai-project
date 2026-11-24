#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v25: РОЗБЛОКУВАННЯ РИНКУ СКІНІВ (cs2-market.json)"
echo "   1. Пропуск /data та .json файлів у proxy.ts (Next.js Middleware)"
echo "   2. Додано резервний API-роут /api/market для 100% надійності"
echo "   3. Оновлено app/market/page.tsx з автоматичним відновленням"
echo "   4. Оновлено components/interactive-upgrader.tsx для вибору цілей"
echo "=========================================================="

mkdir -p app/api/market app/market components lib public/data

# 1. Повне виправлення proxy.ts / middleware.ts для файлів даних
cat << 'NODE_EOF' > update-proxy-market.js
const fs = require('fs');

const files = ['proxy.ts', 'middleware.ts', 'src/proxy.ts', 'src/middleware.ts'];
const newPaths = 'export const PUBLIC_PATHS = ["/", "/login", "/register", "/catalog", "/market", "/inventory", "/leaderboard", "/topup", "/deposit", "/api", "/data", "/favicon.ico"];';

files.forEach(file => {
  if (fs.existsSync(file)) {
    let content = fs.readFileSync(file, 'utf8');

    // 1. Оновлюємо PUBLIC_PATHS
    if (content.includes('PUBLIC_PATHS')) {
      content = content.replace(/export\s+const\s+PUBLIC_PATHS\s*=\s*\[[\s\S]*?\];/, newPaths);
      content = content.replace(/const\s+PUBLIC_PATHS\s*=\s*\[[\s\S]*?\];/, newPaths);
    } else {
      content = newPaths + '\n' + content;
    }

    // 2. Оновлюємо matcher, щоб не чіпати data та json
    if (content.includes('matcher:')) {
      content = content.replace(
        /matcher:\s*\[[\s\S]*?\]/g,
        'matcher: ["/((?!_next/static|_next/image|favicon.ico|data|api|.*\\\\.(?:svg|png|jpg|jpeg|gif|webp|json|ico)$).*)"]'
      );
    }

    // 3. Додаємо негайний пропуск /data та .json у функції middleware
    if (!content.includes('pathname.startsWith("/data")')) {
      if (content.includes('const { pathname } = request.nextUrl;')) {
        content = content.replace(
          'const { pathname } = request.nextUrl;',
          'const { pathname } = request.nextUrl;\n  if (pathname.startsWith("/data") || pathname.startsWith("/api") || pathname.endsWith(".json") || pathname.includes(".")) return response;'
        );
      } else if (content.includes('request.nextUrl.pathname')) {
        content = content.replace(
          /const\s*\{\s*data:\s*\{\s*user\s*\}\s*\}\s*=\s*await\s*supabase\.auth\.getUser\(\);/,
          'const p = request.nextUrl.pathname;\n  if (p.startsWith("/data") || p.startsWith("/api") || p.endsWith(".json") || p.includes(".")) return response;\n  const { data: { user } } = await supabase.auth.getUser();'
        );
      }
    }

    fs.writeFileSync(file, content, 'utf8');
    console.log('✅ Повністю налаштовано ' + file + ' для пропуску /data та .json');
  }
});
NODE_EOF

node update-proxy-market.js
rm -f update-proxy-market.js

# 2. Створення серверного API-роуту app/api/market/route.ts (гарантована видача JSON)
cat << 'EOF' > app/api/market/route.ts
import { NextResponse } from "next/server";
import fs from "fs";
import path from "path";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    const filePath = path.join(process.cwd(), "public", "data", "cs2-market.json");
    if (fs.existsSync(filePath)) {
      const data = fs.readFileSync(filePath, "utf8");
      return new NextResponse(data, {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Cache-Control": "public, max-age=3600, s-maxage=3600",
        },
      });
    }
    return NextResponse.json({ error: "cs2-market.json not found" }, { status: 404 });
  } catch (err: any) {
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}
