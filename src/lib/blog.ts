import type { CollectionEntry } from "astro:content";

export type BlogPost = CollectionEntry<"blog">;
export interface TocHeading {
  id: string;
  level: number;
  title: string;
}

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

function normalizeTocTitle(rawTitle: string) {
  return rawTitle
    .replace(/#link\(\s*"[^"]*"\s*,\s*"([^"]*)"\s*\)/g, "$1")
    .replace(/#link\(\s*"[^"]*"\s*,\s*\[([^\]]*)\]\s*\)/g, "$1")
    .replace(/#\w+\[([^\]]+)\]/g, "$1")
    .replace(/#\w+\(\s*"([^"]+)"\s*\)/g, "$1")
    .replace(/\s+/g, " ")
    .trim();
}

export function extractTypstToc(body?: string): TocHeading[] {
  if (!body) {
    return [];
  }

  const headings: TocHeading[] = [];
  let inFence = false;

  for (const rawLine of body.split(/\r?\n/)) {
    const line = rawLine.trimEnd();
    const trimmed = line.trim();

    if (trimmed.startsWith("```")) {
      inFence = !inFence;
      continue;
    }

    if (inFence) {
      continue;
    }

    const match = line.match(/^(={1,6})\s+(.+?)\s*$/);
    if (!match) {
      continue;
    }

    const [, marks, rawTitle] = match;
    const title = normalizeTocTitle(rawTitle);
    if (!title) {
      continue;
    }

    headings.push({
      id: `heading-${headings.length + 1}`,
      level: marks.length,
      title,
    });
  }

  return headings;
}
