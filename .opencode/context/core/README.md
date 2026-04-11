<!-- SUMMARY: Directory index for context/core — universal standards and workflows. LOAD WHEN: You need to find which core standard or workflow file to load. SKIP WHEN: You already know which specific file you need. -->

# context/core — Directory Index

Universal standards and workflows that apply to all development work.

## Files in this directory

| File | Purpose | Load when |
|------|---------|-----------|
| `navigation.md` | Quick route map to all core files | First time orienting in core/ |
| `context-system.md` | How the OAC context system works | You need to understand lazy-loading |
| `essential-patterns.md` | Essential code/review patterns | Writing or reviewing any code |
| `visual-development.md` | UI/visual development guidelines | Working on frontend/UI |

## Subdirectories

| Directory | Contents | Load README when |
|-----------|----------|-----------------|
| `standards/` | Code quality, testing, docs, security, Nix | You need a specific quality standard |
| `workflows/` | Review, delegation, scenarios, task breakdown | You need a process template |
| `system/` | Context metadata, available models, context guide | You need model strings or context system internals |
| `task-management/` | JSON-driven task tracking with CLI | Working with task CLI |
| `context-system/` | Context system operations and guides | Extending the context system |

## Quick routes (most common)

- **Write Nix code** → `standards/nix.md`
- **Write any code** → `standards/code-quality.md`
- **Security patterns** → `standards/security-patterns.md`
- **Review code** → `workflows/code-review.md`
- **Delegate a task** → `workflows/task-delegation-basics.md`
- **Scenarios/modes** → `workflows/scenarios.md`
- **Find model strings** → `system/available-models.md`
