import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

async function readRepoFile(relativePath: string) {
  return readFile(path.join(repoRoot, relativePath), "utf8");
}

test("library styles are split into documented section files", async () => {
  const libraryEntryCss = await readRepoFile("src/styles/library.css");
  const indexPage = await readRepoFile("src/pages/library/index.astro");

  const sectionFiles = [
    "src/styles/library/page.css",
    "src/styles/library/summary.css",
    "src/styles/library/tree.css",
    "src/styles/library/modal.css",
  ];

  for (const file of sectionFiles) {
    const fileText = await readRepoFile(file);

    assert.match(libraryEntryCss, new RegExp(`@import "\\./library/${path.basename(file)}";`));
    assert.match(fileText, /\/\*[\s\S]*?\*\//, `${file} should include CSS comments`);
  }

  assert.match(indexPage, /import "\.\.\/\.\.\/styles\/library\.css";/);
});
