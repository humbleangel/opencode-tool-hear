import { tool } from "@opencode-ai/plugin";
import { z } from "zod";
import { spawn } from "child_process";
import path from "path";

const hearTool = tool({
  description:
    "Record microphone audio for X seconds and return the transcribed speech as text. Trigger phrases: 'ouca por X segundos' / 'listen for X seconds'. Honor the user's always-listen preference (see voice instructions).",
  args: {
    seconds: z.number().default(5).describe("Recording duration in seconds"),
    language: z
      .string()
      .default("en")
      .describe("Language code for transcription"),
  },
  async execute(args, context) {
    const { seconds, language } = args;

    const pythonScriptPath = path.join(
      process.env.APPDATA ?? "",
      "..",
      "..",
      ".config",
      "opencode",
      "tools",
      "hear.py"
    );

    const inputJson = JSON.stringify({ seconds, language });

    return new Promise((resolve) => {
      const child = spawn("python", [pythonScriptPath], {
        windowsHide: true,
      });
      let stdout = "";
      child.stdout.on("data", (d) => (stdout += d));
      child.on("close", () => {
        try {
          const parsed = JSON.parse(stdout.trim());
          resolve(parsed.text ?? parsed.message ?? stdout.trim());
        } catch {
          resolve(stdout.trim() || "No output from hear.");
        }
      });
      child.stdin.write(inputJson);
      child.stdin.end();
    });
  },
});

export default hearTool;
