<!-- SUMMARY: Sustainable AI operations with limited premium token budget. Strategy for token conservation and alternative funding. LOAD WHEN: Managing token usage, selecting models for cost-effectiveness, or planning AI budget. SKIP WHEN: Not working on token management or model selection. -->

# Quest: Token Budget Crisis & Sustainable AI Operations

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Open |
| **Priority** | High |
| **Created** | 2026-04-06 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |
| **Legacy #** | 08 |

## Problem

GitHub Copilot tokens donated by Microsoft for Open-Source contributors:
- **Total budget:** ~1500 premium requests (100%)
- **Already spent:** ~10% wasted on premature execution
- **Remaining:** ~90% (1350 requests)
- **Crisis:** Cannot afford to waste tokens on unreviewed work

## Impact

- Agent prematurely executed without brainstorming approval
- Wrote extensive documentation that may need complete revision
- Burned ~150 requests worth of tokens on work that wasn't validated first
- At current burn rate, budget exhausted before infrastructure work complete

## Root Cause

Agent jumped to execution mode instead of:
1. Brainstorming approach with user
2. Getting approval on direction
3. Writing minimal viable version
4. Iterating based on feedback

## Current Strategy

### Token Conservation Rules

1. **Brainstorm + get approval** before any large write
2. **Handle tasks yourself** unless you hit a concrete gap
3. **Don't call sub-agents** for exploration, simple checks, or anything you can do at 90%+ quality
4. **Sub-agents only** for genuine knowledge gaps, complex threat modeling, or tricky Nix patterns

### Model Selection Strategy

- **Default orchestrator:** `opencode-go/minimax-m2.7` (1M context, free)
- **Research agent:** `opencode-go/glm-5.1` (ZhiPu GLM, empirically strong for research)
- **Specialists (Nix, security, general):** `github-copilot/claude-sonnet-4.6` (premium — use sparingly)
- **Quick check:** `opencode-go/minimax-m2.7` (same as orchestrator, free and fast)

## Requirements

### Immediate

1. **Document current token usage** — Track tokens per session, identify high-cost operations
2. **Implement token conservation strategy** — ALWAYS brainstorm BEFORE writing
3. **Alternative token sources research** — Who can we pay for more tokens? What providers offer best value?
4. **Cost-benefit analysis** — Which models are most cost-effective per task?

### Long-term

5. **Sustainable AI operations** — Budget allocation per quest/project, token monitoring, automatic warnings
6. **Local model deployment** — 40-core cluster for local inference to reduce cloud dependency

## Research Questions

1. **GitHub Copilot Token Details** — Exact limits, reset period, additional allocation for critical infrastructure?
2. **Alternative Funding** — Anthropic research grants, OpenAI credits, cloud provider credits, NLNet Foundation?
3. **Local Model Economics** — Cost to run DeepSeek-V3 on 40-core cluster vs GPT-4 API, electricity cost per inference?
4. **Token Optimization** — Prompt compression, context window optimization, batch operations?

## Success Criteria

- [ ] Know exact token budget and usage
- [ ] Have 2+ alternative funding sources identified
- [ ] Agent respects brainstorm-before-execute workflow
- [ ] Token burn rate reduced by 50%
- [ ] Can sustain operations through infrastructure completion

## Research Materials

- `research/original-README.md` — Original quest documentation
- `research/session-analysis.md` — Analysis of token usage in sessions

## Related Quests

- [trust-tier-architecture](../trust-tier-architecture/quest.md) — Local models reduce cloud dependency
- [restriction-benchmark](../restriction-benchmark/quest.md) — Need efficient testing methodology
- [claude-system-prompt-analysis](../claude-system-prompt-analysis/quest.md) — Understanding costs of different approaches