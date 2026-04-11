<!-- SUMMARY: Defines operational scenarios/modes for NiXium agents — development mode and attack/security mode. LOAD WHEN: Switching between operational contexts or onboarding a new agent session. SKIP WHEN: Already operating in a confirmed mode and no context switch is needed. -->

# Scenarios / Modes System

NiXium uses an explicit **modes** system to scope what context agents load, which specialists activate, and what constraints apply. This prevents context bloat from loading everything always.

---

## Available Modes

### `development` — Normal Infrastructure Work

**Activates:** Nix coding standards, flake-parts architecture context, nix-specialist subagent  
**Loads:** `context/core/standards/nix.md`, `context/development/infrastructure/nix/overview.md`, `context/project-intelligence/technical-domain.md`  
**Posture:** Collaborative, research-first, quality over speed  
**Command:** `/scenario-development`

**Use when:**
- Writing or reviewing NixOS/Nix configurations
- Adding new machines or modules
- Debugging build failures
- Researching architecture decisions

---

### `attack` — Security Research & Hardening

**Activates:** Zero-trust posture, security-reviewer subagent, pre-authorization framing  
**Loads:** `context/project-intelligence/technical-domain.md` (threat model section), `context/core/system/available-models.md`  
**Posture:** Adversarial, assume compromise, challenge every assumption  
**Command:** `/scenario-attack`

**Use when:**
- Security audits and threat modeling
- Penetration testing NiXium-owned infrastructure
- Reverse engineering owned devices (GPL compliance, EU right-to-repair)
- Reviewing PRs for security anti-patterns
- Incident response

---

## How to Switch Modes

Run the slash command at the start of a session or when context changes:

```
/scenario-development    # Infrastructure work mode
/scenario-attack         # Security research mode
```

---

## Mode Design Principles

1. **Minimal always-loaded context.** Only `navigation.md` is always loaded. Everything else is on-demand.
2. **Modes are additive.** Switching modes loads additional context; it doesn't replace the base navigation.
3. **Modes scope sub-agent selection.** `development` mode prefers `nix-specialist`; `attack` mode prefers `security-reviewer`.
4. **Modes are not security boundaries.** They are organizational/context tools, not access controls.

---

## Extending the Modes System

To add a new mode:
1. Add an entry here documenting what it activates/loads
2. Create `command/scenarios/<mode-name>.md` with the slash command instructions
3. Update `context/core/workflows/README.md` to list the new mode
