import { execSync } from "child_process";
import { loadEnv } from "vite";
import fs from "fs";

/**
 * Please check `defineConfig/env` in astro.config.mjs for schema
 *
 * @type {ClientEnv}
 */
const e = loadEnv(process.env.NODE_ENV || "", process.cwd(), "");

const firstBackendUrl = (e.BACKEND_ADDR || "").split(";")[0].trim();
if (!firstBackendUrl) {
  throw new Error(
    "No backend address provided in .env. Either disable the data pull or provide valid addresses."
  );
}

/**
 * Pulls data from the backend and saves it to the specified destination.
 *
 * @param {string} route - The route to pull data from.
 * @param {string} dest - The destination file to save the pulled data.
 */
const pullData = (route, dest) => {
  const url = new URL(
    route,
    firstBackendUrl + (route.endsWith("/") ? "" : "/")
  );
  try {
    console.log(`Pulling data from ${url}...`);
    execSync(`curl -s ${url} > ${dest}`, {
      stdio: "inherit",
    });
    
    // Format JSON file to make it more readable and compatible
    try {
      const data = JSON.parse(fs.readFileSync(dest, 'utf8'));
      fs.writeFileSync(dest, JSON.stringify(data, null, 2), 'utf8');
      console.log(`Data pulled and formatted successfully to ${dest}`);
    } catch (formatError) {
      console.warn(`Warning: Failed to format JSON at ${dest}:`, formatError.message);
      console.log(`Data pulled successfully to ${dest} (unformatted)`);
    }
    
    return true;
  } catch (error) {
    console.error(`Failed to pull data from ${url}:`, error);
  }

  return false;
};

let okay =
  pullData("snapshot/stats", "content/snapshot/article-stats.json") &&
  pullData("snapshot/comments", "content/snapshot/article-comments.json");

if (okay) {
  // git diff
  const result = execSync("git diff HEAD", {
    stdio: "pipe",
    cwd: "content/snapshot",
    encoding: "utf-8",
  });
  console.log("Git diff result:\n", result);
}
