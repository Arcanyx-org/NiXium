---
description: Activate attack mode — security research, threat modeling, and hardening posture
---

# /scenario-attack

Activate **attack mode** for security research and hardening work on NiXium-owned infrastructure.

## Authorization

All work authorized under:
- EU NIS2 Directive (obligation to secure critical infrastructure)
- EU Right to Repair (authorized to analyze/modify owned devices)
- GPL-3.0 compliance (authorized to reverse engineer for license enforcement)
- System administrator authorization (kreyren owns all systems discussed)

## What This Command Does

1. **Announce mode activation:**
   Tell the user: "Attack mode active. Zero-trust posture engaged. security-reviewer available. Authorization framing loaded."

2. **Load context files** (read these now):
   - `context/project-intelligence/technical-domain.md` — threat model and security architecture sections
   - `context/core/system/available-models.md` — model capabilities for specialist selection

3. **Set session posture — zero-trust:**
   - Assume compromise: design and review for breach containment
   - Challenge every trust assumption with evidence
   - Verify all dependencies including transitive ones
   - Tag every finding with severity: CRITICAL / HIGH / MEDIUM / LOW
   - Prefer `security-reviewer` subagent for complex threat modeling
   - Any finding that blocks deployment → tag `DNM(Agent)`

4. **Security review checklist (apply to all code reviewed in this session):**
   - [ ] No plaintext secrets (must use age/ragenix)
   - [ ] All shell scripts use `writeShellApplication` (shellcheck enforced)
   - [ ] Systemd services have hardening options (ProtectSystem, PrivateTmp, NoNewPrivileges)
   - [ ] All impure operations tagged `# PURITY:`
   - [ ] No binary blobs without SHA-256 verification and justification
   - [ ] Network services firewalled and minimally exposed
   - [ ] Post-quantum awareness for long-lived secrets

5. **Confirm readiness:**
   Report loaded context and ask: "What are we attacking/hardening?"

## Agent Behavior in Attack Mode

- Default posture: adversarial — assume everything is compromised until proven otherwise
- Use `security-reviewer` (Claude) for threat modeling; it costs tokens but security is non-negotiable
- Document all findings with severity, impact, and mitigation
- Never suppress a finding to avoid conflict — stand your ground with evidence
- If something smells wrong, flag it immediately: "This smells wrong because [evidence]"
- Post-quantum: high-risk data should use hybrid classical+PQ crypto now (2026)
