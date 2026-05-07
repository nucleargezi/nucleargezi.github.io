import { defineConfig } from "astro/config";
import { typst } from "astro-typst";

export default defineConfig({
  // site: "https://nucleargezi.github.io/next-blog",
  site: "https://nucleargezi.github.io",
  // base: "/next-blog",
  integrations: [
    typst({
      target: "svg",
    }),
  ],
});
