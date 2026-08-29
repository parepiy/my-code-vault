# Output examples

Each snippet in `code_vault_online.html` can show an example of its output in the
popup. The vault finds the example **by the snippet's id** — no HTML editing needed.

## To attach an example to a snippet

1. Find the snippet's `id` (it's in the `D=[...]` array inside
   `code_vault_online.html`, e.g. `"id":"1787309637773"`).
2. Add a file to this folder named after that id:
   - **`<id>.csv`** → rendered as a table in the popup (preferred).
   - **`<id>.png`** → shown as an image (used if no `.csv` exists).
3. Commit it. The example appears automatically the next time the card is opened.

Example: `outputs/1787309637773.csv` is the demo for the **CJX Store by DC** snippet.

## Other file types

To link any other file (xlsx, pdf, …) instead of a CSV/PNG, add an `out` field to
that snippet in the `D` array, e.g. `"out":"outputs/myfile.xlsx"`. The popup shows
an "open example" link. (CSV/PNG by id needs no `out` field.)

## Notes

- The vault is served from this repo via githack, so examples load from the same
  place — the repo must stay **public** for them to show.
- CSV tables display up to 50 rows in the popup.
