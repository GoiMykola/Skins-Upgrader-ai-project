import { db } from "@/lib/data/db/client";

export async function currentUserId(): Promise<string | null> {
  const { data, error } = await db().auth.getUser();
  if (error || !data.user) return null;
  return data.user.id;
}
