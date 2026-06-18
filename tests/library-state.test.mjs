import assert from "node:assert/strict";
import test from "node:test";

import { buildLibraryPageDataFromTomlText } from "../src/lib/library-state.ts";

const validState = `
schema_version = 4
generated_at = "2026-06-18T00:00:00Z"
status = "failed"
failures = []

[repo]
root = "/tmp/YRS"
base = ""
head = "abc"

[latest_run]
trigger_mode = "all"
changed_paths = []
selected_tests = ["ds/base_state", "ds/seg_state"]
total_discovered = 2
total_selected = 2
passed = 1
failed = 1
invalid = 0

[template_coverage]
all_passed = ["ds/base.hpp"]
has_failures = ["ds/seg.hpp"]
unused = ["al/add.hpp"]

[template_dependencies]
"al/add.hpp" = []
"ds/base.hpp" = []
"ds/seg.hpp" = ["al/add.hpp", "ds/base.hpp"]

[template_dependents]
"al/add.hpp" = ["ds/seg.hpp"]
"ds/base.hpp" = ["ds/seg.hpp"]
"ds/seg.hpp" = []

[tests."ds/base_state"]
path = "ds/base_state"
problem_url = ""
problem_id = 0
dependencies = ["ds/base.hpp"]
last_trigger = "ci"
last_tested_head = ""
last_updated_at = "2026-06-18T00:00:00Z"

[tests."ds/base_state".last_result]
status = "passed"
verdict = "accepted"
grade = ""
time_text = "0.1s"
memory_text = ""
run_id = 0
compile_error = ""
runtime_error = ""
error = ""

[tests."ds/seg_state"]
path = "ds/seg_state"
problem_url = ""
problem_id = 0
dependencies = ["ds/seg.hpp"]
last_trigger = "ci"
last_tested_head = ""
last_updated_at = "2026-06-18T00:00:00Z"

[tests."ds/seg_state".last_result]
status = "failed"
verdict = "failed"
grade = ""
time_text = "0.2s"
memory_text = ""
run_id = 1
compile_error = ""
runtime_error = ""
error = "exit code 1"
`;

test("library state parser builds schema v4 page data", () => {
  const data = buildLibraryPageDataFromTomlText(validState);

  assert.deepEqual(data.summary, {
    templates: {
      total: 3,
      allPassed: 1,
      hasFailures: 1,
      unused: 1,
    },
    tests: {
      total: 2,
      passed: 1,
      notPassed: 1,
    },
  });
  assert.deepEqual(data.templateToTests["ds/base.hpp"], ["ds/base_state"]);
  assert.deepEqual(data.templateToTests["ds/seg.hpp"], ["ds/seg_state"]);
  assert.deepEqual(data.testToTemplates["ds/seg_state"], ["ds/seg.hpp"]);
  assert.deepEqual(data.details["template:ds/seg.hpp"], {
    kind: "template",
    path: "ds/seg.hpp",
    status: "has_failures",
    dependencies: ["al/add.hpp", "ds/base.hpp"],
    dependents: [],
    relatedTests: ["ds/seg_state"],
  });
  assert.deepEqual(data.details["test:ds/seg_state"], {
    kind: "test",
    path: "ds/seg_state",
    status: "not_passed",
    relatedTemplates: ["ds/seg.hpp"],
    meta: [
      { label: "Status", value: "Not passed" },
      { label: "Verdict", value: "failed" },
      { label: "Time", value: "0.2s" },
    ],
  });
});

test("library state parser rejects unsupported schema versions", () => {
  assert.throws(
    () => buildLibraryPageDataFromTomlText(validState.replace("schema_version = 4", "schema_version = 99")),
    /Unsupported schema_version/,
  );
});

test("library state parser rejects duplicate template classification", () => {
  assert.throws(
    () =>
      buildLibraryPageDataFromTomlText(
        validState.replace('unused = ["al/add.hpp"]', 'unused = ["al/add.hpp", "ds/base.hpp"]'),
      ),
    /duplicate template classification/,
  );
});

test("library state parser rejects tests that reference unknown templates", () => {
  assert.throws(
    () => buildLibraryPageDataFromTomlText(validState.replace('dependencies = ["ds/seg.hpp"]', 'dependencies = ["ds/missing.hpp"]')),
    /references unknown template/,
  );
});
