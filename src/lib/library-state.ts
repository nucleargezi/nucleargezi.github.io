import { readFile } from "node:fs/promises";
import { resolve } from "node:path";

import { parse } from "smol-toml";

export type TemplateStatus = "all_passed" | "has_failures" | "unused";
export type TestStatus = "passed" | "not_passed";
export type LibraryItemKind = "template" | "test";

export interface LibraryDirectoryNode {
  type: "directory";
  label: string;
  path: string;
  children: LibraryTreeNode[];
}

export interface LibraryFileNode {
  type: "file";
  id: string;
  kind: LibraryItemKind;
  label: string;
  path: string;
  status: TemplateStatus | TestStatus;
}

export type LibraryTreeNode = LibraryDirectoryNode | LibraryFileNode;

export interface LibraryTemplateSummary {
  total: number;
  allPassed: number;
  hasFailures: number;
  unused: number;
}

export interface LibraryTestSummary {
  total: number;
  passed: number;
  notPassed: number;
}

export interface LibrarySummary {
  templates: LibraryTemplateSummary;
  tests: LibraryTestSummary;
}

export interface LibraryTemplateDetail {
  kind: "template";
  path: string;
  status: TemplateStatus;
  dependencies: string[];
  relatedTests: string[];
}

export interface LibraryDetailMetaItem {
  label: string;
  value: string;
}

export interface LibraryTestDetail {
  kind: "test";
  path: string;
  status: TestStatus;
  relatedTemplates: string[];
  meta: LibraryDetailMetaItem[];
}

export type LibraryDetail = LibraryTemplateDetail | LibraryTestDetail;

export interface LibraryPageData {
  summary: LibrarySummary;
  templateTree: LibraryTreeNode[];
  testTree: LibraryTreeNode[];
  templateToTests: Record<string, string[]>;
  testToTemplates: Record<string, string[]>;
  details: Record<string, LibraryDetail>;
}

interface MutableDirectoryBucket {
  label: string;
  path: string;
  directories: Map<string, MutableDirectoryBucket>;
  files: LibraryFileNode[];
}

interface ParsedTestEntry {
  path: string;
  status: TestStatus;
  dependencies: string[];
  verdict?: string;
  grade?: string;
  timeText?: string;
  memoryText?: string;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function expectRecord(value: unknown, label: string): Record<string, unknown> {
  if (!isRecord(value)) {
    throw new Error(`[library-state] Expected ${label} to be a table.`);
  }

  return value;
}

function expectString(value: unknown, label: string): string {
  if (typeof value !== "string") {
    throw new Error(`[library-state] Expected ${label} to be a string.`);
  }

  return value;
}

function expectNumber(value: unknown, label: string): number {
  if (typeof value !== "number") {
    throw new Error(`[library-state] Expected ${label} to be a number.`);
  }

  return value;
}

function expectStringArray(value: unknown, label: string): string[] {
  if (!Array.isArray(value)) {
    throw new Error(`[library-state] Expected ${label} to be an array.`);
  }

  return value.map((entry, index) => expectString(entry, `${label}[${index}]`));
}

function normalizePath(value: string, label: string): string {
  const path = value.trim();
  if (path.length === 0) {
    throw new Error(`[library-state] Expected ${label} to be a non-empty path.`);
  }

  return path;
}

function sortPaths(paths: Iterable<string>): string[] {
  return [...paths].sort((left, right) => left.localeCompare(right));
}

function makeItemId(kind: LibraryItemKind, path: string): string {
  return `${kind}:${path}`;
}

function createDirectoryBucket(label: string, path: string): MutableDirectoryBucket {
  return {
    label,
    path,
    directories: new Map(),
    files: [],
  };
}

function insertFileNode(root: MutableDirectoryBucket, node: LibraryFileNode) {
  const segments = node.path.split("/");
  if (segments.length === 0) {
    throw new Error(`[library-state] Invalid path "${node.path}".`);
  }

  let current = root;
  for (const [index, segment] of segments.entries()) {
    if (segment.length === 0) {
      throw new Error(`[library-state] Invalid empty path segment in "${node.path}".`);
    }

    const isLeaf = index === segments.length - 1;
    if (isLeaf) {
      if (current.files.some((file) => file.path === node.path)) {
        throw new Error(`[library-state] Duplicate file path "${node.path}" in tree.`);
      }

      current.files.push({
        ...node,
        label: segment,
      });
      return;
    }

    const nextPath = current.path.length === 0 ? segment : `${current.path}/${segment}`;
    const nextBucket = current.directories.get(segment) ?? createDirectoryBucket(segment, nextPath);
    current.directories.set(segment, nextBucket);
    current = nextBucket;
  }
}

function finalizeTree(bucket: MutableDirectoryBucket): LibraryTreeNode[] {
  const directoryNodes = [...bucket.directories.values()]
    .sort((left, right) => left.label.localeCompare(right.label))
    .map<LibraryDirectoryNode>((directory) => ({
      type: "directory",
      label: directory.label,
      path: directory.path,
      children: finalizeTree(directory),
    }));

  const fileNodes = [...bucket.files].sort((left, right) => left.label.localeCompare(right.label));

  return [...directoryNodes, ...fileNodes];
}

function buildTree(
  entries: Array<{
    kind: LibraryItemKind;
    path: string;
    status: TemplateStatus | TestStatus;
  }>,
): LibraryTreeNode[] {
  const root = createDirectoryBucket("", "");

  for (const entry of entries) {
    insertFileNode(root, {
      type: "file",
      id: makeItemId(entry.kind, entry.path),
      kind: entry.kind,
      label: entry.path,
      path: entry.path,
      status: entry.status,
    });
  }

  return finalizeTree(root);
}

function parseTemplateCoverage(value: unknown): Record<TemplateStatus, string[]> {
  const coverage = expectRecord(value, "template_coverage");
  const allPassed = expectStringArray(coverage.all_passed, "template_coverage.all_passed").map(
    (path) => normalizePath(path, "template_coverage.all_passed"),
  );
  const hasFailures = expectStringArray(
    coverage.has_failures,
    "template_coverage.has_failures",
  ).map((path) => normalizePath(path, "template_coverage.has_failures"));
  const unused = expectStringArray(coverage.unused, "template_coverage.unused").map((path) =>
    normalizePath(path, "template_coverage.unused"),
  );

  const seen = new Map<string, TemplateStatus>();
  for (const [status, paths] of Object.entries({
    all_passed: allPassed,
    has_failures: hasFailures,
    unused,
  }) as Array<[TemplateStatus, string[]]>) {
    for (const path of paths) {
      const previous = seen.get(path);
      if (previous) {
        throw new Error(
          `[library-state] Found duplicate template classification for "${path}" in ${previous} and ${status}.`,
        );
      }

      seen.set(path, status);
    }
  }

  return {
    all_passed: sortPaths(allPassed),
    has_failures: sortPaths(hasFailures),
    unused: sortPaths(unused),
  };
}

function createEmptyTemplateDependencies(
  templates: Record<TemplateStatus, string[]>,
): Record<string, string[]> {
  return Object.fromEntries(
    [...templates.all_passed, ...templates.has_failures, ...templates.unused].map((path) => [path, []]),
  ) as Record<string, string[]>;
}

function parseTemplateDependencies(
  value: unknown,
  templates: Record<TemplateStatus, string[]>,
): Record<string, string[]> {
  const templateSet = new Set([
    ...templates.all_passed,
    ...templates.has_failures,
    ...templates.unused,
  ]);
  const result = createEmptyTemplateDependencies(templates);

  if (value === undefined) {
    return result;
  }

  const dependencies = expectRecord(value, "template_dependencies");

  for (const [rawTemplatePath, rawDependencyPaths] of Object.entries(dependencies)) {
    const templatePath = normalizePath(rawTemplatePath, `template_dependencies.${rawTemplatePath}`);
    if (!templateSet.has(templatePath)) {
      throw new Error(
        `[library-state] Found unknown template "${templatePath}" in template_dependencies.`,
      );
    }

    const dependencyPaths = sortPaths(
      new Set(
        expectStringArray(rawDependencyPaths, `template_dependencies.${templatePath}`).map((dependencyPath) =>
          normalizePath(dependencyPath, `template_dependencies.${templatePath}`),
        ),
      ),
    );

    for (const dependencyPath of dependencyPaths) {
      if (!templateSet.has(dependencyPath)) {
        throw new Error(
          `[library-state] Template "${templatePath}" references unknown template "${dependencyPath}".`,
        );
      }
    }

    result[templatePath] = dependencyPaths;
  }

  return result;
}

function parseOptionalString(value: unknown): string | undefined {
  return typeof value === "string" && value.trim().length > 0 ? value : undefined;
}

function parseTestStatus(value: unknown, label: string): TestStatus {
  const status = expectString(value, label);

  switch (status) {
    case "passed":
      return "passed";
    case "failed":
    case "invalid":
      return "not_passed";
    default:
      throw new Error(`[library-state] Unsupported test status "${status}" in ${label}.`);
  }
}

function parseTests(value: unknown): ParsedTestEntry[] {
  if (value === undefined) {
    return [];
  }

  const tests = expectRecord(value, "tests");

  return Object.entries(tests)
    .sort(([leftPath], [rightPath]) => leftPath.localeCompare(rightPath))
    .map(([testKey, rawEntry]) => {
      const entry = expectRecord(rawEntry, `tests.${testKey}`);
      const path = normalizePath(expectString(entry.path, `tests.${testKey}.path`), `tests.${testKey}.path`);
      const dependencies = sortPaths(
        expectStringArray(entry.dependencies, `tests.${testKey}.dependencies`).map((dependency) =>
          normalizePath(dependency, `tests.${testKey}.dependencies`),
        ),
      );
      const lastResult = expectRecord(entry.last_result, `tests.${testKey}.last_result`);

      return {
        path,
        status: parseTestStatus(lastResult.status, `tests.${testKey}.last_result.status`),
        dependencies,
        verdict: parseOptionalString(lastResult.verdict),
        grade: parseOptionalString(lastResult.grade),
        timeText: parseOptionalString(lastResult.time_text),
        memoryText: parseOptionalString(lastResult.memory_text),
      } satisfies ParsedTestEntry;
    });
}

function getTestStatusLabel(status: TestStatus): string {
  return status === "passed" ? "Passed" : "Not passed";
}

function createTestMeta(test: ParsedTestEntry): LibraryDetailMetaItem[] {
  return [
    { label: "Status", value: getTestStatusLabel(test.status) },
    { label: "Verdict", value: test.verdict },
    { label: "Grade", value: test.grade },
    { label: "Time", value: test.timeText },
    { label: "Memory", value: test.memoryText },
  ].filter((entry): entry is LibraryDetailMetaItem => typeof entry.value === "string");
}

function createTemplateToTests(
  templates: Record<TemplateStatus, string[]>,
  tests: ParsedTestEntry[],
): Record<string, string[]> {
  const result = Object.fromEntries(
    [...templates.all_passed, ...templates.has_failures, ...templates.unused].map((path) => [path, []]),
  ) as Record<string, string[]>;

  for (const test of tests) {
    for (const dependency of test.dependencies) {
      if (!result[dependency]) {
        throw new Error(
          `[library-state] Test "${test.path}" references unknown template "${dependency}".`,
        );
      }

      result[dependency].push(test.path);
    }
  }

  for (const [path, relatedTests] of Object.entries(result)) {
    result[path] = sortPaths(new Set(relatedTests));
  }

  return result;
}

function createTestToTemplates(tests: ParsedTestEntry[]): Record<string, string[]> {
  return Object.fromEntries(
    tests.map((test) => [test.path, sortPaths(new Set(test.dependencies))]),
  ) as Record<string, string[]>;
}

function createSummary(
  templates: Record<TemplateStatus, string[]>,
  tests: ParsedTestEntry[],
): LibrarySummary {
  const passedCount = tests.filter((test) => test.status === "passed").length;

  return {
    templates: {
      total: templates.all_passed.length + templates.has_failures.length + templates.unused.length,
      allPassed: templates.all_passed.length,
      hasFailures: templates.has_failures.length,
      unused: templates.unused.length,
    },
    tests: {
      total: tests.length,
      passed: passedCount,
      notPassed: tests.length - passedCount,
    },
  };
}

function createDetails(
  templates: Record<TemplateStatus, string[]>,
  tests: ParsedTestEntry[],
  templateDependencies: Record<string, string[]>,
  templateToTests: Record<string, string[]>,
  testToTemplates: Record<string, string[]>,
): Record<string, LibraryDetail> {
  const details: Record<string, LibraryDetail> = {};

  for (const [status, paths] of Object.entries(templates) as Array<[TemplateStatus, string[]]>) {
    for (const path of paths) {
      details[makeItemId("template", path)] = {
        kind: "template",
        path,
        status,
        dependencies: templateDependencies[path] ?? [],
        relatedTests: templateToTests[path] ?? [],
      };
    }
  }

  for (const test of tests) {
    details[makeItemId("test", test.path)] = {
      kind: "test",
      path: test.path,
      status: test.status,
      relatedTemplates: testToTemplates[test.path] ?? [],
      meta: createTestMeta(test),
    };
  }

  return details;
}

export function buildLibraryPageDataFromTomlText(text: string): LibraryPageData {
  const rawState = expectRecord(parse(text), "library state");
  const schemaVersion = expectNumber(rawState.schema_version, "schema_version");

  if (schemaVersion !== 2 && schemaVersion !== 3) {
    throw new Error(`[library-state] Unsupported schema_version "${schemaVersion}".`);
  }

  const templates = parseTemplateCoverage(rawState.template_coverage);
  const templateDependencies =
    schemaVersion === 3
      ? parseTemplateDependencies(rawState.template_dependencies, templates)
      : createEmptyTemplateDependencies(templates);
  const tests = parseTests(rawState.tests);
  const templateToTests = createTemplateToTests(templates, tests);
  const testToTemplates = createTestToTemplates(tests);

  return {
    summary: createSummary(templates, tests),
    templateTree: buildTree([
      ...templates.all_passed.map((path) => ({ kind: "template" as const, path, status: "all_passed" as const })),
      ...templates.has_failures.map((path) => ({
        kind: "template" as const,
        path,
        status: "has_failures" as const,
      })),
      ...templates.unused.map((path) => ({ kind: "template" as const, path, status: "unused" as const })),
    ]),
    testTree: buildTree(tests.map((test) => ({ kind: "test" as const, path: test.path, status: test.status }))),
    templateToTests,
    testToTemplates,
    details: createDetails(templates, tests, templateDependencies, templateToTests, testToTemplates),
  };
}

export async function getLibraryPageData(
  source: string | URL = resolve(process.cwd(), "src/pages/library/state.toml"),
): Promise<LibraryPageData> {
  const text = await readFile(source, "utf8");
  return buildLibraryPageDataFromTomlText(text);
}
