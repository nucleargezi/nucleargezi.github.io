import assert from "node:assert/strict";
import test from "node:test";

import { algorithmTree as fullAlgorithmTree } from "../src/data/algorithm-tree.ts";
import { algorithmTree as testAlgorithmTree } from "../src/data/algorithm-tree-for-test.ts";
import {
  getAlgorithmTreeForMode,
  isLocalDebugMode,
  localDebugArticleFiles,
} from "../src/lib/local-debug.ts";

function collectSlugs(nodes) {
  return nodes.flatMap((node) => {
    if ("slug" in node) {
      return [node.slug];
    }

    return collectSlugs(node.children);
  });
}

test("local debug article list only includes the intended lightweight articles", () => {
  assert.deepEqual(localDebugArticleFiles, ["personal-info.typ", "a-20260321_fheap.typ"]);
});

test("local debug mode is enabled only by BLOG_LOCAL_DEBUG=1", () => {
  assert.equal(isLocalDebugMode({ BLOG_LOCAL_DEBUG: "1" }), true);
  assert.equal(isLocalDebugMode({ BLOG_LOCAL_DEBUG: "true" }), false);
  assert.equal(isLocalDebugMode({}), false);
});

test("algorithm tree selector switches to the test tree only in local debug mode", () => {
  assert.equal(getAlgorithmTreeForMode({ BLOG_LOCAL_DEBUG: "1" }), testAlgorithmTree);
  assert.equal(getAlgorithmTreeForMode({}), fullAlgorithmTree);
});

test("test algorithm tree only references local debug articles", () => {
  const allowedSlugs = new Set(
    localDebugArticleFiles.map((filename) => filename.replace(/\.typ$/, "")),
  );
  const slugs = collectSlugs(testAlgorithmTree);

  assert.deepEqual(slugs, ["a-20260321_fheap"]);
  assert.ok(slugs.every((slug) => allowedSlugs.has(slug)));
});
