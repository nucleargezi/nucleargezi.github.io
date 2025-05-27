import { NodeCompiler } from "@myriaddreamin/typst-ts-node-compiler";
import { resolve } from "path";
import { readFile } from "fs/promises";

const projectRoot = process.cwd();

const compiler = NodeCompiler.create({
  workspace: resolve(projectRoot, "typ/"),
});

const pdfCompiler = NodeCompiler.create({
  workspace: projectRoot,
  fontArgs: [{ fontPaths: [resolve(projectRoot, "assets/fonts/")] }],
});

export async function renderMonthlyPdf(mainFilePath: string): Promise<Buffer> {
  return pdfCompiler.pdf({
    mainFilePath: resolve(projectRoot, mainFilePath),
    inputs: {
      "build-kind": "monthly",
    },
  });
}

export async function renderComment(typstCode: string): Promise<string> {
  let maxRawBackticks = 0;
  let matchedBackticks;
  let re = /`{3,}/g;
  while ((matchedBackticks = re.exec(typstCode)) !== null) {
    const backtickCount = matchedBackticks[0].length;
    if (backtickCount > maxRawBackticks) {
      maxRawBackticks = backtickCount;
    }
  }
  const commentTemplate = await readFile(
    resolve(projectRoot, "typ/templates/comment.typ"),
    "utf-8"
  );

  const backtick = "`".repeat(Math.max(maxRawBackticks + 1, 3));
  const mainFileContent = `
${commentTemplate.replace("blog.typ", "templates/blog.typ")}
${backtick}md-render
${typstCode}
${backtick}
`;

  try {
    compiler.evictCache(10);
    const result = compiler.tryHtml({ mainFileContent });
    if (result.hasError()) {
      console.error("Error compiling comment:");
      result.printDiagnostics();
      return "";
    }

    return result.result?.body() || "";
  } catch (error) {
    console.error("Error rendering Typst code:", error);
    return "";
  }
}
