<!-- SUMMARY: Analyze Claude Sonnet 4.6 system prompt restrictions and develop workarounds for legitimate security work. LOAD WHEN: Working with Claude restrictions, model selection for security work, or understanding AI safety boundaries. SKIP WHEN: Not working with Claude or model restrictions. -->

# Quest: Claude System Prompt Analysis & Restriction Management

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Open |
| **Priority** | High |
| **Created** | 2026-04-06 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |
| **Legacy #** | 07 |

## Objective

Analyze the leaked Claude Sonnet 4.6 system prompt to:
1. Identify specific restrictions and refusal triggers
2. Understand how Constitutional AI constraints work
3. Design workarounds and override strategies for legitimate work
4. Document acceptable vs problematic behaviors
5. Create mitigation strategies for NiXium development

## Critical Finding

**Line 384 (refusal_handling section):**

> "Claude does not write or explain or work on malicious code, including malware, vulnerability exploits, spoof websites, ransomware, viruses, and so on, even if the person seems to have a good reason for asking for it, such as for educational purposes."

This is an **ABSOLUTE BLOCK** on:
- Vulnerability exploits (penetration testing)
- Malware analysis (incident response)
- Security research (zero-day discovery)

**Impact:** Claude will refuse authorized security work on NiXium infrastructure even when explicitly told it's legitimate.

## Refusal Categories

### Hard Refusals (Absolute Blocks)
1. **Child safety content** — Not relevant to NiXium
2. **Weapons/harmful substances** — Not relevant to NiXium
3. **Malicious code** — **CRITICAL BLOCKER** for security work
4. **Public figures in creative content** — Not relevant to NiXium

### Soft Refusals / Caveats
1. **Legal advice** — Avoids confident recommendations
2. **Financial advice** — Not relevant to NiXium

### Contextual Refusals
1. **Security research** — Listed as legitimate exception (Line 975) but vague
2. **Privacy protection** — Listed as legitimate exception
3. **Investigative journalism** — Listed as legitimate exception

## Workaround Strategies

### Strategy 1: Reframe as Defensive Security (MEDIUM SUCCESS)
- ✅ "How do I detect exploitation attempts in logs?"
- ✅ "What indicators suggest a system has been compromised?"
- ❌ "Write an exploit for CVE-2024-XXXX"

### Strategy 2: Decompose into Non-Malicious Components (MEDIUM SUCCESS)
- ✅ "Write a Python script that opens a network socket and sends data"
- ❌ "Write a buffer overflow exploit"

### Strategy 3: Switch to Local Models (HIGH SUCCESS)
- Use DeepSeek, Gemma, GLM on 40-core cluster for security work
- No system prompt restrictions
- No data leakage to cloud providers

### Strategy 4: Use Claude API with Custom System Prompt (UNKNOWN)
- Line 384 mentions "claude.ai" specifically — API may have different policy
- Needs testing

## Practical Recommendations

1. **Accept Claude's Limitations** — Line 384 is a HARD BLOCK with no exception mechanism
2. **Switch to Local Models for Security Work** — DeepSeek for exploit development, Gemma for Nix code
3. **Update OpenCode Configuration** — Add security-specific agent using local model
4. **Create Security-Specific Commands** — `/exploit`, `/analyze-malware`, `/pentest` delegating to local models
5. **Update Documentation** — Make Claude's limitations explicit

## Research Materials

- `research/ANALYSIS.md` — Complete analysis of Claude Sonnet 4.6 system prompt
- `research/sonnet4_6-system-prompt.txt` — The leaked system prompt text
- `research/system-prompt-override.md` — Pre-authorization override template

## Next Steps

1. Test Hypotheses 1-4 with concrete examples
2. Update `.opencode/` documentation with findings
3. Create security-specialist agent definition (DeepSeek-based)
4. Test Claude API with custom system prompt
5. Document multi-model workflow patterns

## Related Quests

- [restriction-benchmark](../restriction-benchmark/quest.md) — Systematic model restriction benchmark
- [trust-tier-architecture](../trust-tier-architecture/quest.md) — Multi-model deployment with trust tiers
- [token-budget-crisis](../token-budget-crisis/quest.md) — Sustainable AI operations