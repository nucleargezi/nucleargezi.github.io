import { defineConfig } from "astro/config";
import { typst } from "astro-typst";

export default defineConfig({
  integrations: [
    typst({
      mode: {
        default: "html",
        detect: () => "html",
      },
    }),
  ],
});