// Place any global data in this file.
// You can import this data from anywhere in your site by using the `import` keyword.

import * as config from "../config.json";
import INFO from "../content/snapshot/article-clicks.json";
import COMMENTS from "../content/snapshot/article-comments.json";

export const ENABLE_CLICK = true;
export const ENABLE_COMMENT = true;

export const SITE_TITLE = config.SITE_TITLE;
export const SITE_DESCRIPTION = config.SITE_DESCRIPTION;
export const URL_BASE = config.URL_BASE;

// const BACKEND_ADDR = "http://localhost:13333";
const BACKEND_ADDR = "https://glittery-valkyrie-8fbf14.netlify.app/api";
export const CLICK_SERVERS = [BACKEND_ADDR];
export const COMMENT_SERVER = BACKEND_ADDR;
export const CLICK_INFO = INFO;

type Comment = (typeof COMMENTS)[number];
export const COMMENT_INFO = new Map<string, Comment[]>();
for (const comment of COMMENTS) {
  const { articleId } = comment;
  if (!COMMENT_INFO.has(articleId)) {
    COMMENT_INFO.set(articleId, []);
  }
  COMMENT_INFO.get(articleId)?.push(comment);
}
