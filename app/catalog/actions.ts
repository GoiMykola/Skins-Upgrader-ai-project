"use server";
import type { ActionResult } from "@/lib/action-result";

export async function addSkinAction(_prev: ActionResult | null, _formData: FormData): Promise<ActionResult> {
  return { status: 0, message: "Дія ще не реалізована" };
}

export async function deleteSkinAction(_prev: ActionResult | null, _formData: FormData): Promise<ActionResult> {
  return { status: 0, message: "Дія ще не реалізована" };
}
