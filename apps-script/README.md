# Code Vault — Google Apps Script web app

A private replacement for the htmlpreview/gist version. Apps Script serves the
page from a stable URL and reads this repo **server-side**, so:

- No CORS proxy, no `htmlpreview` 429 rate-limit failures.
- The GitHub token stays on the server — **the repo can be private**.
- Access can be locked to your Google account only.

## Files

| File | Apps Script name | Purpose |
|------|------------------|---------|
| `Code.gs` | `Code.gs` | `doGet` + server-side GitHub reads (`getManifest`, `getContent`) |
| `Index.html` | `Index.html` | the vault UI (search, category chips, cards, code viewer) |

## Deploy (manual, ~5 min)

1. Go to <https://script.google.com> ▸ **New project**.
2. Paste `Code.gs` over the default `Code.gs`.
3. **＋ ▸ HTML** → name it exactly `Index` → paste `Index.html`.
4. **Project Settings (⚙) ▸ Script Properties ▸ Add script property**:
   | Property | Value | Required |
   |----------|-------|----------|
   | `GH_OWNER` | `parepiy` | optional (default) |
   | `GH_REPO` | `my-code-vault` | optional (default) |
   | `GH_BRANCH` | `main` | optional (default) |
   | `GH_TOKEN` | a fine-grained PAT | **only if the repo is private** |
5. **Deploy ▸ New deployment ▸ Web app**
   - *Execute as*: **Me**
   - *Who has access*: **Only myself** (or *Anyone with the link* if you want it shareable)
6. Authorize when prompted, then open the `/exec` URL. Bookmark it.

### GitHub token (private repo only)

Create a **fine-grained** PAT at
<https://github.com/settings/personal-access-tokens/new>:
- Repository access → **Only select repositories** → `my-code-vault`
- Permissions → **Contents: Read-only**

Paste it into `GH_TOKEN`. It never leaves the server. With the token set you can
switch the repo back to **private** and the vault keeps working.

## Deploy with clasp (optional, from this folder)

```bash
npm i -g @google/clasp
clasp login
clasp create --title "Code Vault" --type webapp --rootDir apps-script
clasp push
```

Then set Script Properties and deploy from the Apps Script UI as above.
(`clasp` reads `Code.gs`/`Index.html` from this directory.)

## How it works

- `getManifest()` lists the repo tree in one API call, fetches every code file's
  content in parallel (`UrlFetchApp.fetchAll`), derives a **title** from the
  filename, a **category** from the extension (`.sql`→BigQuery, `.bas`→VBA,
  `.m`/`.md`→Power Query), and a **description** from the file's first comment
  line. The result is cached for 6 hours; the **↻** button forces a re-sync.
- `getContent(path)` fetches one file's raw text when you open a card.
- `+ Add` opens the GitHub "new file" page for the repo; commit there and hit ↻.

## Customizing

- Titles/acronyms: edit `ACRONYMS` in `Code.gs`.
- Categories / which file types show up: edit `CATEGORY_BY_EXT`.
- Card icons: edit the `EMOJI` pool.
