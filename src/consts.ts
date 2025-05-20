// Place any global data in this file.
// You can import this data from anywhere in your site by using the `import` keyword.

import * as config from "../config.json";
import INFO from "../content/snapshot/article-clicks.json";
import COMMENTS from "../content/snapshot/article-comments.json";

export const kEnableClick = true;
export const kEnableComment = true;

export const kSiteTitle = config.SITE_TITLE;
export const kSiteDescription = config.SITE_DESCRIPTION;
export const kUrlBase = config.URL_BASE;

// const BACKEND_ADDR = "http://localhost:13333";
const BACKEND_ADDR = "https://glittery-valkyrie-8fbf14.netlify.app/api";

export const kClickServers = [BACKEND_ADDR];
export const kCommentServers = BACKEND_ADDR;
export const kClickInfo = INFO;

type Comment = (typeof COMMENTS)[number];
export const kCommentInfo = new Map<string, Comment[]>();
for (const comment of COMMENTS) {
  const { articleId } = comment;
  if (!kCommentInfo.has(articleId)) {
    kCommentInfo.set(articleId, []);
  }
  kCommentInfo.get(articleId)?.push(comment);
}
