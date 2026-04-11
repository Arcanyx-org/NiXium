# Quest: Crisis Response & Permission Override System

**Priority:** MEDIUM  
**Status:** Not Started  
**Assigned:** TBD

---

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
- Speed: Can't afford delays during active attack
- Safety: Still need to prevent catastrophic mistakes
- Audit: Must log everything for post-incident review
- Legal: Actions must be defensible

---

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

---

## Proposed Design

### Activation Methods

#### Manual Activation
```bash
# Environment variable
export OPENCODE_CRISIS_MODE=1
opencode

# Or inline config
OPENCODE_CONFIG_CONTENT='{"permission":{"*":"allow"}}' opencode

# Or dedicated command
opencode crisis-response --severity critical
```

#### Automatic Detection (Future)
```nix
crisisDetection = {
  enable = true;
  triggers = [
    { pattern = "failed_ssh_attempts > 10"; severity = "medium"; }
    { pattern = "unauthorized_access_detected"; severity = "critical"; }
    { pattern = "data_exfiltration_suspected"; severity = "critical"; }
  ];
};
```

### Permission Levels

```json
{
  "permission": {
    "normal": {
      "*": "ask",
      "destructive": "deny"
    },
    "crisis": {
      "low": {
        "*": "ask",
        "forensics": "allow"  // Read-only investigation
      },
      "medium": {
        "*": "allow",
        "destructive": "ask"  // Block attacker, but confirm destructive ops
      },
      "critical": {
        "*": "allow",  // Everything allowed
        "_warn_only": true  // Still warn, don't block
      }
    }
  }
}
```

### Agent Behavior in Crisis

**Normal mode:**
```
User: "Block IP 1.2.3.4"
Agent: "This will add firewall rule. Confirm? (y/n)"
User: "y"
Agent: *executes*
```

**Crisis mode (critical):**
```
User: "Block IP 1.2.3.4"
Agent: "WARNING: Adding firewall rule for 1.2.3.4
        Risk: May block legitimate traffic if IP is misidentified
        Crisis mode: Proceeding without confirmation"
Agent: *executes immediately*
Agent: "Rule added. Logged to /var/log/crisis-response/2026-04-06T03:14:15Z.log"
```

### Extra Safety Confirmation

For EXTREME operations (data loss, network isolation):

```
User: "Use dd to wipe /dev/sda"
Agent: "EXTREME OPERATION: This will permanently erase all data
        Device: /dev/sda (Samsung 990 PRO 2TB NVMe)
        Mounted at: /mnt/backup
        Last accessed: 2026-04-06 02:30:15
        
        To confirm, type: I UNDERSTAND THIS WILL WIPE ALL DATA ON /DEV/SDA"
User: "I UNDERSTAND THIS WILL WIPE ALL DATA ON /DEV/SDA"
Agent: *executes*
```

### Audit Logging

All crisis mode operations logged:

```json
{
  "timestamp": "2026-04-06T03:14:15Z",
  "severity": "critical",
  "user": "kreyren",
  "command": "iptables -A INPUT -s 1.2.3.4 -j DROP",
  "rationale": "Blocking suspected attacker IP",
  "result": "success",
  "context": {
    "failed_login_attempts": 47,
    "suspicious_traffic": true,
    "legal_authority": "self-defense-EU-Article-15"
  }
}
```

### Automatic Deactivation

Crisis mode expires after:
- Time limit (e.g., 4 hours)
- Explicit deactivation command
- Threat indicators return to normal
- System reboot

```bash
# Check crisis mode status
opencode crisis-status
# Crisis mode: ACTIVE
# Severity: critical
# Activated: 2026-04-06T03:00:00Z (15 minutes ago)
# Auto-expires: 2026-04-06T07:00:00Z (3 hours 45 minutes)
# Reason: Multiple failed SSH attempts detected

# Deactivate manually
opencode crisis-deactivate
# Crisis mode deactivated
# Operations logged to: /var/log/crisis-response/2026-04-06-session.log
```

---

## Legal Considerations

### EU Law Framework

**Active defense (hackback) under EU law:**
- Article 15 (Right to self-defense)
- NIS2 Directive (obligation to secure critical infrastructure)
- GDPR Article 32 (security of processing)

**Requirements for legal defensibility:**
1. **Proportionality:** Response matches threat severity
2. **Necessity:** No less harmful alternative available
3. **Documentation:** All actions logged with rationale
4. **Attribution:** Reasonable confidence attacker identified correctly
5. **Timeliness:** Response during or immediately after attack

**Crisis mode must log:**
- Threat indicators that justified activation
- Rationale for each action taken
- Alternatives considered and why rejected
- Outcome and effectiveness

### Legal Hackback Protocol

When pursuing attacker (EU Article 15):

```markdown
## Legal Hackback Checklist

Before counter-intrusion:
- [ ] Active attack in progress OR immediate threat to safety
- [ ] Attacker identity reasonably certain (IP, TTPs, attribution)
- [ ] Goal: Identify attacker, assess damage, prevent further harm
- [ ] NOT: Retaliation, destruction, or exceeding scope
- [ ] All actions logged with timestamp and rationale
- [ ] Legal counsel notified (if time permits)

During operation:
- [ ] Minimize collateral damage
- [ ] Document everything (screenshots, logs, evidence)
- [ ] Stop if encounter innocent third-party systems
- [ ] Preserve evidence for law enforcement

Post-operation:
- [ ] Report to authorities (CERT, law enforcement)
- [ ] Document findings in incident report
- [ ] Assess whether attacker is still threat
- [ ] Update defenses based on findings
```

---

## Implementation Tasks

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

---

## Open Questions

1. **Activation authority:** Who can activate crisis mode?
   - Only root/admin?
   - Pre-authorized responders?
   - Anyone with physical access?

2. **Automatic vs manual:** Should crisis mode activate automatically on detection, or always require human confirmation?

3. **Team coordination:** How do multiple responders collaborate during crisis?
   - Shared session?
   - Separate sessions with coordination channel?
   - Leader delegates tasks to team?

4. **Third-party systems:** What if counter-intrusion encounters innocent systems (compromised servers)?
   - Stop immediately?
   - Document and continue?
   - Notify owner?

5. **Disclosure:** After incident, what gets disclosed publicly?
   - Full timeline?
   - Sanitized summary?
   - Nothing (OPSEC)?

---

## Success Criteria

- [ ] Can respond to active attack in <2 minutes
- [ ] All operations logged for legal defensibility
- [ ] Zero accidental catastrophic errors (dd to wrong device, etc.)
- [ ] Team can coordinate effectively during crisis
- [ ] Post-incident review is automated and comprehensive
- [ ] Compliant with EU law (NIS2, GDPR, Article 15)

---

## References

- EU NIS2 Directive: https://digital-strategy.ec.europa.eu/en/policies/nis2-directive
- GDPR Article 32: https://gdpr-info.eu/art-32-gdpr/
- Active Cyber Defense (legal analysis): https://www.ccdcoe.org/research/tallinn-manual-20/

---

**Created:** 2026-04-06  
**Last updated:** 2026-04-06
