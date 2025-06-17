import { OpenAI } from "openai";
import { loadEnv } from "vite";
import fs from "fs/promises";

const e = loadEnv("production", process.cwd(), "");

const openai = new OpenAI({
  baseURL: "https://api.deepseek.com/v1",
  apiKey: e.DEEPSEEK_API_KEY,
});

export const createCompletion = async (message, language = "Chinese") => {
  try {
    const completion = await openai.chat.completions.create({
      messages: [
        {
          role: "system",
          content: `You are a knowledgeable translator that translate text in user documents sentence by sentence. Translate following Typst (A markup) to ${language} (only output same syntax) without extra wrapping. Please keep markup to avoid syntax error.`,
        },
        { role: "user", content: message },
      ],
      model: "deepseek-reasoner",
      temperature: 1.3,
    });

    return completion.choices[0].message.content;
  } catch (error) {
    throw new Error("Completion failed: " + error.message);
  }
};

const input = process.argv[2];
if (!input) {
  console.error("Please provide a valid source path to translate.");
  process.exit(1);
}

const lang = process.argv[3];
if (lang != "zh" && lang != "en") {
  console.error("Please provide a valid language (zh or en) to translate to.");
  process.exit(1);
}

const language = lang == "zh" ? "Chinese" : "English";
console.log(`Translating to ${language}...`);

const output = input.replace(/\/article\//, `/article/${lang}/`);

const fileContent = await fs.readFile(input, "utf-8");
const translated = await createCompletion(fileContent, language);
await fs.writeFile(output, translated, "utf-8");
console.log(`Translation completed and saved to ${output}`);
