import { OpenAI } from "openai";
import { loadEnv } from "vite";

const e = loadEnv("production", process.cwd(), "");

const openai = new OpenAI({
  baseURL: "https://api.deepseek.com/v1",
  apiKey: e.DEEPSEEK_API_KEY,
});

export const createCompletion = async (message) => {
  try {
    const completion = await openai.chat.completions.create({
      messages: [
        {
          role: "system",
          content:
            "You are a knowledgeable translator. Translate following HTML to Chinese (only output HTML) without extra wrapping.",
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

console.log(
  await createCompletion(
    `<h1>Hello World</h1>
<p>This is a test.</p>`
  )
);
