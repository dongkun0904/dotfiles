---
name: jira-acli
description: Use when interacting with Jira via the Atlassian CLI (acli) or Confluence via the REST API - view, create, edit, transition, search, or comment on issues. Also read Confluence pages. Activate when user mentions Jira tickets, BUAPP/AIPE/PX issue keys, Confluence pages/URLs, or wants to manage Jira/Confluence from the terminal.
allowed-tools: [Bash, Read, Glob, AskUserQuestion]
user-invocable: true
---

## Overview

Multi-purpose skill for interacting with Jira Cloud using the Atlassian CLI (`acli`) and Confluence Cloud using the REST API. Supports viewing, creating, editing, transitioning, searching, and commenting on Jira issues, as well as reading and searching Confluence pages.

## When to Use

Activate when the user:

1. **Views a Jira issue** - "Show me BUAPP-12345", "What's the status of AIPE-100?"
2. **Creates a Jira issue** - "Create a ticket for this bug", "File a Jira task"
3. **Edits or updates an issue** - "Update the description on BUAPP-123", "Change the assignee"
4. **Adds a comment** - "Add a comment to BUAPP-123", "Comment on this ticket"
5. **Transitions an issue** - "Move BUAPP-123 to In Progress", "Close this ticket"
6. **Searches issues** - "Show my open tickets", "Find bugs in BUAPP project"
7. **Views a Confluence page** - "Read this Confluence page", user pastes a Confluence URL
8. **Searches Confluence** - "Find Confluence pages about authentication", "Search Confluence for TRD"

## When NOT to Use

- User is asking general questions about Jira (not CLI operations)
- User wants to create a full JIRA ticket with PR integration (use `/create-jira-ticket-with-claude-pr` instead)

## Authentication

Check authentication before running commands:

```bash
acli jira auth status
```

If not authenticated, automatically authenticate using the `ATLASSIAN_USERNAME` and `ATLASSIAN_TOKEN` environment variables with a here-string (`<<<`):

```bash
acli jira auth login --site "betterup.atlassian.net" --email "$ATLASSIAN_USERNAME" --token <<< "$ATLASSIAN_TOKEN"
```

**IMPORTANT:** Do NOT use `echo "$TOKEN" | acli ... --token` — it fails with "failed to read token from standard input". Always use the here-string syntax (`<<<`) shown above.

If the env vars are not set, inform the user they need to define `ATLASSIAN_USERNAME` and `ATLASSIAN_TOKEN` in their shell environment.

## Command Reference

### View an Issue

```bash
acli jira workitem view BUAPP-12345
```

### Create an Issue

```bash
acli jira workitem create \
  --project BUAPP \
  --type Task \
  --summary "Summary here" \
  --description "Description here"
```

For rich descriptions, use ADF JSON with `--from-json` (see ADF section below).

### Edit an Issue

```bash
acli jira workitem edit BUAPP-12345 --summary "Updated summary"
acli jira workitem edit BUAPP-12345 --assignee "user@betterup.co"
```

### Add a Comment

```bash
acli jira workitem comment add BUAPP-12345 --body "Comment text here"
```

For rich comments, use ADF JSON with `--from-json`.

### Transition an Issue

Always list available transitions first, then transition:

```bash
# List available transitions
acli jira workitem transition list BUAPP-12345

# Transition to a status
acli jira workitem transition BUAPP-12345 --name "In Progress"
```

### Search Issues (JQL)

```bash
# My open tickets
acli jira workitem list --jql "assignee = currentUser() AND status != Done"

# Project-scoped search
acli jira workitem list --jql "project = BUAPP AND status = 'In Progress'"

# Search by text
acli jira workitem list --jql "project = BUAPP AND text ~ 'search term'"
```

### List Sprints

```bash
acli jira board sprint list --board-id 123
```

## ADF (Atlassian Document Format) - CRITICAL

**ALWAYS use ADF JSON via `--from-json` for descriptions and comments.** Do NOT use wiki markup or markdown — they render as plain text in Jira.

### ADF Structure

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "Section Title" }]
    },
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "Paragraph text here." }]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [{ "type": "text", "text": "List item 1" }]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [{ "type": "text", "text": "List item 2" }]
            }
          ]
        }
      ]
    },
    {
      "type": "codeBlock",
      "attrs": { "language": "ruby" },
      "content": [{ "type": "text", "text": "puts 'hello'" }]
    }
  ]
}
```

### ADF Node Types

| Node | Purpose | Notes |
|------|---------|-------|
| `doc` | Root element | Must have `version: 1` |
| `paragraph` | Text block | Contains inline text nodes |
| `heading` | Section heading | `attrs.level`: 1-6 |
| `bulletList` | Unordered list | Contains `listItem` nodes |
| `orderedList` | Numbered list | Contains `listItem` nodes |
| `listItem` | List entry | Must contain a `paragraph` |
| `codeBlock` | Code snippet | `attrs.language` for syntax highlighting |
| `blockquote` | Quote block | Contains paragraphs |
| `table` | Table | Contains `tableRow` > `tableHeader`/`tableCell` |

### Inline Text Marks

```json
{
  "type": "text",
  "text": "bold text",
  "marks": [{ "type": "strong" }]
}
```

Available marks: `strong` (bold), `em` (italic), `code` (inline code), `link` (with `attrs.href`).

## Team Assignment

When creating tickets, look up the team ID from `config/teams/` YAML files:

1. Find the team file: `config/teams/squad_<team_name>.yml`
2. Extract the `jira.team_id` value
3. Pass it as `customfield_10001` in additional fields

## Custom Fields

| Field | Custom Field ID | Description |
|-------|----------------|-------------|
| Team | `customfield_10001` | Squad/team assignment (UUID) |
| Sprint | `customfield_10010` | Sprint assignment |

## Output

After any operation, always provide:
- The Jira web link: `https://betterup.atlassian.net/browse/<ISSUE_KEY>`
- A summary of what was done
- Any relevant field values (status, assignee, etc.)

## Confluence Operations

The `acli confluence` command only supports space-level operations (list, view, create spaces). For **page-level operations**, use the Confluence REST API directly via `curl` with the same `ATLASSIAN_USERNAME` and `ATLASSIAN_TOKEN` environment variables.

### Extracting a Page ID from a Confluence URL

Confluence URLs follow this pattern:
```
https://betterup.atlassian.net/wiki/spaces/<SPACE_KEY>/pages/<PAGE_ID>/<Page+Title>
```

Extract the numeric `PAGE_ID` from the URL path:
```bash
PAGE_ID=$(echo "$PAGE_URL" | sed -n 's|.*/pages/\([0-9]*\).*|\1|p')
```

### View a Confluence Page

```bash
# Get page metadata and content (storage format - raw HTML/XML)
curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
  "https://betterup.atlassian.net/wiki/api/v2/pages/<PAGE_ID>?body-format=storage"

# Get page with ADF body (structured JSON, better for text extraction)
curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
  "https://betterup.atlassian.net/wiki/api/v2/pages/<PAGE_ID>?body-format=atlas_doc_format"
```

**Tip:** Pipe through `python3 -m json.tool` for readable output, or use `python3 -c` to extract specific fields.

### Extract Readable Text from a Confluence Page

```bash
curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
  "https://betterup.atlassian.net/wiki/api/v2/pages/<PAGE_ID>?body-format=atlas_doc_format" \
  | python3 -c "
import json, sys
d = json.load(sys.stdin)
print('Title:', d.get('title', ''))
print('Status:', d.get('status', ''))
print()
body = d.get('body', {}).get('atlas_doc_format', {}).get('value', '{}')
doc = json.loads(body)
def extract_text(node):
    texts = []
    if isinstance(node, dict):
        if node.get('type') == 'text':
            texts.append(node.get('text', ''))
        for child in node.get('content', []):
            texts.extend(extract_text(child))
    return texts
print(' '.join(extract_text(doc)))
"
```

### Search Confluence Pages by Title

```bash
curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
  "https://betterup.atlassian.net/wiki/api/v2/pages?title=<URL_ENCODED_TITLE>&limit=10"
```

### Search Confluence with CQL (Confluence Query Language)

```bash
# Search by title
curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
  "https://betterup.atlassian.net/wiki/rest/api/search?cql=title%3D%22<TITLE>%22&limit=10"

# Search by text content
curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
  "https://betterup.atlassian.net/wiki/rest/api/search?cql=text~%22<SEARCH_TERM>%22&limit=10"

# Search within a specific space
curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
  "https://betterup.atlassian.net/wiki/rest/api/search?cql=space%3D%22ET%22+AND+text~%22<SEARCH_TERM>%22&limit=10"
```

### Get Page Comments

```bash
curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
  "https://betterup.atlassian.net/wiki/api/v2/pages/<PAGE_ID>/footer-comments?body-format=storage"
```

### Get Page Child Pages

```bash
curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
  "https://betterup.atlassian.net/wiki/api/v2/pages/<PAGE_ID>/children?limit=25"
```

### Confluence Space Operations (via acli)

```bash
# List spaces (uses acli)
acli confluence space list

# View space details
acli confluence space view --id <SPACE_ID>
```

## Reference

- Jira CLI documentation: https://developer.atlassian.com/cloud/acli/reference/commands/
- Confluence REST API v2: https://developer.atlassian.com/cloud/confluence/rest/v2/intro/
