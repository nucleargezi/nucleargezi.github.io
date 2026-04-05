import assert from "node:assert/strict";
import test from "node:test";

const sampleToml = `
schema_version = 2
generated_at = "2026-04-05T14:35:16.222682488Z"
status = "failed"
failures = []

[template_coverage]
all_passed = ["aa/head.hpp", "aa/main.hpp"]
has_failures = ["al/m/add.hpp"]
unused = ["aa/fast.hpp"]

[tests."test/aa/head.cpp"]
path = "test/aa/head.cpp"
dependencies = ["aa/head.hpp", "aa/main.hpp"]

[tests."test/aa/head.cpp".last_result]
status = "passed"
verdict = "Accepted"
grade = "100/100"
time_text = "12 ms"
memory_text = "1024 KB"

[tests."test/al/add.cpp"]
path = "test/al/add.cpp"
dependencies = ["al/m/add.hpp"]

[tests."test/al/add.cpp".last_result]
status = "failed"
verdict = "Wrong Answer"
`;

const sampleInvalidStatusToml = `
schema_version = 2
generated_at = "2026-04-05T14:35:16.222682488Z"
status = "failed"
failures = []

[template_coverage]
all_passed = ["aa/head.hpp"]
has_failures = []
unused = []

[tests."test/aa/head.cpp"]
path = "test/aa/head.cpp"
dependencies = ["aa/head.hpp"]

[tests."test/aa/head.cpp".last_result]
status = "invalid"
verdict = "Compile Error"
`;

async function loadLibraryStateModule() {
  try {
    return await import("../src/lib/library-state.ts");
  } catch {
    return undefined;
  }
}

test("buildLibraryPageDataFromTomlText normalizes template and test state", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  const data = module!.buildLibraryPageDataFromTomlText(sampleToml);

  assert.deepEqual(data.summary.templates, {
    total: 4,
    allPassed: 2,
    hasFailures: 1,
    unused: 1,
  });

  assert.deepEqual(data.summary.tests, {
    total: 2,
    passed: 1,
    notPassed: 1,
  });

  assert.equal(data.details["test:test/al/add.cpp"]?.status, "not_passed");
});

test("buildLibraryPageDataFromTomlText creates reverse dependency indexes", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  const data = module!.buildLibraryPageDataFromTomlText(sampleToml);

  assert.deepEqual(data.templateToTests["aa/head.hpp"], ["test/aa/head.cpp"]);
  assert.deepEqual(data.templateToTests["aa/main.hpp"], ["test/aa/head.cpp"]);
  assert.deepEqual(data.templateToTests["al/m/add.hpp"], ["test/al/add.cpp"]);
  assert.deepEqual(data.templateToTests["aa/fast.hpp"], []);

  assert.deepEqual(data.testToTemplates["test/aa/head.cpp"], ["aa/head.hpp", "aa/main.hpp"]);
  assert.deepEqual(data.testToTemplates["test/al/add.cpp"], ["al/m/add.hpp"]);
});

test("buildLibraryPageDataFromTomlText builds sorted directory trees", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  const data = module!.buildLibraryPageDataFromTomlText(sampleToml);

  assert.deepEqual(
    data.templateTree.map((node) => node.label),
    ["aa", "al"],
  );

  assert.equal(data.templateTree[0]?.type, "directory");
  assert.deepEqual(
    data.templateTree[0]?.children.map((node) => node.label),
    ["fast.hpp", "head.hpp", "main.hpp"],
  );

  assert.equal(data.testTree[0]?.type, "directory");
  assert.equal(data.testTree[0]?.label, "test");
  assert.deepEqual(
    data.testTree[0]?.children.map((node) => node.label),
    ["aa", "al"],
  );
});

test("buildLibraryPageDataFromTomlText rejects duplicate template classification", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  assert.throws(
    () =>
      module!.buildLibraryPageDataFromTomlText(`
schema_version = 2
[template_coverage]
all_passed = ["aa/head.hpp"]
has_failures = ["aa/head.hpp"]
unused = []
`),
    /duplicate/i,
  );
});

test("buildLibraryPageDataFromTomlText rejects unsupported schema versions", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  assert.throws(
    () =>
      module!.buildLibraryPageDataFromTomlText(`
schema_version = 3
[template_coverage]
all_passed = []
has_failures = []
unused = []
`),
    /schema_version/i,
  );
});

test("buildLibraryPageDataFromTomlText maps invalid test results to not_passed", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  const data = module!.buildLibraryPageDataFromTomlText(sampleInvalidStatusToml);

  assert.equal(data.summary.tests.notPassed, 1);
  assert.equal(data.testTree[0]?.type, "directory");
  assert.equal(data.details["test:test/aa/head.cpp"]?.status, "not_passed");
});

test("buildLibraryPageDataFromTomlText rejects unknown test result statuses", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  assert.throws(
    () =>
      module!.buildLibraryPageDataFromTomlText(`
schema_version = 2
[template_coverage]
all_passed = ["aa/head.hpp"]
has_failures = []
unused = []

[tests."test/aa/head.cpp"]
path = "test/aa/head.cpp"
dependencies = ["aa/head.hpp"]

[tests."test/aa/head.cpp".last_result]
status = "skipped"
`),
    /status/i,
  );
});

test("buildLibraryPageDataFromTomlText rejects tests that reference unknown templates", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  assert.throws(
    () =>
      module!.buildLibraryPageDataFromTomlText(`
schema_version = 2
[template_coverage]
all_passed = ["aa/head.hpp"]
has_failures = []
unused = []

[tests."test/aa/head.cpp"]
path = "test/aa/head.cpp"
dependencies = ["aa/head.hpp", "missing/template.hpp"]

[tests."test/aa/head.cpp".last_result]
status = "passed"
`),
    /unknown template|missing\/template\.hpp/i,
  );
});
