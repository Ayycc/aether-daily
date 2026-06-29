#!/usr/bin/env node

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { checkXUrl, isPlaceholderXUrl } from './x-url-utils.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DATA_PATH = join(__dirname, '..', 'data', 'articles.json');

async function main() {
  const feed = JSON.parse(readFileSync(DATA_PATH, 'utf8'));
  const results = [];

  for (const article of feed.articles) {
    const placeholder = isPlaceholderXUrl(article.xURL);
    let check = { ok: false, skipped: true };

    if (!placeholder && article.xURL) {
      check = await checkXUrl(article.xURL);
      await new Promise((resolve) => setTimeout(resolve, 400));
    }

    results.push({
      id: article.id,
      headline: article.headline,
      xURL: article.xURL,
      xLinkType: article.xLinkType,
      placeholder,
      ...check,
    });
  }

  const broken = results.filter((row) => row.placeholder || !row.ok);
  console.log(JSON.stringify({ total: results.length, broken: broken.length, results }, null, 2));
  process.exit(broken.length > 0 ? 1 : 0);
}

main();
