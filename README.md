# my-code-vault
i store all my codes here

snippet is chunk of codes store seperately to reuse in the future

## Online vault

`code_vault_online.html` is a self-contained, searchable browser view of all 79
snippets (search, type chips, Add/Edit/Delete, Backup/Settings/Sync, and an
output-example table per snippet). Everything is embedded in the single file.

Hosting (repo must be **public**): open via githack from `main`:

https://raw.githack.com/parepiy/my-code-vault/main/code_vault_online.html

Updates are pushed to `main`; githack serves the latest (hard-refresh to skip
its cache).

### Output examples

Each snippet's popup can show an example of its output, rendered as a table.
Examples are stored **inline** in the snippet's `outCsv` field inside the
`SEED=[...]` array, or added in-app via the Add/Edit form's CSV box.

### Data & backup

Add/Edit/Delete save in the browser (localStorage). Use the **Backup** button to
download a JSON copy, and **Settings** to restore from a `.json` or `.html`
backup.

