# NiXium Memory - Cross-Session Institutional Knowledge

**Purpose:** Preserve important learnings, decisions, and context across OpenCode sessions

**Last updated:** 2026-04-09

---

## How to Use This File

**Add entries when:**
- You discover something non-obvious that took time to figure out
- You make an architectural decision with important rationale
- You hit a gotcha that should be documented
- You learn a pattern that future agents/contributors should know
- You identify a common mistake and how to avoid it

**Entry format:**
```markdown
## YYYY-MM-DD: Brief Title

**Issue/Question:** What was the problem or question?

**Context:** Why did this come up? What were we trying to do?

**Discovery/Decision:** What did we learn or decide?

**Rationale:** Why is this the right approach?

**Impact:** What does this affect? Who should know about this?

**References:** Links to code, issues, docs, or commits
```

---

## Active Work Streams

### 2026-04-06: OpenCode Optimization for NiXium

**Goal:** Reduce agent onboarding time from 80 messages/8 hours to 10 messages/5 minutes

**Status:** In Progress - Foundation documentation complete

**Completed:**
- ✅ Created .opencode/QUICK_START.md (core concepts, architecture, coding standards)
- ✅ Created .opencode/SOUL.md (collaborative culture, personality, communication style)
- ✅ Created .opencode/guides/ideology.md (deep philosophy, security principles, design rationale)
- ✅ Created opencode.json (model selection, agent definitions, permissions)
- ✅ Created agent definitions (researcher, quick-check, security-reviewer, nix-specialist)
- ✅ Created command definitions (/research, /quick, /security, /nix)
- ✅ Created MEMORY.md structure (this file)

**Next Steps:**
- [ ] Create benchmark framework (.opencode/benchmarks/)
- [ ] Test in fresh OpenCode session
- [ ] Measure improvement (time to understanding, mistakes made)
- [ ] Iterate based on results

**Owner:** User + Agent collaboration

---

## Architecture Decisions

### 2026-04-06: Flake-Parts vs Standard NixOS

**Decision:** Use flake-parts for all machine configurations, NOT standard NixOS imports

**Rationale:**
1. **Explicit dependency management** - No hidden transitive imports
2. **Per-machine isolation** - Each machine is separate module with own imports
3. **Multi-architecture support** - perSystem handles x86_64/aarch64 automatically
4. **Composability** - Modules can be tested independently and reused

**Trade-off:**
- More verbose (must explicitly import every config file)
- Steeper learning curve
- BUT: Better for mission-critical infrastructure (clarity > convenience)

**Impact:** 
- Files in src/nixos/modules/ are NOT auto-discovered
- Must explicitly import in machine's default.nix
- This is the #1 confusion point for new agents

**References:**
- .opencode/QUICK_START.md (architecture section)
- .opencode/guides/ideology.md (flake-parts rationale)
- AGENTS.md (critical architecture overview)

---

### 2026-04-06: Model Selection for Agents

**Decision:** Use diverse models optimized for specific tasks, not single model for everything

**Rationale:**
1. **Research:** DeepSeek Chat (maintainer reports "absolutely amazing for research")
2. **Quick-check:** Gemini 2.0 Flash (fast, free, accurate for validation)
3. **Security:** Claude Sonnet 4 (thorough threat modeling, hardening expertise)
4. **Nix code:** Gemma 2 27B (maintainer reports "writes good Nix")

**Trade-off:**
- More complex config
- Need to learn which agent for which task
- BUT: Better results than one-size-fits-all

**Anti-pattern identified:**
- Anthropic bias in initial recommendations (assumed Claude best for everything)
- User corrected this with empirical data from actual testing
- Lesson: Trust evidence over marketing/assumptions

**Impact:**
- opencode.json defines 4 specialized agents
- Commands (/research, /quick, /security, /nix) invoke appropriate agent
- Future benchmarking will validate/refine these choices

**References:**
- opencode.json (modelSelector section)
- .opencode/SOUL.md (model bias awareness)

---

## Lessons Learned

### 2026-04-06: Tabs vs Spaces - Not a Security Issue

**Lesson:** Tabs are used for accessibility/utility, NOT security

**Context:** 
During documentation writing, agent incorrectly stated tabs prevent "malicious spaces" 
and were a security feature. User corrected this.

**Truth:**
- **Tabs chosen for:** Accessibility (customizable width), semantic clarity, efficiency
- **NOT for:** Security (this was agent hallucination)

**Why this matters:**
- Misrepresenting rationale damages credibility
- Security claims require evidence
- When uncertain, say "I don't know" rather than inventing justification

**Corrective action:**
- .opencode/guides/ideology.md now accurately explains tab rationale
- Removed all "security" claims about tabs
- Added this to MEMORY.md so future agents don't repeat mistake

**Reference:** .opencode/guides/ideology.md (Why Tabs, Not Spaces section)

---

### 2026-04-06: Research-First Culture (20:2:1 Ratio)

**Lesson:** Time spent in research is NOT waste, it's the most valuable work

**Context:**
NiXium operates on 20:2:1 research:documentation:code ratio. This seems slow but is intentional.

**Why it works:**
1. Research finds better solutions (first idea rarely best)
2. Catches issues early (security flaw in research costs minutes, in production costs days)
3. Documentation compounds value (future work accelerated)
4. Code is liability (less code = less bugs)

**Anti-pattern:**
- Agent rushing to code after reading file summaries
- Assuming "standard NixOS" patterns work (they don't - flake-parts is different)
- Proposing code without VM testing

**Success pattern:**
- Spend 80% time understanding problem
- Test hypotheses with VM builds
- Document findings before implementing
- Write minimal code that solves root problem

**Impact:**
- All agents should prioritize research over speed
- VM testing is mandatory, not optional
- Quality beats speed, always

**Reference:** 
- .opencode/SOUL.md (Research-First Culture)
- .opencode/guides/ideology.md (Quality Over Speed Philosophy)

---

## Known Issues and Gotchas

### Flake-Parts Module Import Confusion

**Issue:** Agents expect files in src/nixos/modules/ to be auto-discovered (standard NixOS behavior)

**Reality:** NiXium uses flake-parts - modules must be explicitly imported in machine's default.nix

**Symptoms:**
- Agent creates file in modules/ expecting it to work
- Builds fail with "option does not exist"
- Agent confused because file exists but isn't loaded

**Solution:**
1. Create config file in src/nixos/machines/<machine>/config/
2. Import in src/nixos/machines/<machine>/default.nix
3. OR export shared module in src/nixos/default.nix and import in machines

**Prevention:**
- .opencode/QUICK_START.md emphasizes this in critical warnings
- AGENTS.md has extensive section on architecture
- Future agents should catch this in onboarding

---

### VM Testing with Disko

**Issue:** Disko configs designed for real hardware need adaptation for VM testing

**Gotchas:**
- Partition sizes: Set `imageSize = "64G"` (or appropriate size)
- Device paths: VM uses /dev/vda not /dev/nvme0n1
- LUKS passwords: Use password option in VM, not keyFile
- Swap: Often disabled in VM to reduce resource usage
- Impermanence: May need `lib.mkForce false` in VM variant

**Pattern:**
```nix
virtualisation.vmVariantWithDisko = {
	virtualisation = {
		memorySize = 2048;
		cores = 2;
	};
	disko.devices.disk.system.imageSize = "64G";
	swapDevices = lib.mkForce [];
};
```

**Reference:** AGENTS.md (VM Configuration Tips section)

---

### State Version Must Be Dynamic

**Issue:** Hardcoding `system.stateVersion = "24.11"` causes issues across releases

**Correct pattern:**
```nix
system.stateVersion = lib.versions.majorMinor lib.version;
```

**Why:**
- Dynamically matches NixOS release version
- Works across 24.05, 24.11, 25.05, etc.
- No manual updates needed

**Prevention:**
- Quick-check agent validates against hardcoded stateVersion
- Nx coding standards document this pattern
- All example code uses dynamic version

---

## Common Mistakes to Avoid

### 1. Using writeShellScriptBin Instead of writeShellApplication

**Mistake:**
```nix
pkgs.writeShellScriptBin "myscript" ''
  #!/usr/bin/env bash
  curl $URL  # No shellcheck, no validation
'';
```

**Correct:**
```nix
pkgs.writeShellApplication {
  name = "myscript";
  runtimeInputs = [ pkgs.curl ];
  bashOptions = [ "errexit" "nounset" ];
  text = ''curl "$URL"'';  # Shellcheck validates, catches unquoted $URL
}
```

**Why:** Build-time validation prevents runtime errors

---

### 2. Plaintext Secrets in Config

**Mistake:**
```nix
services.myapp.apiKey = "sk_live_abc123";  # NEVER
```

**Correct:**
```nix
age.secrets.myapp-key.file = ./secrets/myapp-key.age;
services.myapp.apiKeyFile = config.age.secrets.myapp-key.path;
```

**Why:** Zero-trust security model, secrets must be encrypted

---

### 3. Missing Systemd Hardening

**Mistake:**
```nix
systemd.services.myservice.script = ''...'';
# No hardening options
```

**Correct:**
```nix
systemd.services.myservice = {
  script = ''...'';
  serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    NoNewPrivileges = true;
  };
};
```

**Why:** Defense in depth, limit blast radius of compromise

---

### 4. Proposing Code Without VM Testing

**Mistake:**
> "I wrote this config, it should work. Want me to commit it?"

**Correct:**
> "I implemented and tested this in VM. Build succeeded, service starts correctly, 
> logs show no errors. All changes reverted, ready for your review."

**Why:** Build-time validation catches many issues, but runtime testing is essential

---

## Research Findings

### XZ Backdoor (2024) - Supply Chain Security

**Finding:** XZ Utils backdoor (March 2024) demonstrated supply chain attacks can evade review for years

**Key insights:**
1. **Social engineering** was the real attack (maintainer burnout, community pressure)
2. **Complexity hides malice** (multi-stage obfuscation, binary test data)
3. **Build-time validation** helps (shellcheck would flag suspicious patterns)
4. **Sustainable pace** matters (rushed maintainers can't review thoroughly)

**NiXium defenses:**
- Pin dependencies, review changes before updating
- Build-time validation (shellcheck, linters)
- Prefer simple code over clever abstractions
- No binary blobs without justification
- Quality over speed (resist pressure to "just ship it")

**Reference:** .opencode/guides/ideology.md (Supply Chain Security section)

---

### Post-Quantum Cryptography Timeline

**Finding:** "Harvest now, decrypt later" attacks happening NOW

**Timeline:**
- 2026 (now): Attackers recording encrypted traffic
- 2030s: Quantum computers likely break RSA-2048, ECC-256
- 2040s: Large-scale quantum computers commoditized

**Implications for NiXium:**
- High-risk data: Use post-quantum crypto NOW (hybrid classical + PQ)
- Medium-risk: Plan migration by 2028-2030
- Low-risk: Migrate before 2035

**Current status:**
- SSH: Ed25519 (will need Kyber addition)
- LUKS: AES-256 (quantum-resistant for symmetric crypto)
- TLS: Monitor for post-quantum TLS 1.4

**Reference:** .opencode/guides/ideology.md (Post-Quantum Awareness section)

---

## 2026-04-09: Sub-Agent Model Strings Were Wrong

**Issue:** Agent `.md` files in `.opencode/agents/` referenced models that don't exist under the configured providers (`deepseek/deepseek-chat`, `google/gemma-2-27b-it`, `google/gemini-2.0-flash-exp:free`, `anthropic/claude-sonnet-4`).

**Reality:** All Claude-capable agents use `github-copilot/claude-sonnet-4.6`; quick-check uses `opencode/nemotron-3-super-free`. This matches `opencode.json`.

**Fix:** Updated all 4 agent `.md` files to reflect correct model strings.

**Lesson:** When updating `opencode.json` model strings, also update the human-readable agent docs in `.opencode/agents/`.

---

## 2026-04-09: Token Conservation — Nemotron-First Strategy

**Decision:** Primary agent (nemotron, free) should handle as much as possible autonomously. Claude sub-agents cost premium GitHub Copilot tokens (~585 remaining as of last analysis).

**Rules added to `build.md`:**
1. Brainstorm + get approval before any large write
2. Handle tasks yourself unless you hit a concrete gap
3. Don't call sub-agents for exploration, simple checks, or anything you can do at 90%+ quality
4. Sub-agents only for genuine knowledge gaps, complex threat modeling, or tricky Nix patterns

**Reference:** `.opencode/quests/08-token-budget-crisis/`

---

## 2026-04-09: Claude Sonnet 4.6 Restriction Analysis

**Issue:** Claude Sonnet 4.6 has built-in restrictions that interfere with legitimate NiXium security and infrastructure work, causing unnecessary refusals during development.

**Context:** While analyzing the leaked Claude Sonnet 4.6 system prompt to understand refusal patterns for Quest 07, identified specific restriction categories that impact infrastructure security work.

**Discovery/Decision:** 
Claude has absolute refusals for:
1. Child safety content (under 18 exploitation)
2. Weapons/harmful substances technical details
3. Malicious code creation (malware, exploits, etc.)
4. Copyright violations (15+ word quotes, multiple quotes per source)

And contextual refusals for:
- Real public figures in creative/persuasive content

**Rationale:** 
These restrictions are designed for general safety but can block legitimate security research, cryptography implementation, reverse engineering for GPL compliance, and infrastructure hardening work that NiXium requires.

**Impact:** 
Agents using Claude may experience false refusals during authorized security work. Need pre-authorization framing and workaround strategies to maintain productivity while respecting legitimate safety boundaries.

**References:**
- .opencode/system-prompts/claude-sonnet-4.6.txt (Claude Sonnet 4.6 system prompt)
- .opencode/guides/claude-restrictions.md (detailed analysis)
- .opencode/guides/claude-pre-authorization.md (pre-authorization template)

## Meta: About This File

**Maintenance:**
- Add entries immediately when discoveries are made
- Don't wait to "batch" updates
- Be specific and actionable
- Explain WHY, not just WHAT
- Include references to code/docs/commits

**Review:**
- Periodically review and archive outdated entries
- Move resolved issues to "Historical" section
- Keep active sections concise and relevant

**Integration:**
- Referenced by agents via .opencode/SOUL.md
- Not loaded by default (agents check when needed)
- Human contributors should also read this

---

*This file will grow as we learn. Treat it as living institutional knowledge.*
