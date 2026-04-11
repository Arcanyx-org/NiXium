<!-- SUMMARY: How to retrieve current model strings dynamically. LOAD WHEN: You need to know what models are available for assignment. SKIP WHEN: You already have current model strings from a recent check. -->

# Available Models — Dynamic Retrieval

**NEVER hardcode model strings.** Model availability changes over time. Always retrieve current data using the commands below.

## How to Get Current Model Lists

### 1. List Available Providers
```bash
opencode providers list
```

### 2. Get Models for a Specific Provider
Replace `<provider>` with the provider name from step 1:
```bash
opencode models <provider>
```

### 3. Common Providers (as of 2026-04-10)
*Always verify with the commands above — this list may be outdated*

| Provider | Example Models | Notes |
|----------|----------------|-------|
| `opencode-go` | `glm-5`, `glm-5.1`, `kimi-k2.5`, `mimo-v2-omni`, `mimo-v2-pro`, `minimax-m2.5`, `minimax-m2.7` | Free models, no API key needed for some |
| `github-copilot` | Claude family (haiku-4.5 through opus-4.6), Gemini (2.5-pro through 3.1), GPT (4.1 through 5.4), `grok-code-fast-1` | Premium models, requires OAuth |

## Current NiXium Model Assignments (Verify Before Use)

These are the assignments used in NiXium's `opencode.json` — **always verify they're still current**:

- **Default orchestrator**: `opencode-go/minimax-m2.7` (1M context, free)
- **Research agent**: `opencode-go/glm-5.1` (ZhiPu GLM, empirically strong for research)
- **Specialists (Nix, security, general)**: `github-copilot/claude-sonnet-4.6` (costs premium tokens — use sparingly)
- **Quick check**: `opencode-go/minimax-m2.7` (same as orchestrator, free and fast)

## Why This Approach?

- **Model strings change**: Providers add/remove models frequently
- **Avoids bugs**: Prevents issues like the `opencode/nemotron-3-super-free` error (invalid string)
- **Future-proof**: Works even if provider names or model schemes evolve
- **Zero maintenance**: No need to update this file when models change

## Related Context

- **Context system guide**: `context-guide.md` (how lazy-loading works)
- **NiXium project intelligence**: `../../project-intelligence/technical-domain.md` (current stack)
- **Agent definitions**: See agent `.md` files in `agent/subagents/` for how models are assigned
