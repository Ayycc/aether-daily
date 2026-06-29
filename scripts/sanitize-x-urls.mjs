#!/usr/bin/env node

import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { resolveArticleXLink } from './x-url-utils.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DATA_PATH = join(__dirname, '..', 'data', 'articles.json');

function sanitizeFeed(feed) {
  const articles = feed.articles.map((article) => {
    const link = resolveArticleXLink(article);
    return {
      ...article,
      xURL: link.xURL,
      xLinkType: link.xLinkType,
    };
  });

  return { ...feed, articles };
}

function main() {
  const feed = JSON.parse(readFileSync(DATA_PATH, 'utf8'));
  const sanitized = sanitizeFeed(feed);
  writeFileSync(DATA_PATH, `${JSON.stringify(sanitized, null, 2)}\n`, 'utf8');

  const posts = sanitized.articles.filter((article) => article.xLinkType === 'post').length;
  const profiles = sanitized.articles.filter((article) => article.xLinkType === 'profile').length;
  console.log(`Sanitized ${sanitized.articles.length} articles (${posts} posts, ${profiles} profiles).`);
}

main();
