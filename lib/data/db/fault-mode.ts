export type FaultMode = "none" | "slow" | "down";
export const FAULT_MODE: FaultMode = "none";
export const faultFetch: typeof fetch = async (input, init) => {
  const mode = (process.env.VITEST ? "none" : FAULT_MODE) as FaultMode;
  if (mode === "slow") await new Promise((resolve) => setTimeout(resolve, 5000));
  if (mode === "down") throw new TypeError("fetch failed: база недоступна (режим збою down)");
  return fetch(input, init);
};
