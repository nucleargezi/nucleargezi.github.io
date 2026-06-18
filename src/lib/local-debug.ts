import { algorithmTree } from "../data/algorithm-tree.ts";
import { algorithmTree as testAlgorithmTree } from "../data/algorithm-tree-for-test.ts";

import type { AlgorithmTreeNode } from "../data/algorithm-tree.ts";

type Env = {
  BLOG_LOCAL_DEBUG?: string;
};

export const localDebugArticleFiles = ["personal-info.typ", "a-20260321_fheap.typ"] as const;

function getCurrentEnv(): Env {
  const globalProcess = (globalThis as { process?: { env?: Env } }).process;
  return globalProcess?.env ?? {};
}

export function isLocalDebugMode(env: Env = getCurrentEnv()) {
  return env.BLOG_LOCAL_DEBUG === "1";
}

export function getBlogArticleGlobPattern(env: Env = getCurrentEnv()): string | string[] {
  return isLocalDebugMode(env) ? [...localDebugArticleFiles] : "*.typ";
}

export function getAlgorithmTreeForMode(env: Env = getCurrentEnv()): AlgorithmTreeNode[] {
  return isLocalDebugMode(env) ? testAlgorithmTree : algorithmTree;
}
