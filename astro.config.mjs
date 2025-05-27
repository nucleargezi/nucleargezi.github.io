// @ts-check
import { defineConfig, envField } from "astro/config";
import sitemap from "@astrojs/sitemap";
import { typst } from "astro-typst";
import { loadEnv } from "vite";

// Please check `defineConfig/env` in astro.config.mjs for schema
const e = loadEnv(process.env.NODE_ENV || "", process.cwd(), "");
const { SITE, URL_BASE } = e;

const EnvStr = (optional = false) =>
  envField.string({ context: "client", access: "public", optional });

export default defineConfig({
  site: SITE,
  base: URL_BASE,

  env: {
    schema: {
      SITE_TITLE: EnvStr(),
      SITE_INDEX_TITLE: EnvStr(),
      SITE_DESCRIPTION: EnvStr(),

      SITE: EnvStr(),
      URL_BASE: EnvStr(true),

      // # Please remove them if you don't like to use backend.
      // `;` separated list of backend addresses
      BACKEND_ADDR: EnvStr(),
      BAIDU_VERIFICATION_CODE: EnvStr(),
    },
  },

  integrations: [
    sitemap(),
    typst({
      // Always builds HTML files
      mode: {
        default: "html",
        detect: () => "html",
      },
    }),
  ],

  vite: {
    build: {
      assetsInlineLimit(filePath, content) {
        const KB = 1024;
        return content.length < (filePath.endsWith(".css") ? 100 * KB : 4 * KB);
      },
    },
    ssr: {
      external: ["@myriaddreamin/typst-ts-node-compiler"],
      noExternal: ["@fontsource-variable/inter"],
    },
  },
});
