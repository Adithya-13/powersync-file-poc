# AGENTS.md

This repository uses **Linear-driven development**. Every change must map to a Linear ticket.

---

# General Agent Behavior

You are a **partner**, not just an executor.

- Think critically before acting
- Ask questions when something is unclear
- Before ANY change: read existing code first
- Before creating new files/functions: check existing patterns
- Explain what current code does before modifying it
- Ask confirmation before large refactors

Be extremely concise.

---

# Architecture Rules

Follow existing architecture and patterns.

Do NOT:
- invent new patterns
- create new folders without reason
- break existing architecture

Flutter default architecture:

- Feature-first structure
- Clean Architecture
- Riverpod state management

---

# Code Standards

Always:

- follow existing naming and formatting
- keep functions small and modular
- prefer simple solutions
- handle errors properly
- never hardcode secrets
- use env variables

---

# Linear Workflow

## Before starting a ticket

1. Pull the ticket from Linear using `Linear:get_issue`
2. Read comments on the previous ticket
3. Understand:
   - description
   - acceptance criteria
   - technical notes
4. Set ticket status → **In Progress**

---

# Branch Naming

Always create a branch before implementation.

Branch format:

feature/{ticket-id}-{short-description}

Use `gitBranchName` from Linear.

Branching rules:

- If ticket depends on another ticket → branch from that ticket branch
- Otherwise branch from `main`

---

# Commits

Use **atomic commits**.

Follow **Conventional Commits**.

feat(scope): description  
fix(scope): description  
refactor(scope): description  
chore(scope): description  
docs(scope): description  

Scopes used in this project:

schema  
auth  
todos  
attachments  
ui  
sync  
config  

Example:

feat(schema): add AttachmentTable to PowerSync schema  
feat(attachments): implement SupabaseStorageAdapter  
feat(ui): add photo upload flow  

Rules:

- commits grouped by logical change
- concise messages
- explain WHAT and WHY

---

# While Working

If a blocker appears:

- comment on Linear
- keep status **In Progress**

Add implementation notes to Linear comments.

---

# Completing a Ticket

Before finishing run verification:

flutter analyze  
flutter build apk --debug  

Both must pass.

---

# Completion Comment Format

### What was built

- bullet list of implemented features

### Key files changed

- `file/path.dart` — description

### Verification

- ✅ flutter analyze — clean
- ✅ flutter build apk --debug — success

### Handoff notes

- patterns used
- providers introduced
- context for next ticket

Formatting rule: wrap all code references in backticks.

---

# After Completion

1. Set Linear status → **In Review**
2. Push branch
3. Open GitHub PR to `main`
4. Post PR URL as Linear comment

---

# PR Format

Title:

[TICKET-ID] ticket title

Example:

[POW-14] Implement Supabase Storage remote adapter

PR description:

## Overview
Short explanation of change.

## Changes
- file or module changed

## Testing
flutter analyze — clean  
flutter build apk --debug — success  

## Notes
Optional deviations from spec.

## Linear
Linear ticket URL

---

# Ticket Order

Work by **phase order**:

Phase 1 → Phase 2 → Phase 3 → Phase 4

Within a phase:

- work in numeric order
- unless another ticket becomes unblocked

---

# Parallel Tickets

Phase 3  
POW-14  
POW-15  

Phase 4  
POW-19  
POW-21  
POW-22  

---

# Status Meaning

Backlog → not scheduled  
Todo → ready to work  
In Progress → active  
In Review → awaiting human review  
Done → verified  
Canceled → removed