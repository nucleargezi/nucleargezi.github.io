import { execSync } from "child_process";
import { readFile } from "fs/promises";
import { join } from "path";

const config = JSON.parse(
  await readFile(join(import.meta.dirname, "../config.json"), "utf-8")
);

const firstBackendUrl = config.BACKEND_ADDR[0];
if (!firstBackendUrl) {
  throw new Error(
    "No backend address provided in config.json. Either disable the data pull or provide valid addresses."
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
    console.log(`Data pulled successfully to ${dest}`);
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
