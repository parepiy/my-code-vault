# Code Vault — Google Apps Script web app

A private, self-contained version of the code vault. Apps Script serves the page
from a stable URL and stores snippets in a **Google Sheet** it creates for you,
so:

- No htmlpreview / CORS proxy, no rate-limit "failed to fetch".
- **Add / Edit / Delete** work and persist (the old gist/backup was read-only).
- Access can be locked to your Google account only.
- No GitHub token or repo access needed — the vault owns its own data.

## Files

| File | Apps Script name | Purpose |
|------|------------------|---------|
| `Code.gs` | `Code.gs` | `doGet` + Sheet-backed `getSnippets` / `addSnippet` / `updateSnippet` / `deleteSnippet` |
| `Seed.gs` | `Seed.gs` | your existing **79 snippets**, loaded into the Sheet on first run |
| `Index.html` | `Index.html` | the UI — search, type chips, cards, view/copy, add/edit/delete |

## Deploy (~4 min)

1. Go to <https://script.google.com> ▸ **New project** (or use the one you started).
2. Paste `Code.gs` over the default `Code.gs`.
3. **＋ ▸ Script** → name it `Seed` → paste `Seed.gs`.
4. **＋ ▸ HTML** → name it exactly `Index` → paste `Index.html`.
5. **Deploy ▸ New deployment ▸ Web app**
   - *Execute as*: **Me**
   - *Who has access*: **Only myself** (or *Anyone with the link* to share)
6. Click **Authorize access** and allow the Sheets/Drive scopes (needed so it can
   create and read your data Sheet). Open the `/exec` URL and bookmark it.

On first load it creates a spreadsheet called **"Code Vault Data"** in your Drive
and fills it with your 79 snippets. After that the web app reads and writes that
Sheet. You can also edit snippets directly in the Sheet if you prefer.

> The `GH_TOKEN` / `GH_*` script properties from the earlier GitHub-based version
> are **not used** here — you can leave them or delete them.

## How it works

- `getSnippets()` returns every row of the `snippets` sheet as
  `{id, name, type, desc, code}`.
- `addSnippet` / `updateSnippet` / `deleteSnippet` mutate the Sheet and return the
  refreshed list; the UI re-renders from it.
- Each card's emoji is derived from its `id` (same scheme as your original), so
  icons stay stable.
- The backing spreadsheet id is remembered in Script Properties (`SHEET_ID`).

## Customizing

- Change the emoji pool: edit `E` in `Index.html`.
- Change the type options in the Add/Edit form: edit the `<select id="ftype">`.
- Re-seed from scratch: delete the "Code Vault Data" spreadsheet **and** the
  `SHEET_ID` script property, then reload — it rebuilds from `Seed.gs`.

## Backup

The Sheet is your live data. To snapshot it, **File ▸ Download** it from Google
Sheets, or keep exporting the standalone HTML backup as before.
