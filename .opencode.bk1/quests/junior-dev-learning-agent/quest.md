<!-- SUMMARY: Design and implement a learning agent to onboard junior developers on Nix, NiXium standards, and project concepts. LOAD WHEN: Building educational agents or onboarding tooling. SKIP WHEN: Not working on learning/education tooling. -->

# Quest: Junior Developer Learning Agent

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Open |
| **Priority** | Medium |
| **Created** | 2026-05-01 |
| **Updated** | 2026-05-01 |
| **Assigned** | TBD |

## Problem

NiXium has a steep learning curve: flake-parts architecture, Nx coding standards, security-hardened workflows, and project-specific conventions (AGENTS.md, MEMORY.md, quest system). Junior developers joining the project face significant friction — they must simultaneously learn Nix, NiXium's non-standard architecture, and strict coding standards before they can contribute meaningfully.

There is no structured, interactive way to onboard new contributors. They must read AGENTS.md, MEMORY.md, Nx standard, and multiple quests piecemeal, without validation that they understand the material.

## Context

NiXium is not standard NixOS — it uses flake-parts, explicit imports, and has extensive documentation:

- **AGENTS.md**: Critical architecture overview (flake-parts, not standard NixOS)
- **MEMORY.md**: Cross-session discoveries and gotchas
- **docs/nx/standard.md**: Nx Language Standard (tabs, shell scripting rules)
- **Quest system**: Structured tracking for features/investigations
- **Context system**: `.opencode/context/` with lazy-loaded documentation

A learning agent should:
1. Teach juniors the **programming languages** they'll encounter (Nix, bash/sh via writeShellApplication, potentially Lua for neovim configs)
2. Teach **core concepts** (flake-parts modules, perSystem, disko, lanzaboote, impermanence, ragenix)
3. Enforce **expected standards** (Nx standard, security hardening, VM-first testing, quest lifecycle)
4. Validate understanding through **interactive exercises** or checks

Existing agent infrastructure (opencode agent system) can be leveraged — this may be a new subagent type or a mode added to OpenAgent.

## Proposed Solution

Create a `JuniorMentor` agent (or equivalent) that:

1. **Assesses current knowledge** — ask juniors what they know (Nix? bash? flake-parts?)
2. **Curates a learning path** — structured modules based on assessed gaps
3. **Delivers interactive lessons** — each lesson covers one topic with examples from NiXium codebase
4. **Validates with exercises** — small, safe tasks (e.g., "create a quest following the template", "write a writeShellApplication script")
5. **References project docs** — pulls from AGENTS.md, Nx standard, quest system as teaching material
6. **Tracks progress** — saves progress to `.opencode/quests/junior-dev-learning-agent/sessions/` or similar

### Alternative Considered

- **Static documentation only**: Rejected — no validation, no interactivity, high dropout rate
- **Add to AGENTS.md**: Rejected — AGENTS.md is reference, not a learning tool
- **Use existing ContextScout**: Rejected — ContextScout discovers context; it doesn't teach

## Implementation

- [ ] Define learning modules (Nix basics, NiXium architecture, Nx standard, security model, VM testing, quest system)
- [ ] Design assessment questions to gauge junior's starting level
- [ ] Create lesson templates with code examples from NiXium codebase
- [ ] Design exercise validation (what constitutes a "pass" for each module)
- [ ] Implement agent logic (or subagent type) for `JuniorMentor`
- [ ] Add progress tracking (session notes in quest directory)
- [ ] Test with a real junior developer and iterate based on feedback
- [ ] Document the agent in `.opencode/context/core/workflows/` if it becomes a standard workflow

## Success Criteria

- [ ] Junior can explain why NiXium uses flake-parts (not standard NixOS) after completing the architecture module
- [ ] Junior can write a Nix config following Nx standard (tabs, writeShellApplication, concatStringsSep) after the standards module
- [ ] Junior can create a properly formatted quest after the quest system module
- [ ] Junior can build and test a VM after the VM testing module
- [ ] Agent tracks progress and resumes from last completed module

## Related Quests

- [foundation-complete](foundation-complete/quest.md) — Foundation documentation that juniors must understand
- [yes-man](yes-man/quest.md) — Agent should challenge, not just agree (relevant to mentor agent behavior)

## Notes

- The agent should be patient and assume zero prior Nix knowledge
- Use real NiXium code examples (e.g., `src/nixos/machines/template/` for architecture lessons)
- Exercises must be safe — no risk of breaking the main NiXium config
- Consider integrating with the existing subagent system (add as new subagent_type in opencode config)
- May benefit from using Context7 skill to fetch current Nix language documentation as teaching material

---

*When updating this quest, also update the `Updated` date in the metadata table.*
