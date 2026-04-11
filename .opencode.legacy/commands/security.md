# /security - Security Review and Threat Analysis

**Invokes:** `security-reviewer` agent (Claude Sonnet 4)

**Purpose:** Security-focused code review, threat modeling, hardening verification

## Usage

```bash
/security <code, file, or security question>
```

## When to Use

Use `/security` when you need:
- Security review of new or modified code
- Threat modeling for components
- Verification of hardening measures
- Secret management review
- Zero-trust compliance checking
- Attack surface analysis

## Examples

```bash
# Code review
/security Review src/nixos/machines/router/config/firewall.nix
/security Check if this systemd service is properly hardened

# Threat modeling
/security What are the attack vectors for the monitoring service?
/security Analyze security implications of adding this new service

# Compliance
/security Does this configuration follow zero-trust principles?
/security Verify all secrets are properly encrypted

# Specific concerns
/security Is this file permission secure?
/security Review the TLS configuration for the web server
```

## Expected Output

Security review provides structured findings:

### 🔴 Critical Issues (Blocking)
Must be fixed before merge:
- Plaintext secrets
- Missing firewall rules
- World-readable sensitive files
- Disabled security features
- Known vulnerable configurations

### 🟡 Warnings (Should Fix)
Should be addressed, not necessarily blocking:
- Missing optional hardening
- Suboptimal permissions
- Weak cryptography (not broken, but could be stronger)
- Missing defense-in-depth layers

### 🟢 Recommendations (Nice to Have)
Improvements beyond minimum requirements:
- Additional hardening options
- Enhanced monitoring
- Better isolation
- Forward-looking improvements (post-quantum readiness)

### ✅ Compliant
What's done correctly:
- Proper use of age-encrypted secrets
- Strong systemd hardening
- Zero-trust principles followed
- Defense-in-depth implemented

## Output Format Example

```markdown
## Security Review: services/monitoring/prometheus.nix

### 🔴 CRITICAL: Missing Network Isolation
**Issue:** Prometheus metrics endpoint exposed on 0.0.0.0:9090
**Impact:** Internal metrics (potentially sensitive) accessible from external network
**Fix:** 
```nix
services.prometheus.listenAddress = "127.0.0.1";
# Or use firewall to restrict:
networking.firewall.allowedTCPPorts = lib.mkForce [];  # Don't expose
```

### 🔴 CRITICAL: No Systemd Hardening
**Issue:** Service runs without security options
**Impact:** If compromised, attacker has broad system access
**Fix:** Add to systemd.services.prometheus.serviceConfig:
```nix
ProtectSystem = "strict";
ProtectHome = true;
PrivateTmp = true;
NoNewPrivileges = true;
ReadWritePaths = [ "/var/lib/prometheus" ];
```

### 🟡 WARNING: Retention Period Too Long
**Issue:** Metrics retained for 365 days (high disk usage, privacy concern)
**Impact:** Old data may no longer be needed, increases attack value
**Recommendation:** Reduce to 90 days unless longer retention justified
```nix
services.prometheus.retentionTime = "90d";
```

### ✅ COMPLIANT: Proper Secret Management
**Good:** API keys use age encryption, not plaintext
```nix
age.secrets.prometheus-api-key.file = ./secrets/api-key.age;
```

### ✅ COMPLIANT: TLS Enabled
**Good:** HTTPS with strong cipher suites

## Overall Assessment
**Status:** ❌ NOT READY FOR MERGE (2 critical issues)
**Risk Level:** HIGH (network exposure + privilege escalation risk)

Fix critical issues, then re-review.
```

## Security Review Checklist

When you invoke `/security`, the agent checks:

### Systemd Hardening
- [ ] ProtectSystem = "strict" or "full"
- [ ] ProtectHome = true
- [ ] PrivateTmp = true
- [ ] NoNewPrivileges = true
- [ ] PrivateDevices (if devices not needed)
- [ ] ReadWritePaths explicitly defined
- [ ] User/Group or DynamicUser set

### Secrets Management
- [ ] No plaintext secrets in .nix files
- [ ] age.secrets.* used for all sensitive data
- [ ] Secret files have mode 0400 or 0600
- [ ] Secrets not in Nix store
- [ ] API keys, passwords, certs all encrypted

### Network Security
- [ ] Firewall enabled (networking.firewall.enable = true)
- [ ] Minimal open ports
- [ ] TLS 1.3 minimum
- [ ] Strong cipher suites
- [ ] mTLS for service-to-service
- [ ] Certificate validation enabled

### File Permissions
- [ ] Sensitive files: 0400 or 0600
- [ ] Config files: 0644 (if no secrets)
- [ ] No world-writable (0666, 0777)

### Access Control
- [ ] SSH key-only (no password auth)
- [ ] Sudo restricted
- [ ] Principle of least privilege

## Threat Models Considered

Security-reviewer analyzes these threat scenarios:

### External Attacker
- Network-based attacks (port scanning, exploitation)
- Supply chain attacks (compromised dependencies)
- Social engineering (phishing, credential theft)

### Insider Threat
- Malicious user with legitimate access
- Compromised user credentials
- Privilege escalation

### Compromised Service
- Application vulnerability exploited
- Service running as root
- Lateral movement to other services
- Persistence mechanisms

### Physical Access
- Disk extraction (LUKS encryption)
- Cold boot attacks (memory encryption)
- Evil maid attacks (secure boot)

## Integration Workflow

Typical security workflow:
1. Developer writes code
2. `/quick` validates syntax
3. `/nix` ensures code quality
4. **`/security`** reviews security
5. Fix any issues
6. `/security` re-review
7. Merge when ✅ compliant

## Performance

- **Speed:** Thorough, not fast (expect 1-3 minutes)
- **Token usage:** High (loads security context)
- **Cost:** Moderate (Claude Sonnet 4)

## Tips for Better Results

**Provide full context:**
- ✅ "Review src/nixos/machines/router/config/firewall.nix - this handles external traffic"
- ❌ "Is this secure?" (what is "this"?)

**Specify concerns:**
- ✅ "I'm worried about secret exposure in this service config"
- ❌ "Check for security issues" (too vague)

**Include threat model:**
- ✅ "This service is internet-facing, review for external attack vectors"
- ❌ No context about service purpose

## When to Use vs. Other Commands

| Task | Command |
|------|---------|
| Is this code secure? | `/security` ✅ |
| How does security work here? | `/research` |
| Fix this vulnerability | `/nix` (after security identifies it) |
| Does this have syntax errors? | `/quick` |

## Known Strengths

- Thorough threat analysis
- Identifies subtle vulnerabilities
- Explains impact clearly
- Provides specific fixes
- Understands zero-trust architecture

## Common Findings

Most common security issues found:

1. **Missing systemd hardening** (60% of issues)
2. **Plaintext secrets** (20% of issues)
3. **Overly permissive firewall** (10% of issues)
4. **Weak file permissions** (5% of issues)
5. **Other** (5%)

## Success Criteria

Good security review:
- ✅ Finds real vulnerabilities
- ✅ Explains impact/risk
- ✅ Suggests specific fixes
- ✅ Balances security with usability
- ✅ Educates (explains why)

Poor security review:
- ❌ False positives
- ❌ Vague warnings
- ❌ No actionable fixes
- ❌ Overly paranoid
- ❌ Misses obvious issues

## Post-Review Actions

After security review:

### If Critical Issues Found (🔴)
1. Fix immediately
2. Re-run `/security` to verify
3. Do NOT merge until ✅

### If Warnings Found (🟡)
1. Evaluate: Is fix needed now or later?
2. Create TODO/FIXME if deferring
3. Document decision

### If Compliant (✅)
1. Proceed to merge
2. Document security decisions in commit message
