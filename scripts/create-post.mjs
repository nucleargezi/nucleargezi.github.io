import { readFile, writeFile } from "fs/promises";
import { existsSync } from "fs";
import { execSync } from "child_process";
import { join } from "path";

const id = process.argv[2];
if (!id) {
  throw new Error("No ID provided. Usage: node create.mjs <id>");
}

async function main() {
  const root = join(import.meta.dirname, "../");

  const dest = join(root, `content/article/${id}.typ`);
  if (existsSync(dest)) {
    console.error(
      `Post already exists at ${dest}. Please choose a different ID.`
    );
    process.exit(1);
  }

  const src = join(root, "typ/templates/blog-post.typ");

  const content = (await readFile(src, "utf-8")).replaceAll(
    '"1970-01-01"',
    JSON.stringify(toISOStringWithTimezone(new Date()))
  );

  await writeFile(dest, content, "utf-8");
  console.log(`Created new post at ${dest}`);

  if (process.env.TERM_PROGRAM === "vscode") {
    execSync(`code ${dest}`, {
      stdio: "inherit",
      cwd: root,
    });
  }
}

// Pad a number to 2 digits
const pad = (n) => `${Math.floor(Math.abs(n))}`.padStart(2, "0");
// Get timezone offset in ISO format (+hh:mm or -hh:mm)
const getTimezoneOffset = (date) => {
  const tzOffset = -date.getTimezoneOffset();
  const diff = tzOffset >= 0 ? "+" : "-";
  return diff + pad(tzOffset / 60) + ":" + pad(tzOffset % 60);
};

/**
 * Returns the current date in ISO format with timezone offset.
 * The timezone offset is calculated based on the local timezone.
 *
 * @param {Date} date - The date to format.
 * @returns {string} - The ISO date string with timezone offset.
 */
const toISOStringWithTimezone = (date) => {
  const year = date.getFullYear(),
    month = pad(date.getMonth() + 1),
    day = pad(date.getDate()),
    hours = pad(date.getHours()),
    minutes = pad(date.getMinutes()),
    seconds = pad(date.getSeconds()),
    tz = getTimezoneOffset(date);
  return `${year}-${month}-${day}T${hours}:${minutes}:${seconds}${tz}`;
};

await main();
