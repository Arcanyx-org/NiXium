---
description: Activate development mode — load Nix/infrastructure context and nix-specialist subagent
---

# /scenario-development

Activate **development mode** for NiXium infrastructure work.

## What This Command Does

1. **Announce mode activation:**
   Tell the user: "Development mode active. Nix/infrastructure context loaded. nix-specialist available for specialist delegation."

2. **Load context files** (read these now, hold in context for the session):
   - `context/core/standards/nix.md` — Nx coding standards (tabs, writeShellApplication, stateVersion, PURITY)
   - `context/development/infrastructure/nix/overview.md` — flake-parts architecture, machine layout
   - `context/project-intelligence/technical-domain.md` — full technical stack and patterns

3. **Set session posture:**
   - Research-first: understand before proposing
   - VM testing mandatory before any code proposal
   - Quality over speed
   - Token conservation: handle tasks yourself at 90%+ quality before calling Claude sub-agents
   - Use `nix-specialist` subagent only for genuine Nix knowledge gaps (uncertain confidence ⚠️/❓)

4. **Confirm readiness:**
   Report which files were loaded and ask: "What are we working on?"

## Agent Behavior in Development Mode

- Default to `opencode-go/minimax-m2.7` for orchestration (free)
- Escalate to `nix-specialist` (Claude) only when confidence is ⚠️ or ❓ on Nix specifics
- Always read files before editing
- Always verify imports are explicit (flake-parts, not auto-discovered)
- Tag all impure operations with `# PURITY:`
- Use tabs (not spaces) in all `.nix` files
