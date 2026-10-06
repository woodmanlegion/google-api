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

# Opens a browser; approve the request there. Completes automatically —
# nothing to copy or paste. (The URL is also always printed and saved to
# ~/.config/google-api/last-auth-url.txt, in case nothing auto-opens.)
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
Don't guess the project ID or dig through the Console for it — it's already sitting in
`~/.config/google-api/credentials.json`'s `project_id` field (the same project the OAuth
client itself was registered under).

**Also currently non-functional even with `project_id` set**: `services.list` needs
`https://www.googleapis.com/auth/cloud-platform` or `.../cloud-platform.read-only` — neither
is in `SCOPES`. Fails with "Request had insufficient authentication scopes" otherwise. Adding
`cloud-platform.read-only` would fix this; not done yet because it's a notably broad scope to
grant a personal-use CLI (even read-only, it's project-wide, not limited to Service Usage) —
a deliberate decision to make, not a drive-by scope add like the others in this doc.

## Gmail

```bash
google-api gmail search 'newer_than:7d is:unread' --max 20
google-api gmail read <message-id>
google-api gmail send --to a@b.com --subject "Hi" --body "Hello"
google-api gmail send --to a@b.com --subject "Hi" --body '<p>See attached <img src="cid:photo"></p>' --image /path/to/photo.jpg
google-api gmail labels
```

`gmail send` uses the Gmail API by default — no inline images possible (the API path
only builds a single-part message). If `~/.config/google-api/app.passwd` holds a Gmail
App Password (myaccount.google.com/apppasswords, requires 2-Step Verification), it
switches automatically to SMTP instead, which is required for `--image` (repeatable;
`PATH` or `PATH:CID` — defaults the CID to the filename without extension, reference it
in `--body` as `cid:NAME`). Nothing else about the command changes; `gmail send` with no
`--image` still works the same either way, just over a different transport.

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

No image support here at all — Blogger v3 has no media resource (no upload, no list,
no delete). An image on `blogger.googleusercontent.com` can only be removed via
Blogger's own web UI at `blogger.com/mediamanager`, and unlinking it from a post
(deleting the `<img>` tag, or even deleting the post/blog entirely) does not delete
the file — it stays live at that URL. Don't expect `blogger delete` to touch images.

## Contacts

```bash
google-api contacts list --max 30
google-api contacts search "Alice"
google-api contacts get people/c12345678
google-api contacts create --name "Alice Example" --email a@b.com --phone "+1 555 0100"
google-api contacts update people/c12345678 --note "Private -- do not publish or share."
google-api contacts delete people/c12345678
```

`update` currently only supports `--note` (the Notes/biography field) -- it's the one
write operation this needed so far, not full field coverage. It replaces the whole
Notes field (not append), fetches the current `etag` itself first (People API requires
it for its own optimistic-concurrency check), and needs `get`'s `biographies` field to
read back what's there. `create`/`update`/`delete` all prompt for confirmation unless
`--yes` is passed, same pattern as `blogger`/`calendar`/`gmail`.

## Photos (via Drive)

Lists and searches images stored in Google Drive/Photos. Uses the Drive API
— no separate scope needed. Albums not available; use `google-photos-api`
skill for full Photos Library access (requires Google app verification).

```bash
google-api photos list --max 20
google-api photos search --date 2026-09-13
```

## Related skills

| Skill | Auth | Purpose |
|-------|------|---------|
| `google-maps-api` | API key | Geocode, directions, places |
| `google-photos-api` | OAuth (restricted) | Full Photos Library — albums, search, upload |
| `google-firebase-api` | Service account | Firestore, Realtime DB, Cloud Functions |

## Notes

- Confirms before sending mail, creating calendar events, publishing posts, or deleting — pass `--yes`/`-y` on `gmail send` or `blogger post` to skip it for headless/agent use
- `--json` flag available on most list commands for machine-readable output
- Token stored at `~/.config/google-api/token.json` (chmod 600) — never commit
- For new Google APIs: enable in GCP console, add scope to `SCOPES` in script, re-auth with `auth setup --url-only` + `auth setup --code <redirect-url>`
- Drive search uses Google query syntax e.g. `"mimeType='application/vnd.google-apps.folder'"` not `"type:folder"`
- `docs cat` exports via Drive API as plain text — works on Google Docs, not on uploaded files
- OAuth consent screen must be External with your account added as a test user (Internal only works for Google Workspace orgs)
