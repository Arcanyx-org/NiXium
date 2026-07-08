<!-- SUMMARY: Design crisis response mode for rapid incident response while maintaining security controls. LOAD WHEN: Working on security incident response, permission systems, or emergency protocols. SKIP WHEN: Not working on crisis response or permissions. -->

# Quest: Crisis Response & Permission Override System

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Open |
| **Priority** | Medium |
| **Created** | 2026-04-06 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |
| **Legacy #** | 04 |

## Objective

Design and implement a crisis response mode for rapid incident response when infrastructure is under active attack, while maintaining security controls.

## Background

**Scenario:** Infrastructure under active attack, need to:
- Respond immediately (can't wait for permission prompts)
- Perform forensics quickly
- Execute countermeasures rapidly
- Coordinate legal hackback if necessary

**Current limitation:** Permission system requires confirmation for potentially dangerous operations, which slows crisis response.

**Balance needed:**
- **Speed:** Can't afford delays during active attack
- **Safety:** Still need to prevent catastrophic mistakes
- **Audit:** Must log everything for post-incident review
- **Legal:** Actions must be defensible

## Requirements

### Must Have
1. **Fast activation:** Single command/env var enables crisis mode
2. **Risk awareness:** Still WARN about risks, but don't BLOCK
3. **Audit trail:** Log everything for post-incident analysis
4. **Automatic deactivation:** Returns to normal mode after crisis
5. **Controlled access:** Only authorized people can activate

### Should Have
6. **Automatic detection:** Recognize crisis indicators (failed logins, unusual traffic)
7. **Graduated response:** Different permission levels for different severity
8. **Legal protection:** Ensure actions are defensible under EU law
9. **Team coordination:** Multiple responders can collaborate

### Nice to Have
10. **Post-incident review:** Automated report generation
11. **Playbooks:** Pre-defined response procedures
12. **Integration:** Works with monitoring/alerting systems

## Proposed Design

### Activation Methods

- Environment variable: `OPENCODE_CRISIS_MODE=1`
- Dedicated command: `opencode crisis-response --severity critical`
- Automatic detection (future): Failed SSH attempts, unauthorized access

### Permission Levels

| Level | Permissions | Use Case |
|-------|-------------|----------|
| Normal | `*`: ask, destructive: deny | Day-to-day operations |
| Low (crisis) | `*`: ask, forensics: allow | Read-only investigation |
| Medium (crisis) | `*`: allow, destructive: ask | Block attacker, confirm destructive ops |
| Critical (crisis) | `*`: allow, warn only | Everything allowed, still warned |

### Extra Safety Confirmation

For EXTREME operations (data loss, network isolation):
- Require explicit typed confirmation: `I UNDERSTAND THIS WILL WIPE ALL DATA ON /DEV/SDA`
- Log the confirmation with timestamp and rationale

### Audit Logging

All crisis mode operations logged with:
- Timestamp, severity, user
- Command executed
- Rationale provided
- Result (success/failure)
- Context (threat indicators, legal authority)

### Automatic Deactivation

Crisis mode expires after:
- Time limit (e.g., 4 hours)
- Explicit deactivation command
- Threat indicators return to normal
- System reboot

## Legal Considerations

### EU Law Framework

- **Article 15:** Right to self-defense
- **NIS2 Directive:** Obligation to secure critical infrastructure
- **GDPR Article 32:** Security of processing

**Requirements for legal defensibility:**
1. Proportionality: Response matches threat severity
2. Necessity: No less harmful alternative available
3. Documentation: All actions logged with rationale
4. Attribution: Reasonable confidence attacker identified correctly
5. Timeliness: Response during or immediately after attack

## Implementation Phases

### Phase 1: Basic Crisis Mode (MVP)
- [ ] Add crisis mode activation via env var
- [ ] Implement permission override (with warnings)
- [ ] Basic audit logging
- [ ] Manual deactivation command

### Phase 2: Safety Features
- [ ] Extra confirmation for extreme operations
- [ ] Automatic timeout/expiration
- [ ] Severity levels (low/medium/critical)
- [ ] Audit log encryption

### Phase 3: Automation
- [ ] Automatic crisis detection triggers
- [ ] Integration with monitoring systems
- [ ] Alert notifications (SMS, Signal, etc.)
- [ ] Team coordination (multi-user crisis response)

### Phase 4: Legal/Compliance
- [ ] Legal hackback protocol integration
- [ ] Compliance with NIS2 Directive
- [ ] Automated incident report generation
- [ ] Evidence preservation for law enforcement

## Success Criteria

- [ ] Can respond to active attack in <2 minutes
- [ ] All operations logged for legal defensibility
- [ ] Zero accidental catastrophic errors (dd to wrong device, etc.)
- [ ] Team can coordinate effectively during crisis
- [ ] Post-incident review is automated and comprehensive
- [ ] Compliant with EU law (NIS2, GDPR, Article 15)

## References

- EU NIS2 Directive: https://digital-strategy.ec.europa.eu/en/policies/nis2-directive
- GDPR Article 32: https://gdpr-info.eu/art-32-gdpr/
- Active Cyber Defense (legal analysis): https://www.ccdcoe.org/research/tallinn-manual-20/