import { NextResponse } from "next/server";
import fs from "fs";

export const dynamic = "force-dynamic";

export async function GET() {
  const userConfigPath = process.env.USER_CONFIG_PATH;

  let cfg: Record<string, string> = {};
  if (userConfigPath && fs.existsSync(userConfigPath)) {
    try {
      const raw = fs.readFileSync(userConfigPath, "utf-8");
      cfg = JSON.parse(raw || "{}");
    } catch { }
  }

  const provider = cfg?.LLM || process.env.LLM || "";

  let hasKey = false;
  if (provider === "custom") {
    // Custom LLM: check for URL and model
    const url = cfg?.CUSTOM_LLM_URL || process.env.CUSTOM_LLM_URL || "";
    const model = cfg?.CUSTOM_MODEL || process.env.CUSTOM_MODEL || "";
    hasKey = Boolean(url.trim() && model.trim());
  } else {
    // Default: check for OpenAI API key
    const keyFromFile = cfg?.OPENAI_API_KEY || "";
    const keyFromEnv = process.env.OPENAI_API_KEY || "";
    hasKey = Boolean((keyFromFile || keyFromEnv).trim());
  }

  return NextResponse.json({ hasKey });
} 