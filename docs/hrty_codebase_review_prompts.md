# HRTY Codebase Review Prompts for Claude Code

## Main Review Prompt

Copy and paste this prompt to initiate a comprehensive codebase review:

```
Review the HRTY codebase - an iOS heart failure management app focused on empowerment through routine and supportive care.

**OUTPUT & CONTEXT MANAGEMENT**
- Save all findings to `CODEBASE_REVIEW.md` in the project root
- Update this file incrementally as you complete each section
- Monitor your context usage. When context drops below 50%:
  1. Save current progress to the markdown file
  2. Add a "## Resume Point" section at the end with:
     - Which sections are complete (with checkmarks)
     - Which section you were working on and where you stopped
     - Specific next steps to continue
     - Any relevant context or findings to carry forward
  3. Instruct me to start a new session with: "Continue the HRTY codebase review from CODEBASE_REVIEW.md - pick up at the Resume Point"

**MARKDOWN FILE STRUCTURE**

# HRTY Codebase Review
Date: [date]
Status: [In Progress / Complete]

## Summary
[High-level findings once complete]

## Test Results
- [ ] All tests passing
- [ ] Test failures: [list]

## Testing Coverage & Health
[findings]

## Architecture & Maintainability
[findings]

## Reliability
[findings]

## User Experience Code Quality
[findings]

## iOS Best Practices
[findings]

## Code Health
[findings]

## Prioritized Recommendations
[ordered list of fixes by impact]

## Resume Point (if incomplete)
- Completed: [sections]
- Current section: [section name]
- Stopped at: [specific location/file]
- Next steps: [what to do next]
- Key context: [anything important to remember]

**ANALYSIS PRIORITIES**

**Testing Coverage & Health**
- Run all existing unit tests and report any failures
- Identify features/modules that lack unit tests
- Check that view models have tests for their core logic
- Verify data persistence and validation logic is tested
- Flag any critical paths (daily tracking, data entry, notifications) without test coverage
- Are tests well-structured and testing meaningful behavior (not just implementation details)?

**Architecture & Maintainability**
- Is the MVVM/SwiftUI architecture clean and consistent?
- Are views, view models, and data layers properly separated?
- Any circular dependencies or tightly coupled components?

**Reliability (critical for health app)**
- Data persistence issues that could lose user entries?
- Edge cases in daily tracking flows?
- Proper error handling for network/storage failures?
- State management issues that could cause unexpected behavior?

**User Experience Code Quality**
- Animation or transition code that could cause jank?
- Accessibility support (VoiceOver, Dynamic Type) for users who may have visual or motor challenges?
- Proper keyboard handling and input validation?

**iOS Best Practices**
- Memory leaks or retain cycles?
- Proper use of @State, @StateObject, @ObservedObject, @EnvironmentObject?
- Any deprecated APIs or iOS version compatibility issues?

**Code Health**
- Duplicated logic that should be extracted?
- Overly complex functions that need breaking up?
- Naming clarity and consistency?
- Missing or outdated comments?

Start by running `xcodebuild test` (or the appropriate test command) and report results. Prioritize all findings by user impact. For each issue, explain the risk and provide a concrete fix. For missing tests, provide example test cases I should add.
```

---

## Continuation Prompt

Use this when starting a new session after context dropped:

```
Continue the HRTY codebase review from CODEBASE_REVIEW.md - pick up at the Resume Point section and continue from where you left off.
```

---

## Follow-Up Prompts

### Refactoring Priorities

```
Now suggest 3 refactoring projects I could do iteratively to improve the codebase health, ordered by effort-to-impact ratio.
```

### Quick Health Check

```
Do a quick code quality audit. What are the top 5 things I should fix or improve in this codebase?
```

### Architecture Deep Dive

```
Review the architecture of this codebase. Are there separation of concerns issues, circular dependencies, or patterns that will make this hard to maintain as it grows? Suggest refactoring opportunities.
```

---

## Notes

- The main prompt is designed to be resumable across multiple Claude Code sessions
- All findings are saved incrementally to `CODEBASE_REVIEW.md` in your project root
- The review prioritizes reliability and testing given HRTY is a health-focused app
- Adjust the test command (`xcodebuild test`) if your project uses a different test runner
