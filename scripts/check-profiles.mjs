#!/usr/bin/env node

import { checkXUrl, profileUrlFromHandle } from './x-url-utils.mjs';

const handles = [
  '@OpenAI', '@AnthropicAI', '@GoogleDeepMind', '@xai', '@MetaAI', '@claudeai',
  '@cursor_ai', '@github', '@replit', '@perplexity_ai', '@Alibaba_Qwen',
  '@Stanford', '@MIT', '@UCBerkeley', '@NousResearch', '@AutoGPT', '@BabyAGI',
  '@MultiOn', '@adept', '@heyalexmoore', '@AITwitter', '@reddit', '@huggingface', '@midjourney',
];

async function main() {
  for (const handle of handles) {
    const url = profileUrlFromHandle(handle);
    const result = await checkXUrl(url);
    console.log(`${handle}\t${result.ok ? 'ok' : 'broken'}\t${url}`);
    await new Promise((resolve) => setTimeout(resolve, 350));
  }
}

main();
