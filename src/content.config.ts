import { glob } from "astro/loaders";
import { defineCollection, z } from "astro:content";

const blog = defineCollection({
  loader: glob({ base: "./content/article", pattern: "*.typ" }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    tags: z.array(z.string()).optional(),
    description: z.any().optional(),
    lang: z.string().optional(),
    region: z.string().optional(),
  }),
});

export const collections = { blog };
