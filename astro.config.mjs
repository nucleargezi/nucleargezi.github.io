// @ts-check
import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";
import { typst } from "astro-typst";
import { URL_BASE } from "./config.json";

// https://astro.build/config
export default defineConfig({
  // Deploys to GitHub Pages
  site: "https://myriad-dreamin.github.io",
  base: URL_BASE,

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
});
