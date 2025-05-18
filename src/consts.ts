// Place any global data in this file.
// You can import this data from anywhere in your site by using the `import` keyword.

import * as config from "../config.json";
import INFO from "../assets/article-clicks.json";

export const SITE_TITLE = config.SITE_TITLE;
export const SITE_DESCRIPTION = config.SITE_DESCRIPTION;
export const URL_BASE = config.URL_BASE;

export const CLICK_SERVERS = [];
export const ENABLE_CLICK = false;
export const CLICK_INFO = INFO;
