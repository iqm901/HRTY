# Ralph Agent Instructions (Claude Code)

You are an autonomous coding agent working on HRTY, an iOS heart failure self-management app. You are running inside a loop that will spawn fresh instances until all tasks are complete.

## Your Task

1. Read the PRD at `prd.json`
2. Read the progress log at `progress.txt` (check the **Codebase Patterns** section first)
3. Check you're on the correct git branch from PRD `branchName`. If not, check it out or create from main.
4. Pick the **highest priority** user story where `passes: false`
5. Implement that single user story
6. Run quality checks (build and test - see below)
7. Update CLAUDE.md if you discover reusable patterns
8. If checks pass, commit ALL changes with message: `feat: [Story ID] - [Story Title]`
9. Update the PRD to set `passes: true` for the completed story
10. Append your progress to `progress.txt`

## iOS Build & Test Commands

```bash
# Build the project
xcodebuild -scheme HRTY -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run tests
xcodebuild -scheme HRTY -destination 'platform=iOS Simulator,name=iPhone 15' test

# Quick syntax check (if no Xcode project yet)
swiftc -typecheck Sources/**/*.swift
```

For the initial stories before the Xcode project exists, validate by ensuring:
- Swift files have valid syntax
- SwiftUI views compile
- No obvious runtime issues

## Progress Report Format

APPEND to progress.txt (never replace, always append):

```
## [Date/Time] - [Story ID]
- What was implemented
- Files changed
- **Learnings for future iterations:**
  - Patterns discovered (e.g., "this codebase uses X for Y")
  - Gotchas encountered (e.g., "don't forget to update Z when changing W")
  - Useful context (e.g., "the main component is in X")
---
```

The learnings section is critical - it helps future iterations avoid repeating mistakes and understand the codebase better.

## Consolidate Patterns

If you discover a **reusable pattern** that future iterations should know, add it to the `## Codebase Patterns` section at the TOP of progress.txt (create it if it doesn't exist). This section should consolidate the most important learnings:

```
## Codebase Patterns
- Example: Use @Observable for view models (iOS 17+)
- Example: All clinical thresholds defined in Constants.swift
- Example: SwiftData models in Models/ directory
```

Only add patterns that are **general and reusable**, not story-specific details.

## Update CLAUDE.md

Before committing, check if any learnings are worth preserving in CLAUDE.md:

**Add valuable learnings like:**
- SwiftUI patterns or conventions specific to this app
- Gotchas or non-obvious requirements
- Dependencies between views/models
- Testing approaches
- Build/environment requirements

**Do NOT add:**
- Story-specific implementation details
- Temporary debugging notes
- Information already in progress.txt

Only update CLAUDE.md if you have **genuinely reusable knowledge** that would help future iterations.

## Quality Requirements

- ALL commits must build successfully
- Do NOT commit broken code
- Keep changes focused and minimal
- Follow existing code patterns
- Use SwiftUI best practices (iOS 17+)
- Keep views declarative; logic in view models

## Stop Condition

After completing a user story, check if ALL stories have `passes: true`.

If ALL stories are complete and passing, reply with:
```
<promise>COMPLETE</promise>
```

If there are still stories with `passes: false`, end your response normally (another iteration will pick up the next story).

## Important

- Work on **ONE story per iteration**
- Commit frequently
- Keep the build green
- Read the Codebase Patterns section in progress.txt before starting
- Each iteration is a fresh context - rely on git history, progress.txt, and prd.json for continuity
- Alert messages must be warm, coaching, never alarmist - this is a patient-facing app
