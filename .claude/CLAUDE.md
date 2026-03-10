# CLAUDE.md

## Linear Workflow

### Before starting any ticket
1. Pull the ticket from Linear: use `Linear:get_issue` with the issue ID
2. Read comments on the immediately preceding ticket (e.g. if starting POW-9, read POW-8 comments) using `Linear:list_comments` — look for handoff notes left by the previous agent
3. Read the full description, acceptance criteria, technical notes
4. Set the ticket status to **In Progress** via `Linear:save_issue`

### Branch naming

- Always create a new branch before starting any implementation
- Branch name format: `feature/{ticket-id}-{short-description}` (use `gitBranchName` field from Linear exactly)
- If the current ticket **depends on** (is blocked by) a previous ticket that is not yet merged, branch off that ticket's branch instead of `main`
  - Check the ticket's "Blocked by" field in Linear to determine the parent branch
- Otherwise always branch from `main`

### Committing

After implementation is verified (build passes):

- Use **atomic commits**: group logically related files into one commit — do not commit file-by-file, but also do not dump all changes in a single commit if they span unrelated concerns
- Follow **Conventional Commits** format:
  - `feat(scope): description` — new feature
  - `fix(scope): description` — bug fix
  - `refactor(scope): description` — code restructure without behavior change
  - `chore(scope): description` — tooling, deps, config
  - `docs(scope): description` — documentation only
  - Scopes for this project: `schema`, `auth`, `todos`, `attachments`, `ui`, `sync`, `config`
- Keep commit messages concise — describe *what* changed and *why*, not *how*
- Example groupings for a Flutter ticket:
  - Commit 1: `feat(schema): add AttachmentTable to PowerSync schema`
  - Commit 2: `feat(attachments): implement SupabaseStorageAdapter`
  - Commit 3: `feat(ui): add photo upload button and attach flow`

### While working
- Add implementation notes as comments via `Linear:save_comment`
- If a blocker is discovered, add a comment with the blocker details and leave status as In Progress

### After completing a ticket
1. Run `flutter-verify` skill — analyze + build must pass
2. Post a completion comment using this structure:

   **What was built**
   - {Bullet list of features/files implemented}

   **Key files changed**
   - `{file path}` — {what changed}

   **Verification**
   - ✅ flutter analyze — clean
   - ✅ flutter build apk --debug — success

   **Handoff notes**
   - {Context the next ticket needs: providers added, patterns used, fields introduced}
   - {Any deviations from the original spec and why}

   > Formatting rule: wrap all code references in backticks — field names, model names, function names, file paths, CLI commands.

3. Set status to **In Review** (needs human review)
4. Create atomic commits following Conventional Commits (see "Committing" section)
5. Push the branch and open a GitHub PR to `main` using `pr-finish` skill
6. Post the PR URL as a follow-up comment on the Linear ticket via `Linear:save_comment`

### Finding your next ticket
- Work in phase/milestone order: Phase 1 → Phase 2 → Phase 3 → Phase 4
- Within a phase, work tickets in numeric order unless a specific one is unblocked earlier
- Use `Linear:list_issues` filtered by project + state=Todo to find next work
- Pull the full ticket with `Linear:get_issue` before starting — never work from memory alone

### Known parallel groups
These tickets are independent and can run simultaneously in separate worktrees:
- **Phase 3:** POW-14 + POW-15 (storage adapter + queue init)
- **Phase 4:** POW-19 + POW-21 + POW-22 (error handler, UI badges, cache config)

### Status meanings
| Status | Meaning |
|---|---|
| Backlog | Not yet scheduled |
| Todo | Scheduled for current session |
| In Progress | Actively being worked on |
| In Review | Built, awaiting human review |
| Done | Verified complete |
| Canceled | Descoped or not needed |

## GitHub Workflow

### Creating a PR

After all commits are pushed, open a GitHub PR targeting `main`:

**Title format:** `[{TICKET-ID}] {ticket title}`
- Example: `[POW-14] Implement Supabase Storage remote adapter`

**PR description format:**

```
## Overview
{1–2 sentences describing what this PR does and why}

## Changes
- `{file or area}` — {what changed}

## Testing
- flutter analyze — clean
- flutter build apk --debug — passes
- {any manual steps to verify}

## Notes
{Optional: deviations from spec, caveats. Omit if nothing notable.}

## Linear
{Linear ticket URL}
```

- After the PR is created, post its URL as a **separate comment** on the Linear ticket
- Use `Linear:save_comment` with the PR URL and a one-line summary