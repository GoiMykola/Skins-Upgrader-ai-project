"use client";

import { AuthModal } from "@/components/auth-modal";
import { useRouter } from "next/navigation";

export default function LoginPage() {
  const router = useRouter();
  return (
    <div className="min-h-[80vh] flex items-center justify-center p-4">
      <AuthModal
        isOpen={true}
        initialTab="login"
        onClose={() => router.push("/")}
        onSuccess={() => router.push("/inventory")}
      />
    </div>
  );
}
