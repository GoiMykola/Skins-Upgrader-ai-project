import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";

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
  let response = NextResponse.next({ request: { headers: request.headers } });
  const p = request.nextUrl.pathname;

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

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || "https://dummy-cs2goi.supabase.co";
  const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy";

  const supabase = createServerClient(supabaseUrl, supabaseKey, {
    cookies: {
      getAll() { return request.cookies.getAll(); },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request: { headers: request.headers } });
        cookiesToSet.forEach(({ name, value, options }) => response.cookies.set(name, value, options));
      },
    },
  });

  await supabase.auth.getUser();
  return response;
}
