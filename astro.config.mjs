import { defineConfig } from "astro/config";
import { typst } from "astro-typst";

export default defineConfig({
  site: "https://nucleargezi.github.io/next-blog",
  integrations: [
    typst({
      mode: {
        default: "html",
        detect: () => "html",
      },
    }),
  ],
});
