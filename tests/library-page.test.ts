import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test, { before } from "node:test";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const libraryOutputPath = path.join(repoRoot, "dist", "library", "index.html");

let renderedLibraryPage = "";
let renderedLibraryCss = "";

before(async () => {
  await execFileAsync("pnpm", ["build"], { cwd: repoRoot });
  renderedLibraryPage = await readFile(libraryOutputPath, "utf8");
  const cssMatch = renderedLibraryPage.match(/href="(\/_astro\/[^"]+\.css)"/);

  assert.ok(cssMatch, "expected the built library page to reference an Astro CSS asset");

  renderedLibraryCss = await readFile(path.join(repoRoot, "dist", cssMatch[1]!), "utf8");
});

test("library page renders detail panel hooks and serialized details", () => {
  assert.match(renderedLibraryPage, /<script type="application\/json" id="library-details">/);
  assert.match(renderedLibraryPage, /data-library-detail-modal/);
  assert.match(renderedLibraryPage, /data-library-detail-dialog/);
  assert.match(renderedLibraryPage, /data-library-detail-kicker/);
  assert.match(renderedLibraryPage, /data-library-detail-title/);
  assert.match(renderedLibraryPage, /data-library-detail-summary/);
  assert.match(renderedLibraryPage, /data-library-detail-meta/);
  assert.match(renderedLibraryPage, /data-library-detail-related/);
  assert.match(renderedLibraryPage, /data-library-tree-button/);
  assert.match(renderedLibraryPage, /data-library-detail-modal[^>]*hidden/);
});

test("library page script opens a modal on selection and clears state on outside click", () => {
  assert.match(renderedLibraryPage, /const openModal = \(button\) =>/);
  assert.match(renderedLibraryPage, /const closeModal = \(\) =>/);
  assert.match(renderedLibraryPage, /modalElement\.hidden = false/);
  assert.match(renderedLibraryPage, /modalElement\.hidden = true/);
  assert.match(renderedLibraryPage, /updateSelection\(null\)/);
  assert.match(renderedLibraryPage, /modalElement\.addEventListener\("click", closeModal\)/);
  assert.match(renderedLibraryPage, /dialogElement\.addEventListener\("click", \(event\) =>/);
  assert.doesNotMatch(renderedLibraryPage, /const initialButton = buttons\[0\]/);
  assert.doesNotMatch(renderedLibraryPage, /selectButton\(initialButton\)/);
  assert.doesNotMatch(renderedLibraryPage, /JSON\.parse\(detailSource\?\.textContent \?\? "\{\}"\)/);
});

test("library page CSS keeps hidden modal and hidden meta sections collapsed", () => {
  assert.match(renderedLibraryCss, /\.library-detail-modal\[hidden\][^{]*\{[^}]*display:\s*none/);
  assert.match(renderedLibraryCss, /\.library-detail-meta\[hidden\][^{]*\{[^}]*display:\s*none/);
});

test("library modal dialog uses an opaque background", () => {
  assert.match(renderedLibraryCss, /\.library-detail-dialog[^{]*\{[^}]*background:\s*#[0-9a-fA-F]{3,8}/);
});
