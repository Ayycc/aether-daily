#!/usr/bin/env node

const PLACEHOLDER_STATUS = /\/status\/\d*0{7,}\d*$/;

/** Verified post URLs checked against live X pages. */
export const VERIFIED_POST_URLS = {
  0: 'https://x.com/OpenAI/status/2070555272230384038',
  1: 'https://x.com/claudeai/status/2069468693017268244',
  2: 'https://x.com/Alibaba_Qwen/status/2069720365442719867',
  3: 'https://x.com/NousResearch/status/2070610321278988385',
  4: 'https://x.com/heyalexmoore/status/2070857558886351096',
  7: 'https://x.com/xai/status/1868045124028268983',
  9: 'https://x.com/cursor_ai/status/2039768512894505086',
};

/** Fallback links when a handle or placeholder post is invalid. */
export const SPECIAL_LINKS = {
  21: {
    xURL: 'https://x.com/search?q=AI%20Twitter%20Spaces&src=typed_query',
    xLinkType: 'search',
  },
};

const PROFILE_HANDLE_OVERRIDES = {
  '@AutoGPT': 'SignificantGravitas',
};

export function isPlaceholderXUrl(url) {
  return !url || PLACEHOLDER_STATUS.test(url);
}

export function profileUrlFromHandle(handle) {
  const normalized = handle.replace(/^@/, '').trim();
  const username = PROFILE_HANDLE_OVERRIDES[handle] ?? normalized;
  return `https://x.com/${username}`;
}

export function resolveArticleXLink(article) {
  const special = SPECIAL_LINKS[article.id];
  if (special) {
    return special;
  }

  const verified = VERIFIED_POST_URLS[article.id];
  if (verified) {
    return { xURL: verified, xLinkType: 'post' };
  }

  if (article.xURL && !isPlaceholderXUrl(article.xURL)) {
    return { xURL: article.xURL, xLinkType: article.xLinkType ?? 'post' };
  }

  return {
    xURL: profileUrlFromHandle(article.handle),
    xLinkType: 'profile',
  };
}

export async function checkXUrl(url) {
  try {
    const response = await fetch(url, {
      redirect: 'follow',
      headers: { 'User-Agent': 'Mozilla/5.0 (compatible; AetherDaily/1.0)' },
    });
    const html = await response.text();
    const broken =
      /Nothing to see here|This Post was deleted|This account doesn't exist|Account suspended|page doesn't exist/i.test(
        html
      );
    return { ok: response.ok && !broken, status: response.status, broken };
  } catch (error) {
    return { ok: false, error: error.message };
  }
}
