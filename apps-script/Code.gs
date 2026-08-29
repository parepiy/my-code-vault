/**
 * Code Vault — Google Apps Script backend.
 *
 * Stores snippets in a Google Sheet (created automatically on first run) and
 * serves Index.html as a private web app with working Add / Edit / Delete.
 * Seed data (your existing 79 snippets) lives in Seed.gs and is loaded into
 * the Sheet the first time the app runs.
 *
 * No GitHub token or repo access is needed — the vault is self-contained.
 *
 * Deploy: Deploy ▸ New deployment ▸ Web app ▸ Execute as: Me ▸
 *         Who has access: Only myself. See README.md.
 */

var SHEET_NAME = 'snippets';
var HEADERS = ['id', 'name', 'type', 'desc', 'code'];

function doGet() {
  return HtmlService.createHtmlOutputFromFile('Index')
    .setTitle('Code Vault')
    .addMetaTag('viewport', 'width=device-width, initial-scale=1');
}

/* ---------------- storage ---------------- */

// Opens (or creates + seeds) the backing spreadsheet, returns the data sheet.
function getSheet_() {
  var props = PropertiesService.getScriptProperties();
  var id = props.getProperty('SHEET_ID');
  var ss;
  if (id) {
    ss = SpreadsheetApp.openById(id);
  } else {
    ss = SpreadsheetApp.create('Code Vault Data');
    props.setProperty('SHEET_ID', ss.getId());
  }
  var sh = ss.getSheetByName(SHEET_NAME);
  if (!sh) {
    sh = ss.insertSheet(SHEET_NAME);
    sh.getRange(1, 1, 1, HEADERS.length).setValues([HEADERS]);
    seedInto_(sh);
  }
  return sh;
}

// Writes the SEED array (from Seed.gs) into an empty sheet.
function seedInto_(sh) {
  if (typeof SEED === 'undefined' || !SEED.length) return;
  var rows = SEED.map(function (s) {
    return [String(s.id || Date.now()), s.name || '', s.type || '', s.desc || '', s.code || ''];
  });
  sh.getRange(2, 1, rows.length, HEADERS.length).setValues(rows);
}

function rowsToItems_(vals) {
  var out = [];
  for (var r = 1; r < vals.length; r++) {
    if (!vals[r][0]) continue;
    out.push({
      id: String(vals[r][0]),
      name: vals[r][1],
      type: vals[r][2],
      desc: vals[r][3],
      code: vals[r][4]
    });
  }
  return out;
}

function findRow_(sh, id) {
  var ids = sh.getRange(1, 1, Math.max(sh.getLastRow(), 1), 1).getValues();
  for (var r = 1; r < ids.length; r++) {
    if (String(ids[r][0]) === String(id)) return r + 1; // 1-based sheet row
  }
  return -1;
}

/* ---------------- public API (called via google.script.run) ---------------- */

// Returns all snippets as a JSON string.
function getSnippets() {
  var sh = getSheet_();
  return JSON.stringify(rowsToItems_(sh.getDataRange().getValues()));
}

// Adds a snippet; returns the full refreshed list.
function addSnippet(obj) {
  var sh = getSheet_();
  var id = String(Date.now());
  sh.appendRow([id, (obj.name || '').trim(), obj.type || 'BigQuery',
                (obj.desc || '').trim(), obj.code || '']);
  return getSnippets();
}

// Updates an existing snippet by id; returns the full refreshed list.
function updateSnippet(obj) {
  var sh = getSheet_();
  var row = findRow_(sh, obj.id);
  if (row < 0) throw new Error('Snippet not found: ' + obj.id);
  sh.getRange(row, 1, 1, HEADERS.length).setValues([[
    String(obj.id), (obj.name || '').trim(), obj.type || 'BigQuery',
    (obj.desc || '').trim(), obj.code || ''
  ]]);
  return getSnippets();
}

// Deletes a snippet by id; returns the full refreshed list.
function deleteSnippet(id) {
  var sh = getSheet_();
  var row = findRow_(sh, id);
  if (row > 0) sh.deleteRow(row);
  return getSnippets();
}
