import { writeFile, readdir } from "fs/promises";
import { join } from "path";

async function main() {
  const root = join(import.meta.dirname, "../");

  // 扫描 content/article 目录中的所有 .typ 文件
  const arts = (await readdir(join(root, `content/article`)))
    .filter((it) => it.endsWith(".typ"))
    .map((it) => it.replace(/\.typ$/g, ""))
    .sort();

  // 写入 article-ids.json
  await writeFile(
    join(root, `content/snapshot/article-ids.json`),
    JSON.stringify(arts, null, 1),
    "utf-8"
  );

  console.log(`✅ Updated article-ids.json with ${arts.length} articles:`);
  console.log(arts.map((art) => `  - ${art}`).join("\n"));
}

await main();
