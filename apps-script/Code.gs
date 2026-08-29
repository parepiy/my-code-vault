/**
 * Code Vault — Google Apps Script backend.
 *
 * Serves Index.html as a private web app and reads the GitHub repo
 * SERVER-SIDE with UrlFetchApp, so the repo can stay PRIVATE and the
 * token never reaches the browser.
 *
 * Setup (see README.md for the full walkthrough):
 *   Project Settings ▸ Script Properties:
 *     GH_OWNER   parepiy            (optional, this is the default)
 *     GH_REPO    my-code-vault      (optional, this is the default)
 *     GH_BRANCH  main               (optional, this is the default)
 *     GH_TOKEN   <fine-grained PAT> (required only if the repo is private)
 */

// Extensions treated as code, and how they map to a category label.
var CATEGORY_BY_EXT = {
  sql: 'BigQuery',
  bas: 'VBA',
  m: 'Power Query',
  md: 'Power Query'
};

// Tokens that should render fully upper-cased in card titles.
var ACRONYMS = {
  cjx: 1, cj: 1, td: 1, tdcj: 1, tdsc: 1, tdx: 1, db: 1, oos: 1, rtc: 1,
  npd: 1, ros: 1, scm: 1, doh: 1, rsp: 1, pog: 1, sup: 1, ttl: 1, id: 1,
  cp1: 1, cp2: 1, cp3: 1, url: 1, sc: 1
};

// Emoji pool used to give each card a stable little icon.
var EMOJI = ['🌸','🍊','🌻','🍄','🎀','🌷','🐼','🐱','🐶','🍀','🦉','✨',
             '🌹','🐦','🐰','🦊','🐹','🌼','🐨','🍁','🐥','🌺','🐝','🍋'];

function doGet() {
  return HtmlService.createHtmlOutputFromFile('Index')
    .setTitle('Code Vault')
    .addMetaTag('viewport', 'width=device-width, initial-scale=1');
}

/* ---------------- config + headers ---------------- */

function cfg_() {
  var p = PropertiesService.getScriptProperties();
  return {
    owner: p.getProperty('GH_OWNER') || 'parepiy',
    repo: p.getProperty('GH_REPO') || 'my-code-vault',
    branch: p.getProperty('GH_BRANCH') || 'main',
    token: p.getProperty('GH_TOKEN') || ''
  };
}

function ghHeaders_(rawContent) {
  var c = cfg_();
  var h = {
    'Accept': rawContent ? 'application/vnd.github.raw' : 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28'
  };
  if (c.token) h['Authorization'] = 'Bearer ' + c.token;
  return h;
}

/* ---------------- helpers ---------------- */

function ext_(path) {
  var m = path.split('.').pop();
  return m ? m.toLowerCase() : '';
}

function isCode_(path) {
  var base = path.split('/').pop();
  if (base.toLowerCase() === 'readme.md') return false;
  return !!CATEGORY_BY_EXT[ext_(path)];
}

function category_(path) {
  return CATEGORY_BY_EXT[ext_(path)] || 'Other';
}

function title_(path) {
  var base = path.split('/').pop().replace(/\.[^.]+$/, '');
  return base.split(/[_\-\s]+/).map(function (w) {
    if (!w) return '';
    if (ACRONYMS[w.toLowerCase()]) return w.toUpperCase();
    return w.charAt(0).toUpperCase() + w.slice(1);
  }).join(' ').trim();
}

function emoji_(path) {
  var sum = 0;
  for (var i = 0; i < path.length; i++) sum += path.charCodeAt(i);
  return EMOJI[sum % EMOJI.length];
}

// Pull a short description from the first comment line of a file.
function extractDesc_(text) {
  if (!text) return '';
  var lines = text.split(/\r?\n/).slice(0, 20);
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim();
    if (!line) continue;
    var m = line.match(/^(#+|--+|\/\/+|'+|\*+)\s*(.+)$/);
    if (m && m[2]) return m[2].trim().slice(0, 140);
  }
  // Fall back to the first non-empty line.
  for (var j = 0; j < lines.length; j++) {
    if (lines[j].trim()) return lines[j].trim().slice(0, 140);
  }
  return '';
}

function rawUrl_(path) {
  var c = cfg_();
  return 'https://api.github.com/repos/' + c.owner + '/' + c.repo +
         '/contents/' + path.split('/').map(encodeURIComponent).join('/') +
         '?ref=' + encodeURIComponent(c.branch);
}

/* ---------------- public API (called via google.script.run) ---------------- */

/**
 * Returns a JSON string: { items: [...], repo: "...", error: "..." }.
 * Cached for 6h; pass force=true (the ↻ button) to rebuild.
 */
function getManifest(force) {
  var c = cfg_();
  var cache = CacheService.getScriptCache();
  if (!force) {
    var hit = cache.get('manifest');
    if (hit) return hit;
  }

  var treeUrl = 'https://api.github.com/repos/' + c.owner + '/' + c.repo +
                '/git/trees/' + encodeURIComponent(c.branch) + '?recursive=1';
  var res = UrlFetchApp.fetch(treeUrl, { headers: ghHeaders_(false), muteHttpExceptions: true });
  if (res.getResponseCode() !== 200) {
    return JSON.stringify({
      items: [],
      repo: c.owner + '/' + c.repo,
      error: 'GitHub tree request failed (' + res.getResponseCode() +
             '). Check GH_TOKEN / repo name / branch.'
    });
  }

  var tree = (JSON.parse(res.getContentText()).tree || [])
    .filter(function (n) { return n.type === 'blob' && isCode_(n.path); });

  // Fetch every file's raw content in parallel to build descriptions.
  var requests = tree.map(function (n) {
    return { url: rawUrl_(n.path), headers: ghHeaders_(true), muteHttpExceptions: true };
  });
  var bodies = requests.length ? UrlFetchApp.fetchAll(requests) : [];

  var items = tree.map(function (n, i) {
    var body = (bodies[i] && bodies[i].getResponseCode() === 200) ? bodies[i].getContentText() : '';
    return {
      path: n.path,
      title: title_(n.path),
      category: category_(n.path),
      desc: extractDesc_(body),
      emoji: emoji_(n.path)
    };
  }).sort(function (a, b) { return a.title.localeCompare(b.title); });

  var out = JSON.stringify({ items: items, repo: c.owner + '/' + c.repo, error: '' });
  try { cache.put('manifest', out, 21600); } catch (e) { /* >100KB: skip caching */ }
  return out;
}

/** Returns the raw text of one file (called when a card is opened). */
function getContent(path) {
  if (!isCode_(path)) throw new Error('Not an allowed file: ' + path);
  var res = UrlFetchApp.fetch(rawUrl_(path), { headers: ghHeaders_(true), muteHttpExceptions: true });
  if (res.getResponseCode() !== 200) {
    throw new Error('Could not read ' + path + ' (' + res.getResponseCode() + ')');
  }
  return res.getContentText();
}

/** Convenience for the "+ Add" button — the GitHub new-file URL. */
function newFileUrl() {
  var c = cfg_();
  return 'https://github.com/' + c.owner + '/' + c.repo + '/new/' + c.branch;
}
