import { defineConfig } from "vitest/config";
import { loadEnv } from "vite";
import { fileURLToPath } from "node:url";

export default defineConfig(({ mode }) => ({
  resolve: {
    alias: { "@": fileURLToPath(new URL("./", import.meta.url)) },
  },
  test: {
    env: loadEnv(mode, process.cwd(), ""),
    setupFiles: ["./tests/setup.ts"],
    testTimeout: 15000,
  },
}));
