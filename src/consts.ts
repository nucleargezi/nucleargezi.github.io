// Place any global data in this file.
// You can import this data from anywhere in your site by using the `import` keyword.

import * as config from "../config.json";
import CLICKS from "../content/snapshot/article-clicks.json";
import COMMENTS from "../content/snapshot/article-comments.json";

type Comment = (typeof COMMENTS)[number];

/**
 * Whether to enable click tracking.
 */
export const kEnableClick = true;
/**
 * Whether to enable comment posting and viewing.
 */
export const kEnableComment = true;
/**
 * Whether to enable backend, required by click and comment feature.
 */
export const kEnableBackend = true;

/**
 * The title of the website.
 */
export const kSiteTitle = config.SITE_TITLE;
/**
 * The title of the website, used in the index page.
 */
export const kSiteIndexTitle = config.SITE_INDEX_TITLE;
/**
 * The description of the website.
 */
export const kSiteDescription = config.SITE_DESCRIPTION;
/**
 * The URL base of the website.
 * - For a GitHub page `https://username.github.io/repo`, the URL base is `/repo/`.
 * - For a netlify page, the URL base is `/`.
 */
export const kUrlBase = config.URL_BASE.replace(/\/$/, "");

/**
 * The click info obtained from the backend.
 */
export const kClickInfo = CLICKS;
/**
 * The comment info obtained from the backend.
 */
export const kCommentInfo = (() => {
  const kCommentInfo = new Map<string, Comment[]>();
  for (const comment of COMMENTS) {
    const { articleId } = comment;
    if (!kCommentInfo.has(articleId)) {
      kCommentInfo.set(articleId, []);
    }
    kCommentInfo.get(articleId)?.push(comment);
  }
  return kCommentInfo;
})();
/**
 * A candidate list of servers to cover people in different regions.
 */
export const kServers = (() => {
  // const BACKEND_ADDR = "http://localhost:13333";
  const BACKEND_ADDR = "https://glittery-valkyrie-8fbf14.netlify.app/api";

  const kServers = [BACKEND_ADDR];

  if (kEnableBackend && kServers.length === 0) {
    throw new Error("kServers is empty, please set kServers in consts.ts");
  }

  return kServers;
})();
