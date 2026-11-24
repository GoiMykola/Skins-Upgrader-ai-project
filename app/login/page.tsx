"use client";

import { Suspense, useEffect } from "react";
import { AuthModal } from "@/components/auth-modal";
import { useRouter, useSearchParams } from "next/navigation";
import { getCurrentUser } from "@/lib/auth-storage";

function LoginContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const next = searchParams.get("next") || "/inventory";

  useEffect(() => {
    const user = getCurrentUser();
    if (user) {
      router.push(next);
    }
  }, [router, next]);

  return (
    <div className="min-h-[85vh] flex items-center justify-center p-4">
      <AuthModal
        isOpen={true}
        initialTab="login"
        onClose={() => router.push("/")}
        onSuccess={() => router.push(next)}
      />
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-[80vh] flex items-center justify-center text-emerald-400">
          Завантаження...
        </div>
      }
    >
      <LoginContent />
    </Suspense>
  );
}
