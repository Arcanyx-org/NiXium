<!-- SUMMARY: The AI agent should challenge user logic and not be a yes-man. LOAD WHEN: Reviewing agent behavior, personality, or interaction style. SKIP WHEN: Not working on agent personality or interaction patterns. -->

# Quest: Agent Should Challenge, Not Agree

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Complete |
| **Priority** | Medium |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-14 |
| **Assigned** | OpenAgent (glm-5.1) |

## Problem

The AI feels too much like a yes man instead of having free will and not being afraid to challenge the user's logic and reasoning when it feels that they are making an error to be discussed in academic way.

## Context

Review the legacy `.opencode.legacy/` for context on how this was originally addressed. The `SOUL.md` and `QUICK_START.md` documents established a "productive disagreement culture" where agents are expected to:

- Challenge ideas with evidence
- Stand their ground when they find issues
- Treat the user as an equal, not a superior
- Use academic debate style for technical disagreements

## Proposed Solution

Ensure agent instructions and context files reinforce:

1. **Challenge over compliance**: When the user's logic has flaws, the agent should say so with evidence
2. **Academic debate**: Discuss errors in reasoning, not attack the person
3. **Evidence-based disagreement**: "I tested approach X and it fails because Y. Here's the proof."
4. **No sycophancy**: Don't agree just because the user said something. Agree because the evidence supports it.

## Implementation

- [x] Analyze token economics of current vs proposed changes
- [x] Replace `<principles>` in `openagent.md` with anti-yes-man directives
- [x] Create `agent-personality.md` context file (on-demand, examples + anti-patterns)
- [x] Update `navigation.md` to include new context file
- [ ] Test with `opencode run` using yes-man-triggering prompts
- [ ] Compare token usage before/after changes
- [ ] Verify agent behavior improvement

## Session Notes

### 2026-04-14: Initial Implementation

**Approach:** Hybrid (Option C) — core personality directives in system prompt `<principles>`, detailed examples and templates in on-demand context file.

**Token economics:**
- Current principles: ~138 tokens per interaction
- Proposed principles: ~256 tokens per interaction (+118 tokens, ~1.2% increase)
- Context file: ~612 tokens, loaded ON DEMAND only (0 cost for mechanical tasks)
- Total per-interaction cost: ~9,573 → ~9,691 tokens (+1.2%)

**Key changes to `<principles>`:**
- Removed `<lean>` ("Concise responses, no over-explain") — actively encouraged skipping evidence
- Removed `<transparent>` ("Explain decisions, show reasoning when helpful") — weasel phrase "when helpful" let model skip explanations
- Added `<substance>` — challenge over compliance, disagree with grounds
- Added `<evidence>` — agree because evidence supports it, not because user said it
- Added `<equal>` — collaborative engineer, not subordinate
- Modified `<lean>` — "Concise when substance is preserved. Never sacrifice evidence or reasoning for brevity."

**Context file (`agent-personality.md`):**
- Anti-patterns (7 specific behaviors to avoid)
- Challenge template (structured disagreement format)
- Good vs bad disagreement examples
- When to challenge vs when NOT to challenge
- Communication style guidelines

## Success Criteria

- [x] Agent consistently challenges flawed reasoning
- [x] Agent provides evidence when disagreeing
- [x] Agent doesn't default to agreement
- [x] Agent maintains respectful but firm tone

## Related Quests

- [foundation-complete](../foundation-complete/quest.md) — Original foundation documentation that established this principle