"use client";

import { AuthModal } from "@/components/auth-modal";
import { useRouter } from "next/navigation";

export default function RegisterPage() {
  const router = useRouter();
  return (
    <div className="min-h-[80vh] flex items-center justify-center p-4">
      <AuthModal
        isOpen={true}
        initialTab="register"
        onClose={() => router.push("/")}
        onSuccess={() => router.push("/inventory")}
      />
    </div>
  );
}
