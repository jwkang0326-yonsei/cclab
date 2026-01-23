import type { Config } from "@react-router/dev/config";

import { sentryOnBuildEnd } from "@sentry/react-router";
import { vercelPreset } from "@vercel/react-router/vite";
import { readdir } from "node:fs/promises";
import path from "node:path";

declare module "react-router" {
  interface Future {
    unstable_middleware: true;
  }
}

export default {
  ssr: true,
  async prerender() {
    return [
      "/sitemap.xml",
      "/robots.txt",
    ];
  },
  presets: [
    ...(process.env.VERCEL || process.env.VERCEL_ENV === "production" ? [vercelPreset()] : []),
  ],
  buildEnd: async ({ viteConfig, reactRouterConfig, buildManifest }) => {
    if (
      process.env.SENTRY_ORG &&
      process.env.SENTRY_PROJECT &&
      process.env.SENTRY_AUTH_TOKEN
    ) {
      await sentryOnBuildEnd({
        viteConfig,
        reactRouterConfig,
        buildManifest,
      });
    }
  },
} satisfies Config;
