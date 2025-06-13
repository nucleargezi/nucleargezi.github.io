import { blogPosts } from "$content";

export async function GET() {
  // only export specified fields
  const posts = blogPosts.map((post) => ({
    id: post.id,
    collection: post.collection,
    data: {
      title: post.data.title,
    },
  }));

  return Response.json(posts);
}
