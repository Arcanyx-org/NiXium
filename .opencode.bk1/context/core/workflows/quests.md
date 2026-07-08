<!-- Context: workflows/quests | Priority: medium | Version: 1.0 | Updated: 2026-04-13 -->

# Quest Workflow

## What Are Quests?

Quests track features, investigations, and improvements that require planning before execution. They are NOT for simple bug fixes or one-line changes — they're for work that benefits from structured tracking across sessions.

## When to Create a Quest

**Create a quest when:**
- A problem requires research before implementation
- A decision needs to be documented with rationale
- A feature needs planning across multiple sessions
- An anti-pattern needs to be documented as a standard
- An investigation needs structured tracking

**Do NOT create a quest when:**
- A simple bug fix can be done immediately
- A one-line change doesn't need planning
- The work is trivial and won't benefit from tracking

## Quest Directory Structure

```
.opencode/quests/
├── README.md              # Quest index and lifecycle documentation
├── _template.md           # Template for creating new quests
├── <quest-slug>/          # Each quest has its own directory
│   ├── quest.md           # Main quest document (required)
│   ├── sessions/          # Session notes from work on this quest
│   ├── research/          # Research materials, analysis, findings
│   └── ...                # Any other relevant materials
```

## Creating a New Quest

1. Choose a descriptive kebab-case slug (e.g., `post-quantum-crypto`, `write-shell-app-ksh-shfmt`)
2. Create directory: `.opencode/quests/<slug>/`
3. Copy `_template.md` to `<slug>/quest.md`
4. Fill in the template:
   - **SUMMARY head-note**: One-line description for lazy loading
   - **Metadata table**: Status, Priority, Created/Updated dates, Assigned
   - **Problem**: What's wrong or missing
   - **Context**: Background information
   - **Proposed Solution**: Your approach
   - **Implementation**: Checklist of steps
   - **Success Criteria**: Measurable outcomes
   - **Related Quests**: Links to related work
5. Add entry to the appropriate table in `README.md`

## Quest Status Lifecycle

```
Open → In Progress → Decided / Implemented / Complete
                    ↓
                 Cancelled
```

| Status | Meaning | When to Use |
|--------|---------|-------------|
| **Open** | Problem identified, solution not yet started | New quests |
| **In Progress** | Actively being worked on | When you start implementation |
| **Decided** | Decision made, no code changes needed | Pattern/standard established |
| **Implemented** | Code changes made and merged | When PR is merged |
| **Complete** | Fully resolved, no further action | When all success criteria met |
| **Cancelled** | No longer relevant or superseded | When quest becomes obsolete |

### Status Transition Rules

- **Open → In Progress**: When you start actively working on the quest
- **In Progress → Decided**: When the outcome is a decision/pattern, not code
- **In Progress → Implemented**: When code changes are merged
- **Implemented → Complete**: When all success criteria are verified
- **Any → Cancelled**: When the quest is no longer relevant

## Session Notes

When working on a quest across multiple sessions, add session notes to `sessions/`:

```
sessions/
├── 2026-04-13-initial-research.md
├── 2026-04-14-vm-testing.md
└── 2026-04-15-implementation.md
```

### Session Note Format

```markdown
# Session: [Brief Description]

**Date:** YYYY-MM-DD
**Duration:** X hours
**Status:** [What was accomplished]

## What Was Done
- [List of actions taken]

## Findings
- [Key discoveries]

## Decisions Made
- [Decisions with rationale]

## Next Steps
- [What to do next session]

## Blockers
- [Anything preventing progress]
```

## Research Materials

Store research materials in `research/`:

```
research/
├── analysis.md           # Detailed analysis
├── brainstorm-notes.md   # Brainstorming output
├── comparison-matrix.md  # Comparison tables
└── references.md         # Links and citations
```

## Head-Notes (SUMMARY)

Every `quest.md` MUST start with a `<!-- SUMMARY -->` head-note for lazy loading by ContextScout:

```markdown
<!-- SUMMARY: Brief description of what this quest is about. LOAD WHEN: When to load this quest. SKIP WHEN: When to skip this quest. -->
```

This allows the context system to efficiently discover relevant quests without reading every file.

## Updating Quests

When updating a quest:
1. **Always update the `Updated` date** in the metadata table
2. **Add session notes** for significant work sessions
3. **Update status** when transitioning between lifecycle stages
4. **Update README.md** if the quest moves between priority tables
5. **Add findings** to `research/` as you discover them

## Quest Naming Conventions

- **Directory names**: `kebab-case` (e.g., `post-quantum-crypto`)
- **Quest files**: Always `quest.md` inside the directory
- **Session files**: `sessions/YYYY-MM-DD-description.md`
- **Research files**: `research/topic.md`

## Relationship to Other Systems

- **Context System**: Quests are discoverable via ContextScout through their SUMMARY head-notes
- **Task Management**: Quests are NOT tasks — they're higher-level tracking. Use TaskManager for implementation breakdown
- **MEMORY.md**: Cross-session discoveries from quests should be added to MEMORY.md
- **AGENTS.md**: Coding standards discovered through quests should be added to AGENTS.md