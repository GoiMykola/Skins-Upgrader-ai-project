"use server";

import { revalidatePath } from "next/cache";
import { isAccessDenied, type ActionResult } from "@/lib/action-result";
import { currentUserId } from "@/lib/auth";
import { createSkin, deleteSkin, getSkin } from "@/lib/data/db/skins";
import { checkSkin } from "@/lib/validation/skins";

export async function addSkinAction(
  _previous: ActionResult | null,
  formData: FormData,
): Promise<ActionResult> {
  if (!(await currentUserId())) {
    return { status: 401, message: "Увійдіть, щоб створити скін." };
  }
  const checked = checkSkin(formData);
  if (!checked.ok) {
    return { status: 400, message: "Перевірте поля форми.", fieldErrors: checked.fieldErrors };
  }
  try {
    const skin = await createSkin(checked.value);
    revalidatePath("/catalog");
    return { status: 201, id: skin.id, message: "Скін успішно створено." };
  } catch (error) {
    if (isAccessDenied(error)) {
      return { status: 403, message: "У вас немає прав на додавання скінів." };
    }
    throw error;
  }
}

export async function deleteSkinAction(
  _previous: ActionResult | null,
  formData: FormData,
): Promise<ActionResult> {
  if (!(await currentUserId())) {
    return { status: 401, message: "Увійдіть, щоб видалити скін." };
  }
  const id = String(formData.get("id") ?? "");
  if (!/^[0-9a-f-]{36}$/i.test(id)) {
    return { status: 400, message: "Невірний ідентифікатор скіна." };
  }
  const skin = await getSkin(id);
  if (!skin) {
    return { status: 404, message: "Скін не знайдено або у вас немає прав на його видалення." };
  }
  try {
    await deleteSkin(id);
    revalidatePath("/catalog");
    return { status: 200, message: "Скін видалено." };
  } catch (error) {
    if (isAccessDenied(error)) {
      return { status: 403, message: "У вас немає прав на видалення." };
    }
    throw error;
  }
}
