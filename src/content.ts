import { getCollection, getEntry, type CollectionEntry } from "astro:content";
import { exec } from "child_process";

const now = new Date();
interface Publishable {
  data: {
    date: Date;
  };
}
export const byDate = (a: Publishable, b: Publishable) =>
  b.data.date.valueOf() - a.data.date.valueOf();
export const published = (it: Publishable) =>
  it.data.date.valueOf() <= now.valueOf();

export const blogPosts = (await getCollection("blog")).sort(byDate);
export const archives = (await getCollection("archive")).sort(byDate);

export const publishedBlogPosts = blogPosts.filter(published);
export const publishedArchives = archives.filter(published);

const gitProperty = <T>(
  command: (entry: CollectionEntry<"blog">) => string,
  process: (stdout: string, entry: CollectionEntry<"blog">) => T
): ((id: string) => Promise<T>) => {
  const cache = new Map<string, T>();
  return async (id: string) => {
    if (cache.has(id)) {
      return cache.get(id)!;
    }

    const entry = await getEntry("blog", id);
    if (!entry) {
      throw new Error(`Post with id "${id}" not found.`);
    }
    const filepath = entry.filePath;
    if (!filepath) {
      throw new Error(`File path for post with id "${id}" is not available.`);
    }

    return new Promise<T>((resolve, reject) => {
      exec(command(entry), (error, stdout) => {
        if (error) {
          reject(error);
        } else {
          const result = process(stdout.trim(), entry);
          cache.set(id, result);
          resolve(result);
        }
      });
    });
  };
};

interface CommitItem {
  commit: string;
  date: Date;
}

export const postLastModified = gitProperty<CommitItem | undefined>(
  (entry) =>
    `git log -1 --follow --format="%H %ct" -- ${JSON.stringify(
      entry.filePath!
    )}`,
  (stdout) => {
    if (!stdout.trim()) {
      return undefined;
    }

    const [commit, date_] = stdout.split(" ");
    return { commit, date: new Date(parseInt(date_) * 1000) };
  }
);
