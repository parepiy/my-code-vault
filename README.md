# my-code-vault
i store all my codes here

snippet is chunk of codes store seperately to reuse in the future

## Online vault

`code_vault_online.html` is a self-contained, searchable browser view of all 79
snippets. Everything — snippets and their example outputs — is embedded in the
single file, so it works from a **gist** (repo can stay private) or opened locally.

Hosting: paste the file into a gist and open it via githack, e.g.
`https://gist.githack.com/<user>/<gist-id>/raw/code_vault_online.html`.
This file in the repo is the source of truth; copy it into the gist after changes.

### Output examples

Each snippet's popup can show an example of its output, rendered as a table.
Examples are stored **inline** in the snippet's `outCsv` field inside the
`D=[...]` array (paste the CSV text there). No external files needed.

