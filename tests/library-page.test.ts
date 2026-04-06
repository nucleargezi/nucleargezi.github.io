import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test, { before } from "node:test";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const libraryPagePath = path.join(repoRoot, "src", "pages", "library", "index.astro");
const libraryModalCssPath = path.join(repoRoot, "src", "styles", "library", "modal.css");

let renderedLibraryPage = "";
let renderedLibraryCss = "";

before(async () => {
  renderedLibraryPage = await readFile(libraryPagePath, "utf8");
  renderedLibraryCss = await readFile(libraryModalCssPath, "utf8");
});

test("library page renders detail panel hooks and serialized details", () => {
  assert.match(
    renderedLibraryPage,
    /<script type="application\/json" id="library-details"[^>]*set:html=\{serializedDetails\}><\/script>/,
  );
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
  assert.match(renderedLibraryPage, /for \(const \{ label, value \} of detail\.meta\)/);
  assert.doesNotMatch(renderedLibraryPage, /const initialButton = buttons\[0\]/);
  assert.doesNotMatch(renderedLibraryPage, /selectButton\(initialButton\)/);
  assert.doesNotMatch(renderedLibraryPage, /JSON\.parse\(detailSource\?\.textContent \?\? "\{\}"\)/);
  assert.doesNotMatch(renderedLibraryPage, /detail\.verdict/);
  assert.doesNotMatch(renderedLibraryPage, /detail\.grade/);
  assert.doesNotMatch(renderedLibraryPage, /detail\.timeText/);
  assert.doesNotMatch(renderedLibraryPage, /detail\.memoryText/);
});

test("library page CSS keeps hidden modal and hidden meta sections collapsed", () => {
  assert.match(renderedLibraryCss, /\.library-detail-modal\[hidden\][^{]*\{[^}]*display:\s*none/);
  assert.match(renderedLibraryCss, /\.library-detail-meta\[hidden\][^{]*\{[^}]*display:\s*none/);
});

test("library modal dialog uses an opaque background", () => {
  assert.match(renderedLibraryCss, /\.library-detail-dialog[^{]*\{[^}]*background:\s*#[0-9a-fA-F]{3,8}/);
});
