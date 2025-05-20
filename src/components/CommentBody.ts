import { NodeCompiler } from "@myriaddreamin/typst-ts-node-compiler";
import commentTemplate from "../../typ/templates/comment.typ?raw";
import { resolve } from "path";

const compiler = NodeCompiler.create({
  workspace: resolve(import.meta.dirname, "../../typ/templates"),
});

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

  const backtick = "`".repeat(maxRawBackticks + 1);
  const mainFileContent = `
${commentTemplate}
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
