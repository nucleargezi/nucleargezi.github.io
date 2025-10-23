import { execSync } from "child_process";
import { loadEnv } from "vite";
import { writeFileSync } from "fs";

/**
 * Please check `defineConfig/env` in astro.config.mjs for schema
 *
 * @type {ClientEnv}
 */
const e = loadEnv(process.env.NODE_ENV || "", process.cwd(), "");

const firstBackendUrl = (e.BACKEND_ADDR || "").split(";")[0].trim();
if (!firstBackendUrl) {
  console.warn(
    "No backend address provided in .env. Creating empty snapshot files."
  );
  writeFileSync("content/snapshot/article-stats.json", "[]", "utf-8");
  writeFileSync("content/snapshot/article-comments.json", "[]", "utf-8");
  process.exit(0);
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
    const result = execSync(`curl -s -w "\n%{http_code}" ${url}`, {
      encoding: "utf-8",
    });
    
    const lines = result.trim().split("\n");
    const httpCode = lines[lines.length - 1];
    const content = lines.slice(0, -1).join("\n");
    
    // Check if HTTP request was successful
    if (httpCode !== "200") {
      console.warn(`HTTP ${httpCode} received from ${url}, using empty array as fallback`);
      writeFileSync(dest, "[]", "utf-8");
      return false;
    }
    
    // Validate JSON
    try {
      JSON.parse(content);
      writeFileSync(dest, content, "utf-8");
      console.log(`Data pulled successfully to ${dest}`);
      return true;
    } catch (jsonError) {
      console.warn(`Invalid JSON received from ${url}, using empty array as fallback`);
      writeFileSync(dest, "[]", "utf-8");
      return false;
    }
  } catch (error) {
    console.error(`Failed to pull data from ${url}:`, error);
    // Create empty JSON array as fallback
    try {
      writeFileSync(dest, "[]", "utf-8");
    } catch (e) {
      console.error(`Failed to create fallback file ${dest}:`, e);
    }
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
