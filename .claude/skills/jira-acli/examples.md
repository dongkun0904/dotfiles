## Example 1: View a Jira Issue

**User request:**
> Show me BUAPP-12345

**Expected behavior:**
1. Run `acli jira workitem view BUAPP-12345`
2. Present key fields: summary, status, assignee, description, priority
3. Provide web link: `https://betterup.atlassian.net/browse/BUAPP-12345`

---

## Example 2: Create a Bug Ticket

**User request:**
> Create a Jira bug for the login page crash when the session expires

**Expected behavior:**
1. Ask the user for the project key if not specified
2. Look up the team from `config/teams/` if the user mentions a squad
3. Construct the ticket with ADF description using `--from-json`:

```bash
acli jira workitem create --project BUAPP --type Bug \
  --summary "[Frontend] Fix login page crash on session expiry" \
  --from-json '{
    "description": {
      "type": "doc",
      "version": 1,
      "content": [
        {
          "type": "heading",
          "attrs": {"level": 3},
          "content": [{"type": "text", "text": "Background"}]
        },
        {
          "type": "paragraph",
          "content": [{"type": "text", "text": "The login page crashes when the user session expires mid-interaction."}]
        },
        {
          "type": "heading",
          "attrs": {"level": 3},
          "content": [{"type": "text", "text": "Acceptance Criteria"}]
        },
        {
          "type": "bulletList",
          "content": [
            {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Session expiry redirects to login page without crash"}]}]},
            {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Error boundary catches the failure gracefully"}]}]}
          ]
        }
      ]
    },
    "labels": ["ai-generated-ticket", "bug-fix", "frontend"]
  }'
```

4. Return the web link to the created ticket

---

## Example 3: Transition a Ticket

**User request:**
> Move BUAPP-456 to In Progress

**Expected behavior:**
1. List available transitions first:
   ```bash
   acli jira workitem transition list BUAPP-456
   ```
2. Find the matching transition name (e.g., "In Progress")
3. Execute the transition:
   ```bash
   acli jira workitem transition BUAPP-456 --name "In Progress"
   ```
4. Confirm the transition was successful

---

## Example 4: Search for Open Tickets

**User request:**
> Show me my open tickets in the AIPE project

**Expected behavior:**
1. Run JQL search:
   ```bash
   acli jira workitem list --jql "project = AIPE AND assignee = currentUser() AND status != Done ORDER BY updated DESC"
   ```
2. Present results as a summary table with key, summary, status, and priority

---

## Example 5: Add a Comment with Rich Formatting

**User request:**
> Add a comment to BUAPP-789 saying the fix is deployed to staging

**Expected behavior:**
1. Use ADF JSON for the comment:
   ```bash
   acli jira workitem comment add BUAPP-789 --from-json '{
     "body": {
       "type": "doc",
       "version": 1,
       "content": [
         {
           "type": "paragraph",
           "content": [
             {"type": "text", "text": "The fix has been ", "marks": []},
             {"type": "text", "text": "deployed to staging", "marks": [{"type": "strong"}]},
             {"type": "text", "text": " and is ready for QA verification."}
           ]
         }
       ]
     }
   }'
   ```
2. Confirm the comment was added
3. Provide the ticket web link

---

## Example 6: Update Multiple Fields

**User request:**
> Update BUAPP-321 — change the summary to "Fix caching bug" and assign it to jane.doe@betterup.co

**Expected behavior:**
1. Run edit commands:
   ```bash
   acli jira workitem edit BUAPP-321 --summary "[Backend] Fix caching bug"
   acli jira workitem edit BUAPP-321 --assignee "jane.doe@betterup.co"
   ```
2. Confirm updates were applied
3. Provide the ticket web link

---

## Example 7: Read a Confluence Page from URL

**User request:**
> Read this Confluence page: https://betterup.atlassian.net/wiki/spaces/ET/pages/5621579777/TRD+Dare+to+Lead+Group+Coaching+Time+Preference+Collection

**Expected behavior:**
1. Extract the page ID from the URL (5621579777)
2. Fetch the page content via the Confluence REST API:
   ```bash
   curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
     "https://betterup.atlassian.net/wiki/api/v2/pages/5621579777?body-format=atlas_doc_format" \
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
3. Present the page title and a readable summary of its content
4. Provide the original Confluence URL back to the user

---

## Example 8: Search Confluence for a Topic

**User request:**
> Find Confluence pages about "time preference collection"

**Expected behavior:**
1. Search Confluence using CQL:
   ```bash
   curl -s -u "$ATLASSIAN_USERNAME:$ATLASSIAN_TOKEN" \
     "https://betterup.atlassian.net/wiki/rest/api/search?cql=text~%22time+preference+collection%22&limit=10" \
     | python3 -c "
   import json, sys
   d = json.load(sys.stdin)
   for r in d.get('results', []):
       c = r.get('content', {})
       url = r.get('url', '')
       print(f\"  {c.get('id','')}: {c.get('title','')} [{c.get('type','')}]\")
       if url:
           print(f\"    https://betterup.atlassian.net/wiki{url}\")
   "
   ```
2. Present results as a list with titles and links
3. Offer to read any specific page the user is interested in
