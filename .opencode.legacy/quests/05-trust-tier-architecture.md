# Quest: Trust Tier Architecture for Multi-Model Deployment

**Priority:** MEDIUM  
**Status:** Not Started  
**Assigned:** TBD

---

## Objective

Design a multi-agent architecture with different trust tiers based on model hosting (proprietary cloud vs local) and sensitivity of data accessed.

## Background

**Problem:** Claude (and other cloud models) may leak data to providers. Anthropic could be compromised, or use conversations for training.

**Zero-trust principle:** Assume all proprietary models are compromised. Design defense-in-depth.

**Available resources:**
- 40-core cluster for running local models
- Can deploy GLM, DeepSeek, Gemma locally
- Maintainer reports good results with these models

---

## Proposed Trust Tiers

### Tier 1: Public (Cloud Models - Claude, GPT, etc.)
**Trust level:** Assume all data leaked to model provider

**Allowed access:**
- Public repository code
- Architecture discussions
- Documentation
- Planning and research
- Non-sensitive configuration

**NOT allowed:**
- Decrypted secrets
- Incident response details
- Vulnerability details before patch
- Customer/user data
- Attack attribution

**Models:**
- Claude Sonnet 4 (Anthropic)
- GPT-4 (OpenAI)
- Gemini (Google)

**Use cases:**
- General development
- Code review (public code)
- Documentation writing
- Architecture planning

---

### Tier 2: Sensitive (Local Models - Limited Trust)
**Trust level:** Assume model is secure, but environment may be compromised

**Allowed access:**
- Encrypted secrets (age-encrypted)
- Infrastructure configuration
- Internal documentation
- Non-critical vulnerabilities
- Development databases (sanitized)

**NOT allowed:**
- Decrypted production secrets
- Production databases
- Critical zero-days before patch
- Legal/compliance documents

**Models:**
- GLM (local)
- DeepSeek (local)
- Gemma 27B (local)
- Llama 3.x (local)

**Use cases:**
- Nix code with encrypted secrets
- Security testing (non-critical)
- Internal tool development
- Configuration management

---

### Tier 3: Critical (Isolated Local Models - High Trust)
**Trust level:** Assume model and environment are secure

**Allowed access:**
- Decrypted production secrets
- Live production systems
- Critical zero-days
- Incident response
- Legal/compliance documents
- Customer/user data (if necessary)

**NOT allowed:**
- Network access (air-gapped)
- External API calls
- Telemetry to external services

**Models:**
- Isolated local instance (no network)
- Audited code only
- Separate hardware if possible

**Use cases:**
- Production secret management
- Critical incident response
- Zero-day mitigation
- Compliance audits

---

## Agent Configuration by Tier

### opencode.json Structure

```json
{
  "$schema": "https://opencode.ai/config.json",
  
  "agent": {
    "public-researcher": {
      "tier": 1,
      "model": "anthropic/claude-sonnet-4",
      "description": "Public research and planning",
      "permission": {
        "read": {
          "*": "allow",
          "**/.age": "deny",
          "**/.env": "deny",
          "**/secrets/*": "deny"
        }
      }
    },
    
    "sensitive-developer": {
      "tier": 2,
      "model": "local/gemma-27b",
      "description": "Development with encrypted secrets",
      "permission": {
        "read": {
          "*": "allow",
          "**/.age": "allow",  // Can read encrypted
          "**/secrets/*.age": "allow"
        },
        "tools": {
          "age-decrypt": "deny"  // Cannot decrypt
        }
      }
    },
    
    "critical-operator": {
      "tier": 3,
      "model": "local/gemma-27b-isolated",
      "description": "Production operations with secret access",
      "permission": {
        "*": "allow",
        "network": "deny"  // Air-gapped
      },
      "environment": {
        "isolated": true,
        "network": false,
        "telemetry": false
      }
    }
  }
}
```

---

## Workflow Examples

### Scenario 1: Adding New Feature
```
1. User: /public-researcher
   "Research how to add Prometheus monitoring"
   - Claude researches, provides plan
   - No secret access

2. User: /sensitive-developer  
   "Implement Prometheus config with encrypted secrets"
   - Gemma (local) writes Nix code
   - References age-encrypted secrets
   - Cannot decrypt, uses placeholders

3. User: (manual or /critical-operator)
   "Deploy to production"
   - Isolated agent decrypts secrets
   - Deploys with real values
   - No external communication
```

### Scenario 2: Security Incident
```
1. Alert: Suspicious login attempts detected

2. User: /sensitive-developer
   "Analyze logs, identify attack pattern"
   - Local agent reviews logs
   - Identifies attacker IP, TTPs
   - Proposes countermeasures

3. User: /critical-operator
   "Block attacker, assess damage"
   - Isolated agent executes blocks
   - Checks for data exfiltration
   - Reviews accessed secrets
   - Logs everything for legal

4. User: /public-researcher
   "Write sanitized incident report"
   - Claude writes public disclosure
   - No sensitive details included
```

---

## Secret Management Per Tier

### Tier 1 (Public): Placeholders Only
```nix
# Claude sees this
services.myapp = {
  apiKeyFile = config.age.secrets.myapp-key.path;
  # Path visible, content encrypted
};
```

### Tier 2 (Sensitive): Encrypted Access
```nix
# Gemma (local) sees this + can read .age files
age.secrets.myapp-key = {
  file = ./secrets/myapp-key.age;  # Can read encrypted content
  # Cannot decrypt without keys
};
```

### Tier 3 (Critical): Full Access
```nix
# Isolated agent has age keys
# Can decrypt and use real secrets
# But no network access to leak
```

---

## Implementation Phases

### Phase 1: Basic Tier Separation
- [ ] Deploy local models (GLM, DeepSeek, Gemma) on 40-core cluster
- [ ] Configure OpenCode to use different models per agent
- [ ] Test basic tier 1 (Claude) vs tier 2 (local) workflow

### Phase 2: Permission Enforcement
- [ ] Implement file access restrictions per tier
- [ ] Block tier 1 agents from reading sensitive paths
- [ ] Block tier 2 agents from decrypt operations
- [ ] Audit logging of access attempts

### Phase 3: Isolated Tier 3
- [ ] Set up air-gapped environment for tier 3
- [ ] Deploy isolated model instance (no network)
- [ ] Implement secure communication channel (manual/sneakernet?)
- [ ] Test critical operations workflow

### Phase 4: Automation
- [ ] Automatic tier selection based on task
- [ ] Workflow orchestration (tier 1 → tier 2 → tier 3)
- [ ] Secret rotation integrated with tiers
- [ ] Monitoring and alerting

---

## Technical Challenges

### 1. Model Deployment
**Challenge:** Running GLM/DeepSeek/Gemma locally at acceptable speed

**Options:**
- Use 40-core cluster with GPU acceleration
- Quantized models (4-bit, 8-bit) for speed/memory trade-off
- Model caching to reduce load time
- Load balancing across cores

### 2. Context Transfer
**Challenge:** Passing context from tier 1 (Claude) to tier 2 (local) without leaking secrets

**Solution:**
- Tier 1 produces sanitized plan
- Plan explicitly marks secret placeholders
- Tier 2 reads plan + has access to encrypted secrets
- Tier 3 has decrypt keys

### 3. Air-gapped Tier 3
**Challenge:** How to communicate with isolated environment?

**Options:**
- **Physical transfer:** USB drive with encrypted commands
- **One-way network:** Can receive commands, cannot send data out
- **Local console:** Direct terminal access only
- **Secure relay:** Intermediate system with audit logging

### 4. User Experience
**Challenge:** Switching between tiers should be seamless, not annoying

**Solutions:**
- Automatic tier suggestion based on task
- Clear indicators which tier is active
- Easy tier switching with `/tier <name>`
- Workflows that span tiers automatically

---

## Open Questions

1. **Tier 2 hosting:** Run on same cluster as tier 3, or separate?
   - Same: Convenient, but tier 3 isolation at risk
   - Separate: More secure, but higher resource cost

2. **Model selection:** Which local model for which tier?
   - GLM: Best for what?
   - DeepSeek: Best for what?
   - Gemma 27B: Best for what?

3. **Tier 3 access:** Who can invoke tier 3 agent?
   - Only root?
   - Pre-authorized operators?
   - Anyone during crisis mode?

4. **Audit retention:** How long to keep logs?
   - Tier 1: Short (public data)
   - Tier 2: Medium (encrypted secrets)
   - Tier 3: Long (decrypted operations)

5. **Compliance:** Does this satisfy regulatory requirements?
   - GDPR: Data processor agreements with model providers
   - NIS2: Critical infrastructure security
   - SOC2/ISO27001: Access controls

---

## Success Criteria

- [ ] Zero secrets leaked to cloud providers (tier 1 agents)
- [ ] Local models perform acceptably (response time <30s)
- [ ] Tier 3 is genuinely air-gapped (no network escape)
- [ ] Workflow is smooth (not constantly fighting tier restrictions)
- [ ] Audit trail is complete (know who accessed what when)
- [ ] Compliant with regulations (GDPR, NIS2, etc.)

---

## Cost-Benefit Analysis

### Costs
- **Resource:** Running local models on 40-core cluster
- **Complexity:** Managing 3 tiers instead of 1
- **Speed:** Local models may be slower than Claude
- **Maintenance:** Keep local models updated

### Benefits
- **Security:** Secrets never leave infrastructure
- **Compliance:** Meet regulatory requirements
- **Independence:** Not dependent on cloud provider availability
- **Cost:** After initial setup, local inference is free
- **Control:** Full control over model behavior

### Break-even
If preventing one secret leak saves X hours of incident response and reputational damage, the investment is worth it if:

```
(Setup cost + Ongoing cost) < (Probability of leak × Cost of leak)
```

With Claude having already found critical zero-days, probability of leak is non-trivial.

---

## References

- OpenCode multi-agent docs: https://opencode.ai/docs/agents
- GLM deployment guide: TBD
- DeepSeek local hosting: TBD
- Air-gapped ML inference: TBD

---

**Created:** 2026-04-06  
**Last updated:** 2026-04-06
