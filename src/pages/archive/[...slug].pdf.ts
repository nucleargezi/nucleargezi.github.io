import type { APIContext } from "astro";
import { type CollectionEntry, getCollection } from "astro:content";

import { kEnablePrinting } from "$consts";
import { renderMonthlyPdf } from "$components/Typst";

export async function getStaticPaths() {
  if (!kEnablePrinting) {
    return [];
  }

  const monthly = await getCollection("monthly");
  return monthly.map((post) => ({
    params: { slug: post.id },
    props: post,
  }));
}
type Props = CollectionEntry<"blog">;

export async function GET({ params }: APIContext) {
  // props: Props
  return new Response(
    await renderMonthlyPdf(`content/monthly/${params.slug}.typ`)
  );
}
