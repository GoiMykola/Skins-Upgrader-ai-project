import type { ActionResult } from "@/lib/action-result";

export type Submitted = Omit<ActionResult, "status"> & { status: ActionResult["status"] | 0 };

export async function submit(action: unknown, fields: Record<string, string>): Promise<Submitted> {
  const formData = new FormData();
  for (const [name, value] of Object.entries(fields)) formData.set(name, value);
  try {
    const call = action as (previous: null, formData: FormData) => Promise<ActionResult | undefined>;
    const result = await call(null, formData);
    return result ?? { status: 0, message: "Дія нічого не повернула" };
  } catch (error) {
    console.error("Серверна дія завершилася винятком:", error);
    return { status: 0, message: `Виняток: ${error instanceof Error ? error.message : String(error)}` };
  }
}
