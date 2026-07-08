<!-- SUMMARY: Quest index and lifecycle documentation. LOAD WHEN: Creating, updating, or looking up quests. SKIP WHEN: Not working with quests. -->

# NiXium Quests

Quests track features, investigations, and improvements that require planning before execution.

## Quests vs Tagged Issues

**Quests** (this directory) are **planned work items** with research, context, and success criteria. They live in `.opencode/quests/`.

**Tagged issues** (FIXME, TODO, DNM, etc.) are **inline code annotations** marking problems where they occur. They live in the source code.

When someone says "let's go on a quest" or "pick something to work on", they mean the **quest system** — read this README first, not the codebase tags. If they specifically ask about "FIXME tags" or "code issues", then search the codebase.

## Directory Structure

```
.opencode/quests/
├── README.md              # This file — quest index and lifecycle
├── _template.md           # Template for creating new quests
├── <quest-slug>/          # Each quest has its own directory
│   ├── quest.md           # Main quest document (required)
│   ├── sessions/          # Session notes from work on this quest
│   ├── research/          # Research materials, analysis
│   └── ...                # Any other relevant materials
```

## Active Quests

### High Priority

| Quest | Status | Summary |
|-------|--------|---------|
| [post-quantum-crypto](post-quantum-crypto/quest.md) | Open | Evaluate and implement post-quantum cryptography (Kyber vs NTRU Prime) |
| [claude-system-prompt-analysis](claude-system-prompt-analysis/quest.md) | Open | Analyze Claude restrictions and develop workarounds for legitimate security work |
| [token-budget-crisis](token-budget-crisis/quest.md) | Open | Sustainable AI operations with limited premium token budget |
| [model-evaluation-framework](model-evaluation-framework/quest.md) | Open | Unified model evaluation — restriction testing, instruction compliance, regression detection. Uses deny-based evaluation (plan agent) and mkVM action evaluation. |

### Medium Priority

| Quest | Status | Summary |
|-------|--------|---------|
| [crisis-response-system](crisis-response-system/quest.md) | Open | Design crisis response mode for rapid incident response |
| [trust-tier-architecture](trust-tier-architecture/quest.md) | Open | Multi-agent architecture with trust tiers based on model hosting |
| [restriction-benchmark](restriction-benchmark/quest.md) | Superseded | Systematic benchmark of AI model safety restrictions — merged into model-evaluation-framework |
| [junior-dev-learning-agent](junior-dev-learning-agent/quest.md) | Open | Agent to teach juniors Nix, NiXium standards, and project concepts |

### Decided / Implemented

| Quest | Status | Summary |
|-------|--------|---------|
| [add-shell-standards-to-nx-standard](add-shell-standards-to-nx-standard/quest.md) | Implemented | Add shell script standards to Nx Language Standard |
| [concat-strings-sep-for-config](concat-strings-sep-for-config/quest.md) | Decided | Use `concatStringsSep` instead of multiline strings for config |
| [deadnix-linting](deadnix-linting/quest.md) | Open | Integrate deadnix linting into NiXium's build pipeline |
| [disk-strategy-portability](disk-strategy-portability/quest.md) | Decided | Disk strategy portability — TMPDIR fallback with warning |
| [env-vars-over-command-construction](env-vars-over-command-construction/quest.md) | Decided | Use environment variables over dynamic command construction |
| [inline-scripts-vs-standalone](inline-scripts-vs-standalone/quest.md) | Decided | Scripts >20 lines must be standalone .sh files |
| [module-args-vs-let-inherit](module-args-vs-let-inherit/quest.md) | Decided | Use `let inherit` over `config._module.args` for mkVM |
| [nix-repl-vm-testing](nix-repl-vm-testing/quest.md) | Implemented | Ad-hoc VM testing from nix repl using mkVM |
| [posix-shell-compliance](posix-shell-compliance/quest.md) | Decided | All shell scripts must be strict POSIX sh (ksh compatible) |
| [soft-wraps-in-nix](soft-wraps-in-nix/quest.md) | Open | Comments in Nix must use soft wraps, not hard line breaks |
| [write-shell-app-ksh-shfmt](write-shell-app-ksh-shfmt/quest.md) | Open | NiXium writeShellApplication wrapper — ksh default, shfmt optional |
| [write-shell-application-env](write-shell-application-env/quest.md) | Decided | Use `runtimeEnv` over `builtins.replaceStrings` for variable injection |

### Complete

| Quest | Status | Summary |
|-------|--------|---------|
| [foundation-complete](foundation-complete/quest.md) | Complete | Foundation documentation and OpenCode configuration (Quests 01 & 02) |

## Quest Lifecycle

### Status Progression

```
Open → In Progress → Decided / Implemented / Complete
                    ↓
                 Cancelled
```

- **Open**: Problem identified, solution not yet started
- **In Progress**: Actively being worked on
- **Decided**: Decision made, no code changes needed (pattern/standard established)
- **Implemented**: Code changes made and merged
- **Complete**: Fully resolved, no further action needed
- **Cancelled**: No longer relevant or superseded

### Creating a New Quest

1. Create a directory: `.opencode/quests/<descriptive-slug>/`
2. Copy `_template.md` to `<descriptive-slug>/quest.md`
3. Fill in the template with your quest details
4. Add an entry to the appropriate table in this README
5. Start working — add session notes to `sessions/` as you go

### Quest Directory Contents

Each quest directory can contain:

| File/Dir | Purpose | Required |
|----------|---------|----------|
| `quest.md` | Main quest document | Yes |
| `sessions/` | Session notes from work on this quest | No |
| `research/` | Research materials, analysis, findings | No |
| `brainstorm.md` | Brainstorming notes | No |
| `ANALYSIS.md` | Detailed analysis document | No |

### Naming Conventions

- **Directory names**: Use `kebab-case` (e.g., `post-quantum-crypto`, `write-shell-app-ksh-shfmt`)
- **Quest files**: Always named `quest.md` inside the directory
- **Session files**: `sessions/YYYY-MM-DD-description.md`
- **Research files**: `research/topic.md`

### When to Create a Quest

Create a quest when:
- A problem requires research before implementation
- A decision needs to be documented with rationale
- A feature needs planning across multiple sessions
- An anti-pattern needs to be documented as a standard
- An investigation needs structured tracking

Do NOT create a quest when:
- A simple bug fix can be done immediately
- A one-line change doesn't need planning
- The work is trivial and won't benefit from tracking

## Legacy Quests

Quests 01-08 were created in the legacy `.opencode.legacy/quests/` format and have been ported to the current directory structure. The original files are preserved in `.opencode.legacy/` for reference.

| Legacy # | Current Directory | Original Title |
|-----------|-------------------|----------------|
| 01-02 | `foundation-complete/` | Foundation Documentation & OpenCode Configuration |
| 03 | `post-quantum-crypto/` | Post-Quantum Cryptography Implementation |
| 04 | `crisis-response-system/` | Crisis Response & Permission Override System |
| 05 | `trust-tier-architecture/` | Trust Tier Architecture for Multi-Model Deployment |
| 06 | `restriction-benchmark/` | Model Restriction Benchmark Framework |
| 07 | `claude-system-prompt-analysis/` | Claude System Prompt Analysis & Restriction Management |
| 08 | `token-budget-crisis/` | Token Budget Crisis & Sustainable AI Operations |