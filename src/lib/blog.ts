import type { CollectionEntry } from "astro:content";

export type BlogPost = CollectionEntry<"blog">;

export function sortPosts(posts: BlogPost[]) {
  return [...posts].sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());
}

export function formatDate(date: Date) {
  return date.toISOString().slice(0, 10);
}

function extractText(value: unknown): string {
  if (typeof value === "string") {
    return value;
  }

  if (Array.isArray(value)) {
    return value.map(extractText).join("");
  }

  if (value && typeof value === "object") {
    if ("text" in value && typeof value.text === "string") {
      return value.text;
    }

    if ("children" in value && Array.isArray(value.children)) {
      return value.children.map(extractText).join("");
    }
  }

  return "";
}

export function normalizeDescription(value: unknown) {
  const text = extractText(value).replace(/\s+/g, " ").trim();
  return text.length > 0 ? text : undefined;
}

export function toHtmlLang(lang?: string, region?: string) {
  if (!lang) {
    return "zh-CN";
  }

  return region ? `${lang}-${region.toUpperCase()}` : lang;
}
