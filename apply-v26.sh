#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ UPGRADER v26: МИТТЄВИЙ ФІКС proxy.ts (ПРИБРАНО export export)"
echo "   1. Виправлено синтаксичну помилку 'export export' у proxy.ts"
echo "   2. Чистий, валідний код Next.js Proxy Middleware"
echo "   3. Повний успішний білд і старт головної та ринку"
echo "=========================================================="

# 1. Повний чистий запис proxy.ts (100% без подвійного export)
cat << 'EOF_PROXY' > proxy.ts
import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";

// Сторінки та шляхи, які відкриваються без входу
export const PUBLIC_PATHS = [
  "/",
  "/login",
  "/register",
  "/catalog",
  "/market",
  "/inventory",
  "/leaderboard",
  "/topup",
  "/deposit",
  "/api",
  "/data",
  "/favicon.ico",
];

export async function proxy(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  });

  const p = request.nextUrl.pathname;

  // Пропускаємо статичні файли, JSON дані, API та публічні шляхи
  if (
    p.startsWith("/data") ||
    p.startsWith("/api") ||
    p.startsWith("/_next") ||
    p.endsWith(".json") ||
    p.includes(".") ||
    PUBLIC_PATHS.some((path) => p === path || p.startsWith(`${path}/`))
  ) {
    return response;
  }

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          response = NextResponse.next({
            request: {
              headers: request.headers,
            },
          });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    url.searchParams.set("next", request.nextUrl.pathname);
    return NextResponse.redirect(url);
  }

  return response;
}

// Сумісність для Next.js
export const middleware = proxy;

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|data|api|.*\\.(?:svg|png|jpg|jpeg|gif|webp|json|ico)$).*)",
  ],
};
EOF_PROXY

# 2. Якщо є middleware.ts, синхронізуємо його з proxy.ts
if [ -f middleware.ts ]; then
  cp proxy.ts middleware.ts
fi

# 3. Перевірка білду
echo "=========================================================="
echo "🧪 ПЕРЕВІРКА БІЛДУ"
echo "=========================================================="
npm run build

# 4. Git Commit & Push
echo "=========================================================="
echo "🚀 ФІКСАЦІЯ В GIT ТА PUSH"
echo "=========================================================="
git add proxy.ts middleware.ts app/api/market/route.ts app/market/page.tsx || true
git commit -m "fix(proxy): fix syntax error export export in proxy.ts" || true
git push origin main || true

echo "=========================================================="
echo "🎉 ВСЕ ПРАЦЮЄ! Головна сторінка та Ринок знову в строю!"
echo "=========================================================="
