#!/usr/bin/env node

import { readFileSync, writeFileSync, appendFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { isPlaceholderXUrl, resolveArticleXLink } from './x-url-utils.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
const DATA_PATH = join(ROOT, 'data', 'articles.json');
const STATE_PATH = join(ROOT, 'loop', 'state.md');

const CATEGORIES = ['MODELS', 'TOOLS', 'RESEARCH', 'AGENTS', 'COMMUNITY'];
const TIME_SLOTS = ['6:10 AM', '8:45 AM', '10:20 AM', '12:55 PM', '2:14 PM', '4:30 PM', '7:05 PM', '9:30 PM'];

function parseArgs(argv) {
  return {
    force: argv.includes('--force'),
    dryRun: argv.includes('--dry-run'),
  };
}

function todayKey(date = new Date()) {
  return date.toISOString().slice(0, 10);
}

function formatTimestamp(date, slotIndex) {
  return date.toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  }) + ` • ${TIME_SLOTS[slotIndex % TIME_SLOTS.length]}`;
}

function bumpLikes(likes) {
  const growth = 1 + (Math.random() * 0.06 + 0.02);
  return Math.round(likes * growth);
}

function pickHero(articles) {
  return [...articles].sort((a, b) => b.likes - a.likes)[0];
}

function rotateCategorySpotlight(articles, edition) {
  const category = CATEGORIES[edition % CATEGORIES.length];
  const inCategory = articles.filter((article) => article.category === category);
  if (inCategory.length === 0) {
    return articles;
  }

  const spotlight = [...inCategory].sort((a, b) => b.likes - a.likes)[0];
  return articles.map((article) => ({
    ...article,
    likes: article.id === spotlight.id ? bumpLikes(article.likes) : bumpLikes(article.likes * 0.985),
  }));
}

async function fetchFromX(existingArticles) {
  const token = process.env.X_BEARER_TOKEN;
  if (!token) {
    return existingArticles;
  }

  const query = encodeURIComponent(
    '(AI OR LLM OR GPT OR Claude OR agent OR "machine learning") min_faves:5000 lang:en -is:retweet'
  );
  const url = `https://api.twitter.com/2/tweets/search/recent?query=${query}&max_results=10&tweet.fields=public_metrics,created_at,author_id&expansions=author_id&user.fields=username,name`;

  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });

  if (!response.ok) {
    throw new Error(`X API request failed: ${response.status} ${response.statusText}`);
  }

  const payload = await response.json();
  const users = new Map((payload.includes?.users ?? []).map((user) => [user.id, user]));
  const nextId = Math.max(...existingArticles.map((article) => article.id)) + 1;

  const incoming = (payload.data ?? []).slice(0, 3).map((tweet, index) => {
    const author = users.get(tweet.author_id) ?? { name: 'X User', username: 'unknown' };
    const createdAt = new Date(tweet.created_at);
    const metrics = tweet.public_metrics ?? {};
    const text = tweet.text.replace(/\s+/g, ' ').trim();
    const headline = text.length > 90 ? `${text.slice(0, 87)}...` : text;

    return {
      id: nextId + index,
      headline,
      subheadline: 'Trending on X today',
      summary: text,
      author: author.name,
      handle: `@${author.username}`,
      timestamp: formatTimestamp(createdAt, index),
      likes: metrics.like_count ?? 0,
      xURL: `https://x.com/${author.username}/status/${tweet.id}`,
      xLinkType: 'post',
      category: CATEGORIES[index % CATEGORIES.length],
      isHero: false,
    };
  });

  if (incoming.length === 0) {
    return existingArticles;
  }

  const merged = [...incoming, ...existingArticles].slice(0, 30);
  return merged;
}

function appendState(message) {
  if (!existsSync(dirname(STATE_PATH))) {
    return;
  }

  appendFileSync(STATE_PATH, `${message}\n`, 'utf8');
}

function loadFeed() {
  return JSON.parse(readFileSync(DATA_PATH, 'utf8'));
}

function saveFeed(feed) {
  writeFileSync(DATA_PATH, `${JSON.stringify(feed, null, 2)}\n`, 'utf8');
}

export async function refreshArticles(options = {}) {
  const { force = false, dryRun = false } = options;
  const feed = loadFeed();
  const now = new Date();
  const refreshDay = todayKey(now);

  if (!force && feed.lastRefreshed && todayKey(new Date(feed.lastRefreshed)) === refreshDay) {
    const message = `[${now.toISOString()}] Skipped refresh — already updated for ${refreshDay}.`;
    console.log(message);
    return { changed: false, feed, message };
  }

  let articles = feed.articles.map((article) => ({ ...article, isHero: false }));
  articles = rotateCategorySpotlight(articles, feed.edition + 1);

  try {
    articles = await fetchFromX(articles);
  } catch (error) {
    console.warn(`X API fetch skipped: ${error.message}`);
  }

  articles = articles.map((article, index) => {
    const sanitized = resolveArticleXLink(article);
    return {
      ...article,
      timestamp: formatTimestamp(now, index),
      likes: Math.max(article.likes, bumpLikes(article.likes * 0.99)),
      xURL: sanitized.xURL,
      xLinkType: sanitized.xLinkType,
    };
  });

  const hero = pickHero(articles);
  articles = articles.map((article) => ({
    ...article,
    isHero: article.id === hero.id,
  }));

  const nextFeed = {
    edition: feed.edition + 1,
    lastRefreshed: now.toISOString(),
    articles,
  };

  const message = `[${now.toISOString()}] Refreshed edition ${nextFeed.edition}. Hero: "${hero.headline}" (${hero.category}).`;

  if (!dryRun) {
    saveFeed(nextFeed);
    appendState(message);
  }

  console.log(message);
  return { changed: true, feed: nextFeed, message };
}

const isDirectRun = process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1];

if (isDirectRun) {
  const args = parseArgs(process.argv.slice(2));
  refreshArticles(args).catch((error) => {
    console.error(error);
    process.exit(1);
  });
}
