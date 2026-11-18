const selector = "[data-typst-article] .typst-doc";
const articleSvg = document.querySelector(selector);
if (articleSvg) {
  enableTextSelection(articleSvg);
  enableCodeCopy(articleSvg);
}

function enableCodeCopy(svg) {
  const paper = svg.closest(".typst-paper");
  const buttons = paper?.querySelectorAll("button.code-copy");
  if (!buttons?.length) return;

  const blocks = new Map(Array.from(svg.querySelectorAll("g[data-code-block]"),
    block => [block.dataset.codeBlock, block]));
  const status = document.createElement("span");
  status.className = "code-copy-status";
  status.setAttribute("role", "status");
  paper.append(status);

  for (const button of buttons) {
    const id = button.dataset.codeBlock;
    const block = blocks.get(id);
    if (!block) continue;
    button.dataset.ready = "";

    // The button overlays the SVG but is its sibling in the document.
    for (const area of [block, button]) {
      area.addEventListener("pointerenter", () => { button.dataset.hovered = ""; });
      area.addEventListener("pointerleave", event => {
        if (event.relatedTarget?.closest?.("[data-code-block]")?.dataset.codeBlock !== id) {
          delete button.dataset.hovered;
        }
      });
    }

    let reset;
    button.addEventListener("click", async () => {
      status.textContent = "";
      try {
        await navigator.clipboard.writeText(button.dataset.code);
        button.dataset.result = "copied";
        status.textContent = "代码已复制";
      } catch {
        button.dataset.result = "failed";
        status.textContent = "复制失败，请手动选择代码并复制";
      }
      clearTimeout(reset);
      reset = setTimeout(() => { delete button.dataset.result; }, 1500);
    });
  }
}

function enableTextSelection(svg) {
  const selection = window.getSelection();
  let drag;
  let scrollFrame;
  let boxes;
  let draggedLink;

  // Separate SVG foreignObjects have separate HTML text boxes. In the gaps,
  // Chromium's native drag can select from the start of the entire SVG.
  function runAt(element) {
    const run = element?.closest(".tsel") ?? element?.closest(".typst-text")?.querySelector(".tsel");
    return run?.firstChild?.nodeType === Node.TEXT_NODE && svg.contains(run) ? run : null;
  }

  function nearestRun(x, y) {
    const page = svg.getBoundingClientRect();
    // Measure only when the pointer misses the text. Page-relative positions
    // stay valid as the reader scrolls; zoom or resizing changes the scale.
    if (!boxes || boxes.width !== page.width || boxes.height !== page.height) {
      const runs = [];
      for (const run of svg.querySelectorAll(".tsel")) {
        if (run.firstChild?.nodeType !== Node.TEXT_NODE) continue;
        const r = run.getBoundingClientRect();
        if (r.width && r.height) runs.push({ run, left: r.left - page.left, right: r.right - page.left,
          top: r.top - page.top, bottom: r.bottom - page.top });
      }
      boxes = { width: page.width, height: page.height, runs };
    }
    const px = x - page.left, py = y - page.top;
    let best, rowDistance = Infinity, columnDistance = Infinity;
    for (const box of boxes.runs) {
      const dy = Math.max(box.top - py, py - box.bottom, 0);
      const dx = Math.max(box.left - px, px - box.right, 0);
      if (dy < rowDistance || (dy === rowDistance && dx < columnDistance)) {
        best = box.run;
        rowDistance = dy;
        columnDistance = dx;
      }
    }
    return best;
  }

  function caretAt(x, y, target) {
    const run = runAt(target) ?? nearestRun(x, y);
    if (!run) return;
    const node = run.firstChild;
    const caret = document.caretPositionFromPoint?.(x, y);
    if (caret?.offsetNode === node) return { node, offset: caret.offset };
    const nativeRange = !caret && document.caretRangeFromPoint?.(x, y);
    if (nativeRange?.startContainer === node) return { node, offset: nativeRange.startOffset };

    // A glyph, a subscript or a gap can hit the SVG instead of its text box.
    // Resolve against this run's character bounds, never a caret in the TOC.
    const range = document.createRange();
    let offset = 0;
    for (const character of node.data) {
      range.setStart(node, offset);
      range.setEnd(node, offset + character.length);
      const r = range.getBoundingClientRect();
      if (x < (r.left + r.right) / 2) break;
      offset += character.length;
    }
    return { node, offset };
  }

  function extend() {
    if (!drag) return;
    const x = Math.max(0, Math.min(drag.x, innerWidth - 1));
    const y = Math.max(0, Math.min(drag.y, innerHeight - 1));
    const end = caretAt(x, y, document.elementFromPoint(x, y));
    if (end && (selection.anchorNode !== drag.start.node || selection.anchorOffset !== drag.start.offset
        || selection.focusNode !== end.node || selection.focusOffset !== end.offset)) {
      selection.setBaseAndExtent(drag.start.node, drag.start.offset, end.node, end.offset);
    }
  }

  function scrollAtEdge() {
    scrollFrame = undefined;
    if (!drag) return;
    const distance = drag.y < 24 ? drag.y - 24 : Math.max(0, drag.y - innerHeight + 24);
    if (!distance) return;
    const previous = scrollY;
    window.scrollBy(0, Math.sign(distance) * Math.min(32, Math.ceil(Math.abs(distance) / 2)));
    if (scrollY === previous) return;
    extend();
    scrollFrame = requestAnimationFrame(scrollAtEdge);
  }

  function finish() {
    if (scrollFrame !== undefined) cancelAnimationFrame(scrollFrame);
    scrollFrame = undefined;
    drag = undefined;
  }

  document.addEventListener("mousedown", event => {
    finish();
    draggedLink = undefined;
    if (event.defaultPrevented || event.button !== 0 || event.detail !== 1
        || event.shiftKey || event.ctrlKey || event.metaKey || event.altKey) return;
    if (event.target.closest?.("button,input,textarea,[contenteditable]")) return;
    const link = event.target.closest?.("a");
    if (link && !svg.contains(link)) return;
    // In the clipped paper margins the event can land on the blog layout.
    // Match the article's vertical extent, including the ends of its lines.
    if (!svg.contains(event.target)) {
      const box = svg.closest(".post-body").getBoundingClientRect();
      if (!event.target.closest?.(".page-post") || event.clientY < box.top || event.clientY > box.bottom) return;
    }
    const start = caretAt(event.clientX, event.clientY, event.target);
    if (!start) return;
    event.preventDefault();
    if (link) link.focus({ preventScroll: true });
    else if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
    selection.setBaseAndExtent(start.node, start.offset, start.node, start.offset);
    drag = { start, link, x: event.clientX, y: event.clientY, pressX: event.clientX, pressY: event.clientY };
  });

  window.addEventListener("mousemove", event => {
    if (!drag) return;
    if (event.buttons !== 1) return finish();
    drag.x = event.clientX;
    drag.y = event.clientY;
    if (drag.link && Math.hypot(drag.x - drag.pressX, drag.y - drag.pressY) > 4) draggedLink = drag.link;
    extend();
    if (scrollFrame === undefined) scrollAtEdge();
  });
  window.addEventListener("mouseup", event => {
    if (drag && event.button === 0) {
      drag.x = event.clientX;
      drag.y = event.clientY;
      extend();
    }
    finish();
  });
  svg.addEventListener("dragstart", event => { if (drag) event.preventDefault(); });
  svg.addEventListener("click", event => {
    if (draggedLink && event.detail && draggedLink.contains(event.target)) {
      event.preventDefault();
      event.stopImmediatePropagation();
    }
    draggedLink = undefined;
  }, true);
  window.addEventListener("blur", finish);
  window.addEventListener("pointercancel", finish);
  window.addEventListener("keydown", event => { if (event.key === "Escape") finish(); });

  document.addEventListener("copy", event => {
    if (!event.clipboardData || event.defaultPrevented || event.target.closest?.("input,textarea,[contenteditable]")) return;
    const selection = window.getSelection();
    if (!selection || selection.isCollapsed || selection.rangeCount !== 1) return;
    const range = selection.getRangeAt(0);
    const first = range.startContainer.parentElement?.closest(".tsel[data-prose]");
    const last = range.endContainer.parentElement?.closest(".tsel[data-prose]");
    const svg = first?.closest(selector);
    if (!svg || last?.closest(selector) !== svg || first === last) return;

    // cloneContents clips the actual first and last text nodes, including a
    // backwards selection. Every fragment must belong to verified prose.
    const runs = range.cloneContents().querySelectorAll(".tsel");
    let text = "", previous;
    for (const run of runs) {
      const paragraph = run.getAttribute("data-prose");
      if (paragraph === null) return;
      if (previous !== undefined && previous !== paragraph) text += "\n\n";
      text += run.textContent;
      previous = paragraph;
    }
    if (!text) return;
    event.clipboardData.setData("text/plain", text);
    event.preventDefault();
  });
}
