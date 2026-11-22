import type { NextConfig } from "next";

const codespaceOrigin = process.env.CODESPACE_NAME
  ? `${process.env.CODESPACE_NAME}-3000.app.github.dev`
  : undefined;

const nextConfig: NextConfig = {
  experimental: {
    serverActions: {
      allowedOrigins: [
        "*.app.github.dev",
        "*.github.dev",
        "localhost:3000",
        ...(codespaceOrigin ? [codespaceOrigin] : []),
      ],
    },
  },
};

export default nextConfig;
