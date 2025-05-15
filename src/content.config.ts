import { glob } from "astro/loaders";
import { defineCollection, z } from "astro:content";

const blog = defineCollection({
  // Load Typst files in the `content/article/` directory.
  loader: glob({ base: "./content/article", pattern: "**/*.typ" }),
  // Type-check frontmatter using a schema
  schema: z.object({
    title: z.string(),
    author: z.string().optional(),
    desc: z.any().optional(),
    date: z.coerce.date(),
    // Transform string to Date object
    updatedDate: z.coerce.date().optional(),
  }),
});

export const collections = { blog };
