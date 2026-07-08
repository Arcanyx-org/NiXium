<!-- SUMMARY: Multi-agent architecture with trust tiers based on model hosting (cloud vs local vs isolated). LOAD WHEN: Working on agent architecture, model selection, or security tiers. SKIP WHEN: Not working on multi-agent or trust architecture. -->

# Quest: Trust Tier Architecture for Multi-Model Deployment

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Open |
| **Priority** | Medium |
| **Created** | 2026-04-06 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |
| **Legacy #** | 05 |

## Objective

Design a multi-agent architecture with different trust tiers based on model hosting (proprietary cloud vs local) and sensitivity of data accessed.

## Background

**Problem:** Claude (and other cloud models) may leak data to providers. Anthropic could be compromised, or use conversations for training.

**Zero-trust principle:** Assume all proprietary models are compromised. Design defense-in-depth.

**Available resources:**
- 40-core cluster for running local models
- Can deploy GLM, DeepSeek, Gemma locally
- Maintainer reports good results with these models

## Proposed Trust Tiers

### Tier 1: Public (Cloud Models — Claude, GPT, etc.)
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

### Tier 2: Sensitive (Local Models — Limited Trust)
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

### Tier 3: Critical (Isolated Local Models — High Trust)
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

## Technical Challenges

1. **Model Deployment:** Running GLM/DeepSeek/Gemma locally at acceptable speed
2. **Context Transfer:** Passing context from tier 1 (Claude) to tier 2 (local) without leaking secrets
3. **Air-gapped Tier 3:** How to communicate with isolated environment?
4. **User Experience:** Switching between tiers should be seamless, not annoying

## Success Criteria

- [ ] Zero secrets leaked to cloud providers (tier 1 agents)
- [ ] Local models perform acceptably (response time <30s)
- [ ] Tier 3 is genuinely air-gapped (no network escape)
- [ ] Workflow is smooth (not constantly fighting tier restrictions)
- [ ] Audit trail is complete (know who accessed what when)
- [ ] Compliant with regulations (GDPR, NIS2, etc.)