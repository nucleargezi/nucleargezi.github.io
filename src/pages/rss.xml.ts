import rss, { type RSSFeedItem } from "@astrojs/rss";
import { getCollection } from "astro:content";
import type { CollectionEntry } from "astro:content";
import type { APIContext } from "astro";
import { kUrlBase, kSiteTitle, kSiteDescription } from "$consts";

type Item = CollectionEntry<"blog" | "archive">;

export async function GET(context: APIContext) {
  if (!context.site) {
    throw new Error("No site URL found");
  }

  const toRssFeed =
    (sub: string) =>
    (item: Item): RSSFeedItem => ({
      title: item.data.title,
      description: item.data.description,
      pubDate: item.data.date,
      categories: item.data.tags,
      link: `${kUrlBase}/${sub}/${item.id}/`,
    });

  const posts = (await getCollection("blog")).map(toRssFeed("article"));
  const archives = (await getCollection("archive")).map(toRssFeed("archive"));
  return rss({
    title: kSiteTitle,
    description: kSiteDescription,
    site: context.site,
    items: [...posts, ...archives],
  });
}
