import { beforeEach, vi } from "vitest";
import { signInAs } from "./helpers/users";

vi.mock("next/cache", () => ({
  revalidatePath: vi.fn(),
  revalidateTag: vi.fn(),
}));

beforeEach(async () => {
  await signInAs("A");
});
