# Baseline Metrics (Pre-OpenCode Optimization)

**Context:** These metrics reflect agent performance BEFORE Quest 02 work (QUICK_START.md, SOUL.md, specialized agents).

**Date:** ~2026-04-06 and earlier sessions

---

## Observed Issues (Pre-Optimization)

### Architecture Confusion
- **Module import misunderstanding:** ~30 messages explaining flake-parts vs standard NixOS
- **Repeated mistakes:** Adding files to `src/nixos/modules/` expecting auto-import
- **Trial-and-error:** Multiple failed VM builds before correct structure understood

### Communication Overhead
- **Wall-of-text responses:** Excessive scrolling, copy-pasting required
- **Over-explanation:** Long prose when bullet points would suffice
- **Excessive questions:** Asking for clarification on decisions agent should make

### Security Gaps
- **Reactive not proactive:** Security issues caught in review, not prevention
- **Missing PURITY tags:** Impure operations not consistently marked
- **Secret handling:** Confusion about ragenix usage

### Testing Gaps
- **Skipped VM testing:** Proposed code without building first
- **No failure scenario testing:** Only tested happy path
- **Missing documentation:** Changes not documented with rationale

---

## Quantitative Baseline

**Typical onboarding task (add new service to machine):**
- **Messages:** 60-80 back-and-forth
- **Time:** 6-8 hours elapsed (including research, corrections)
- **VM builds:** 3-5 failed builds before success
- **Architecture corrections:** 15-20 messages explaining flake-parts
- **Security remediations:** 2-3 issues found in review
- **Documentation quality:** Minimal, required prompting

---

## Root Causes Identified

1. **Insufficient onboarding docs** - AGENTS.md comprehensive but overwhelming (too long)
2. **No quick-reference guide** - Agents had to re-read entire AGENTS.md each session
3. **Unclear communication norms** - No guidance on response format preferences
4. **Generic model selection** - No specialized agents for specific task types
5. **No memory system** - Each session started from scratch

---

## Quest 02 Interventions

**Created to address root causes:**
- ✅ `QUICK_START.md` - 60-second architecture overview + critical rules
- ✅ `SOUL.md` - Communication culture and collaboration norms
- ✅ `ideology.md` - Design philosophy and "why" behind decisions
- ✅ `opencode.json` - Specialized agents (researcher, security-reviewer, etc.)
- ✅ `MEMORY.md` - Cross-session institutional knowledge
- ✅ Command definitions - `/research`, `/security`, `/quick`, `/nix`

---

## Expected Improvements

**Target metrics after optimization:**
- **Messages:** ≤10 to task completion
- **Time:** ≤5 minutes
- **VM builds:** First build succeeds (proper testing beforehand)
- **Architecture understanding:** Self-directed, no confusion
- **Security:** Proactive detection, no review remediations
- **Documentation:** High quality, included without prompting

**Validation method:** Run benchmark scenarios in fresh session, measure actual performance.
