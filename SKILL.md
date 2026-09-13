---
name: google-api
description: "Unified Google API CLI — Gmail, Calendar, Drive, Sheets, Docs, Tasks, Blogger, Contacts, Photos, Maps. PKCE OAuth, no external dependencies."
metadata:
  {
    "openclaw":
      {
        "emoji": "🔑",
        "requires": { "bins": ["google-api"] },
      },
  }
---

# google-api

Standalone Google API CLI for Termux. PKCE OAuth with localhost redirect — Desktop app client type required. No external dependencies beyond Python 3.8+ stdlib.

## Config files (all in `~/.config/google-api/`)

| File | Purpose |
|------|---------|
| `credentials.json` | OAuth client secret from Google Cloud Console |
| `token.json` | Auto-managed access + refresh token |
| `config.json` | `project_id` (for services cmd), `maps_api_key` |

## Auth (one-time setup)

```bash
# Copy your client_secret.json from Cloud Console
cp /path/to/client_secret.json ~/.config/google-api/credentials.json

# Start device auth — visit the URL shown, enter the short code
google-api auth setup

# Verify
google-api auth status
```

Token auto-refreshes. If it expires hard, re-run `auth setup`.

## Services (Service Usage API)

```bash
# List all enabled APIs on the project
google-api services list --enabled
```

Requires `project_id` in `~/.config/google-api/config.json`:
```json
{ "project_id": "your-project-id" }
```

## Gmail

```bash
google-api gmail search 'newer_than:7d is:unread' --max 20
google-api gmail read <message-id>
google-api gmail send --to a@b.com --subject "Hi" --body "Hello"
google-api gmail labels
```

## Calendar

```bash
google-api calendar cals
google-api calendar events --from 2026-09-09 --to 2026-09-16 --max 20
google-api calendar create --summary "Meeting" --start 2026-09-10T14:00:00Z --end 2026-09-10T15:00:00Z
```

## Drive

```bash
google-api drive search "name contains 'report'" --max 10
google-api drive ls --parent <folder-id>
google-api drive mkdir "New Folder" --parent <parent-id>
google-api drive upload ./video.mp4 --parent <folder-id> --name "video.mp4" --share
google-api drive share <file-id> --to anyone --role reader
google-api drive info <file-id>
```

## Sheets

```bash
google-api sheets get <sheet-id> "Sheet1!A1:D10"
google-api sheets update <sheet-id> "Sheet1!A1:B2" --values-json '[["Name","Score"],["Alice","95"]]'
google-api sheets append <sheet-id> "Sheet1!A:C" --values-json '[["x","y","z"]]'
google-api sheets clear <sheet-id> "Sheet1!A2:Z"
google-api sheets metadata <sheet-id>
```

## Docs

```bash
google-api docs cat <doc-id>
google-api docs export <doc-id> --format pdf --out /tmp/doc.pdf
google-api docs info <doc-id>
```

## Keep

```bash
google-api keep list
google-api keep list --trashed
google-api keep create --title "Idea" --text "Build a thing"
google-api keep create --title "Groceries" --list "Milk,Eggs,Bread"
google-api keep get <note-id>
google-api keep delete <note-id>
```

## Tasks

```bash
google-api tasks lists
google-api tasks list <list-id>
google-api tasks list <list-id> --all
google-api tasks create <list-id> --title "Review PRs" --due 2026-09-10
google-api tasks complete <task-id> <list-id>
google-api tasks clear <list-id>
```

## Blogger

```bash
google-api blogger blogs
google-api blogger posts <blog-id> --max 10
google-api blogger post <blog-id> --title "Hello World" --content "<p>Body</p>"
google-api blogger post <blog-id> --title "Draft" --content "..." --draft
google-api blogger delete <blog-id> <post-id>
```

## Contacts

```bash
google-api contacts list --max 30
google-api contacts search "Alice"
google-api contacts get people/c12345678
```

## Photos

```bash
google-api photos list --max 20
google-api photos albums
google-api photos search --date 2026-09-01
```

## Maps (API key, not OAuth)

Requires `maps_api_key` in `~/.config/google-api/config.json`.

```bash
google-api maps geocode "Dublin, Ireland"
google-api maps directions "Dublin" "Cork" --mode driving
google-api maps places "coffee near Grafton Street"
```

## Notes

- Confirms before sending mail, creating calendar events, publishing posts, or deleting
- `--json` flag available on most list commands for machine-readable output
- Token stored at `~/.config/google-api/token.json` (chmod 600) — never commit
- For new Google APIs: enable in GCP console, add scope to `SCOPES` in script, re-auth with `auth setup --url-only` + `auth setup --code <redirect-url>`
- Drive search uses Google query syntax e.g. `"mimeType='application/vnd.google-apps.folder'"` not `"type:folder"`
- `docs cat` exports via Drive API as plain text — works on Google Docs, not on uploaded files
- Photos requires `photoslibrary.readonly` scope — add to SCOPES and re-auth after enabling Photos Library API in GCP
- Maps requires a separate API key (not OAuth) — set `maps_api_key` in `~/.config/google-api/config.json`
- OAuth consent screen must be External with your account added as a test user (Internal only works for Google Workspace orgs)
