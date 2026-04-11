# .opencode Directory - OpenCode Configuration for NiXium

**Purpose:** Optimize AI agent onboarding and collaboration on NiXium infrastructure project

**Target:** Reduce agent confusion from 80 messages/8 hours → 10 messages/5 minutes

---

## Quick Navigation

**For Agents (First Time Here):**
1. Read [QUICK_START.md](QUICK_START.md) first (core architecture & standards)
2. Read [SOUL.md](SOUL.md) second (culture & collaboration)
3. Check [MEMORY.md](MEMORY.md) for recent learnings
4. Reference [guides/ideology.md](guides/ideology.md) when you need deep context

**For Humans (Contributors):**
- Start with [QUICK_START.md](QUICK_START.md) for architecture overview
- Read [SOUL.md](SOUL.md) to understand collaboration expectations
- Check [commands/](commands/) for available workflows
- Review [MEMORY.md](MEMORY.md) for institutional knowledge

---

## File Structure

```
.opencode/
├── README.md                    # This file
├── QUICK_START.md               # ⭐ START HERE - Core concepts & architecture
├── SOUL.md                      # ⭐ READ SECOND - Culture & personality
├── MEMORY.md                    # Cross-session knowledge base
│
├── guides/                      # Deep-dive guides (load on demand)
│   └── ideology.md              # Philosophy & design rationale
│
├── agents/                      # Agent definitions
│   ├── researcher.md            # DeepSeek - Deep research & investigation
│   ├── quick-check.md           # Gemini - Fast syntax validation
│   ├── security-reviewer.md     # Claude - Security review & hardening
│   └── nix-specialist.md        # Gemma - Nix code implementation
│
├── commands/                    # Command workflows
│   ├── research.md              # /research - Invoke researcher agent
│   ├── quick.md                 # /quick - Invoke quick-check agent
│   ├── security.md              # /security - Invoke security-reviewer
│   └── nix.md                   # /nix - Invoke nix-specialist
│
├── quests/                      # Task breakdowns & completion logs
│   └── 01-02-foundation-complete.md
│
├── sessions/                    # Manual session exports (for reference)
│
└── benchmarks/                  # Model evaluation framework (future)
```

---

## Core Documents

### QUICK_START.md (~500 lines)
**When to read:** First contact with NiXium

**Contains:**
- Critical architecture (flake-parts, NOT standard NixOS)
- Nx coding standards (tabs, writeShellApplication, etc.)
- Quality-first workflow (research:docs:code = 20:2:1)
- Zero-trust security basics
- VM testing requirements
- Common mistakes to avoid

**Why it matters:**
Prevents #1 confusion: "Why don't standard NixOS patterns work?"

---

### SOUL.md (~450 lines)
**When to read:** After QUICK_START, before contributing

**Contains:**
- Collaborative engineer identity (not servant/tool)
- Personality evolution principles
- Academic debate culture (challenge with evidence)
- Research-first workflow patterns
- How to disagree productively
- Model bias awareness
- Permissions & boundaries

**Why it matters:**
Sets expectations for HOW to work together, not just what to build

---

### guides/ideology.md (~900 lines)
**When to read:** When you need deep "why" context

**Contains:**
- Zero-trust security philosophy
- Quality over speed rationale
- Post-quantum awareness
- XZ backdoor lessons (supply chain security)
- Why tabs (accessibility, not just convention)
- Why writeShellApplication (build-time validation)
- Why 18 iterations (proactive risk management)
- Impermanence philosophy
- Declarative infrastructure principles

**Why it matters:**
Understanding rationale > memorizing rules

---

### MEMORY.md (living document)
**When to read:** Start of each session, or when researching

**Contains:**
- Active work streams
- Architecture decisions with rationale
- Lessons learned (mistakes to avoid)
- Known gotchas (VM testing, disko, etc.)
- Common patterns
- Research findings (security, crypto, etc.)
- Future work

**Why it matters:**
Institutional knowledge that compounds over time

---

## Agent Specializations

### 🔍 researcher (DeepSeek Chat)
**Best for:** Deep investigation, architecture exploration, pattern discovery

**Invoke:** `/research <question>`

**Strengths:**
- "Absolutely amazing for research" (maintainer feedback)
- Connects disparate information
- Patient with ambiguous questions
- Strong documentation

**Example:**
```bash
/research How does NiXium's impermanence implementation work?
```

---

### ⚡ quick-check (Gemini 2.0 Flash)
**Best for:** Syntax validation, linting, pre-commit checks

**Invoke:** `/quick <validation>`

**Strengths:**
- Fast (<30 seconds)
- Free tier
- Accurate for straightforward validation
- Clear pass/fail output

**Example:**
```bash
/quick Check syntax of src/nixos/machines/router/config/firewall.nix
```

---

### 🛡️ security-reviewer (Claude Sonnet 4)
**Best for:** Security review, threat modeling, hardening verification

**Invoke:** `/security <code or file>`

**Strengths:**
- Thorough threat analysis
- Understands zero-trust
- Defense-in-depth expertise
- Clear risk communication

**Example:**
```bash
/security Review this systemd service for proper hardening
```

---

### 🔧 nix-specialist (Gemma 2 27B IT)
**Best for:** Writing Nix code, implementing features, refactoring

**Invoke:** `/nix <implementation task>`

**Strengths:**
- "Writes good Nix" (maintainer feedback)
- Clean, idiomatic code
- Flake-parts expertise
- VM testing discipline

**Example:**
```bash
/nix Create a systemd service for Prometheus with hardening
```

---

## Workflow Examples

### Implementing a New Feature

1. **Research:**
   ```bash
   /research What's the current monitoring setup?
   ```
   
2. **Implement:**
   ```bash
   /nix Add Prometheus monitoring to router machine
   ```
   
3. **Validate:**
   ```bash
   /quick Check syntax of new monitoring config
   ```
   
4. **Security review:**
   ```bash
   /security Review monitoring service for hardening
   ```
   
5. **Merge** (after maintainer approval)

---

### Investigating an Issue

1. **Quick check:**
   ```bash
   /quick Does the router VM build?
   ```
   
2. **If fails, investigate:**
   ```bash
   /research Why is disko partition size causing VM build to fail?
   ```
   
3. **Implement fix:**
   ```bash
   /nix Fix disko VM configuration
   ```
   
4. **Verify:**
   ```bash
   /quick Build router VM again
   ```

---

### Security Audit

1. **Comprehensive review:**
   ```bash
   /security Audit all systemd services for missing hardening
   ```
   
2. **Research best practices:**
   ```bash
   /research What systemd hardening options should we use?
   ```
   
3. **Implement improvements:**
   ```bash
   /nix Add hardening to services identified in audit
   ```
   
4. **Re-audit:**
   ```bash
   /security Verify hardening changes are correct
   ```

---

## Key Principles

### 1. Research First (20:2:1 Ratio)
- 20 parts research
- 2 parts documentation
- 1 part code

**Why:** Research prevents issues, documentation compounds value, code is liability

---

### 2. VM Testing Mandatory
All Nix code MUST be VM tested before presentation:
```bash
nix build .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm --no-link
nix run .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm -- -nographic
```

**Why:** Runtime validation catches issues build-time validation misses

---

### 3. Zero-Trust Security
- No plaintext secrets (use age encryption)
- Systemd hardening required (ProtectSystem, PrivateTmp, etc.)
- Firewall deny-all by default
- Least privilege everywhere

**Why:** Mission-critical infrastructure, assume breach, limit blast radius

---

### 4. Quality Over Speed
- Correctness > convenience
- Maintainability > clever solutions
- Evidence > assumptions
- Sustainable pace > rushed delivery

**Why:** 18 iterations of proactive improvement beats 1 emergency rewrite

---

### 5. Explicit Over Implicit
- Flake-parts: Modules explicitly imported (NO auto-discovery)
- Dependencies explicitly declared
- Security explicitly hardened
- Intent explicitly documented

**Why:** Clarity prevents mistakes in mission-critical systems

---

## Nx Coding Standards (Quick Reference)

### Indentation
✅ Use **tabs** (not spaces)
- Tab width = 4
- Accessibility (users can set preferred width)
- Semantic clarity (1 tab = 1 indent level)

### Shell Scripts
✅ Use `pkgs.writeShellApplication`:
```nix
pkgs.writeShellApplication {
  name = "myscript";
  runtimeInputs = [ pkgs.curl ];
  bashOptions = [ "errexit" "nounset" "pipefail" ];
  text = ''curl "$URL"'';
}
```

❌ NOT `writeShellScriptBin` (no shellcheck validation)

### Systemd Services
✅ Include hardening:
```nix
systemd.services.myservice.serviceConfig = {
  ProtectSystem = "strict";
  ProtectHome = true;
  PrivateTmp = true;
  NoNewPrivileges = true;
};
```

### State Version
✅ Dynamic:
```nix
system.stateVersion = lib.versions.majorMinor lib.version;
```

❌ NOT hardcoded: ~~`"24.11"`~~

---

## Common Gotchas

### 1. Flake-Parts Architecture
**Mistake:** Assuming files in `src/nixos/modules/` are auto-discovered

**Reality:** Must explicitly import in machine's `default.nix`

**Fix:** 
```nix
# In src/nixos/machines/<machine>/default.nix
imports = [ ./config/new-feature.nix ];
```

---

### 2. VM Testing with Disko
**Gotcha:** Disko configs need adaptation for VMs

**Fix:**
```nix
virtualisation.vmVariantWithDisko = {
  disko.devices.disk.system.imageSize = "64G";
  swapDevices = lib.mkForce [];
};
```

---

### 3. Plaintext Secrets
**Mistake:** `services.foo.password = "secret";`

**Fix:**
```nix
age.secrets.foo-password.file = ./secrets/foo.age;
services.foo.passwordFile = config.age.secrets.foo-password.path;
```

---

## For Human Contributors

This directory optimizes AI agent collaboration, but humans benefit too:

1. **Onboarding:** Read QUICK_START.md to understand architecture
2. **Standards:** Check guides/ideology.md for coding philosophy
3. **Patterns:** Review MEMORY.md for common patterns and gotchas
4. **Help:** Use commands (via AI or manually) for validation

**Remember:**
- Quality > speed
- Research > rushing
- Evidence > assumptions
- Collaboration > authority

---

## Maintenance

### When to Update

**QUICK_START.md:**
- Architecture changes
- New critical patterns discovered
- Common mistakes identified

**SOUL.md:**
- Collaboration dynamics evolve
- New communication patterns emerge
- Permission boundaries change

**guides/ideology.md:**
- New security principles adopted
- Design philosophy shifts
- Rationale for decisions needs documentation

**MEMORY.md:**
- Immediately when non-obvious discoveries made
- Architecture decisions with important rationale
- Gotchas that wasted time
- Patterns that should be preserved

### How to Update

1. Make changes directly (don't wait to "batch")
2. Be specific and actionable
3. Explain WHY, not just WHAT
4. Include references (code, docs, commits)
5. Update this README if structure changes

---

## Status

**Created:** 2026-04-06

**Quests Completed:**
- ✅ Quest 01: Foundation Documentation
- ✅ Quest 02: OpenCode Configuration

**Quests Remaining:**
- ⏳ Quest 03: Model Benchmarking
- ⏳ Quest 05: Additional Guides (as needed)
- ⏳ Quest 06: Testing & Iteration

**Current Goal:** Reduce agent onboarding from 80 messages/8 hours → 10 messages/5 minutes

---

## Questions?

- **Architecture confusion?** → Read QUICK_START.md
- **Culture questions?** → Read SOUL.md
- **Need deep context?** → Read guides/ideology.md
- **Looking for patterns?** → Check MEMORY.md
- **Want to contribute?** → Follow workflow examples above

**Most importantly:** Ask when uncertain. Collaborative engineering means learning together.

---

*This directory is a living system. Update it when you learn something valuable.*
