import rss from "@astrojs/rss";
import { getCollection } from "astro:content";
import { kUrlBase, kSiteTitle, kSiteDescription } from "$consts";

export async function GET(context) {
  const posts = await getCollection("blog");
  return rss({
    title: kSiteTitle,
    description: kSiteDescription,
    site: context.site,
    items: posts.map((post) => ({
      ...post.data,
      link: `${kUrlBase}/article/${post.id}/`,
    })),
  });
}
