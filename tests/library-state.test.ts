import assert from "node:assert/strict";
import test from "node:test";

const sampleToml = `
schema_version = 2
generated_at = "2026-04-05T14:35:16.222682488Z"
status = "failed"
failures = []

[repo]
root = "/home/yorisou/Yorisou_alg_space/YRS"
base = "origin/main"
head = "HEAD"

[latest_run]
trigger_mode = "all"
changed_paths = []
selected_tests = ["test/aa/head.cpp", "test/al/add.cpp"]
total_discovered = 2
total_selected = 2
passed = 1
failed = 1
invalid = 0

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

const sampleSchema4Toml = `
schema_version = 4
generated_at = "2026-04-06T07:43:53.464721882Z"
status = "passed"
failures = []

[template_coverage]
all_passed = ["aa/head.hpp", "aa/main.hpp"]
has_failures = ["al/m/add.hpp"]
unused = ["aa/fast.hpp"]

[template_dependencies]
"aa/head.hpp" = ["aa/main.hpp"]
"aa/main.hpp" = []
"al/m/add.hpp" = ["aa/head.hpp", "aa/main.hpp"]
"aa/fast.hpp" = []

[template_dependents]
"aa/head.hpp" = ["al/m/add.hpp"]
"aa/main.hpp" = ["aa/head.hpp", "al/m/add.hpp"]
"al/m/add.hpp" = []
"aa/fast.hpp" = []

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
  assert.deepEqual(data.details["template:aa/head.hpp"]?.dependencies, []);
  assert.deepEqual(data.details["test:test/aa/head.cpp"]?.meta, [
    { label: "Status", value: "Passed" },
    { label: "Verdict", value: "Accepted" },
    { label: "Grade", value: "100/100" },
    { label: "Time", value: "12 ms" },
    { label: "Memory", value: "1024 KB" },
  ]);
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

test("buildLibraryPageDataFromTomlText includes template relations for schema version 4", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  const data = module!.buildLibraryPageDataFromTomlText(sampleSchema4Toml);

  assert.deepEqual(data.details["template:aa/head.hpp"]?.dependencies, ["aa/main.hpp"]);
  assert.deepEqual(data.details["template:aa/head.hpp"]?.dependents, ["al/m/add.hpp"]);
  assert.deepEqual(data.details["template:aa/main.hpp"]?.dependencies, []);
  assert.deepEqual(data.details["template:aa/main.hpp"]?.dependents, ["aa/head.hpp", "al/m/add.hpp"]);
  assert.deepEqual(data.details["template:al/m/add.hpp"]?.dependencies, ["aa/head.hpp", "aa/main.hpp"]);
  assert.deepEqual(data.details["template:al/m/add.hpp"]?.dependents, []);
});

test("buildLibraryPageDataFromTomlText defaults template dependents to empty arrays when omitted", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  const data = module!.buildLibraryPageDataFromTomlText(`
schema_version = 3
[template_coverage]
all_passed = ["aa/head.hpp"]
has_failures = []
unused = []

[template_dependencies]
"aa/head.hpp" = []
`);

  assert.deepEqual(data.details["template:aa/head.hpp"]?.dependents, []);
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

test("buildLibraryPageDataFromTomlText rejects unsupported future schema versions", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  assert.throws(
    () =>
      module!.buildLibraryPageDataFromTomlText(`
schema_version = 5
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
  assert.deepEqual(data.details["test:test/aa/head.cpp"]?.meta, [
    { label: "Status", value: "Not passed" },
    { label: "Verdict", value: "Compile Error" },
  ]);
});

test("buildLibraryPageDataFromTomlText omits missing test detail metadata entries", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  const data = module!.buildLibraryPageDataFromTomlText(sampleToml);

  assert.deepEqual(data.details["test:test/al/add.cpp"]?.meta, [
    { label: "Status", value: "Not passed" },
    { label: "Verdict", value: "Wrong Answer" },
  ]);
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

test("buildLibraryPageDataFromTomlText rejects template dependency keys for unknown templates", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  assert.throws(
    () =>
      module!.buildLibraryPageDataFromTomlText(`
schema_version = 4
[template_coverage]
all_passed = ["aa/head.hpp"]
has_failures = []
unused = []

[template_dependencies]
"missing/template.hpp" = ["aa/head.hpp"]
`),
    /unknown template|missing\/template\.hpp/i,
  );
});

test("buildLibraryPageDataFromTomlText rejects unknown template dependency references", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  assert.throws(
    () =>
      module!.buildLibraryPageDataFromTomlText(`
schema_version = 4
[template_coverage]
all_passed = ["aa/head.hpp"]
has_failures = []
unused = []

[template_dependencies]
"aa/head.hpp" = ["missing/template.hpp"]
`),
    /unknown template|missing\/template\.hpp/i,
  );
});

test("buildLibraryPageDataFromTomlText rejects template dependent keys for unknown templates", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  assert.throws(
    () =>
      module!.buildLibraryPageDataFromTomlText(`
schema_version = 4
[template_coverage]
all_passed = ["aa/head.hpp"]
has_failures = []
unused = []

[template_dependents]
"missing/template.hpp" = ["aa/head.hpp"]
`),
    /unknown template|missing\/template\.hpp/i,
  );
});

test("buildLibraryPageDataFromTomlText rejects unknown template dependent references", async () => {
  const module = await loadLibraryStateModule();

  assert.equal(
    typeof module?.buildLibraryPageDataFromTomlText,
    "function",
    "expected buildLibraryPageDataFromTomlText to be exported from src/lib/library-state.ts",
  );

  assert.throws(
    () =>
      module!.buildLibraryPageDataFromTomlText(`
schema_version = 4
[template_coverage]
all_passed = ["aa/head.hpp"]
has_failures = []
unused = []

[template_dependents]
"aa/head.hpp" = ["missing/template.hpp"]
`),
    /unknown template|missing\/template\.hpp/i,
  );
});
