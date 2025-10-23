import { glob } from "astro/loaders";
import { defineCollection, z } from "astro:content";

const nullToUndefined = <T>(value: T | null) => value ?? undefined;
const coerceStringOpt = () => z.string().nullish().transform(nullToUndefined);

const blog = defineCollection({
  // Load Typst files in the `content/article/` directory.
  loader: glob({ base: "./content/article", pattern: "*.typ" }),
  // Type-check frontmatter using a schema
  schema: z.object({
    title: z.string(),
    lang: coerceStringOpt(),
    region: coerceStringOpt(),
    author: z.string().optional(),
    description: z.any().optional(),
    date: z.coerce.date(),
    tags: z.array(z.string()).optional(),
  }),
});

const archive = defineCollection({
  // Load Typst files in the `content/article/` directory.
  loader: glob({ base: "./content/archive", pattern: "**/*.typ" }),
  // Type-check frontmatter using a schema
  schema: z.object({
    title: z.string(),
    author: z.string().optional(),
    description: z.any().optional(),
    date: z.coerce.date(),
    indices: z.array(z.string()).optional(),
    tags: z.array(z.string()).optional(),
  }),
});

export const collections = {
  blog,
  archive,
};
