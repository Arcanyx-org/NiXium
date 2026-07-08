<!-- SUMMARY: Evaluate and implement post-quantum cryptography (Kyber vs NTRU Prime) for NiXium's age/ragenix secret management. LOAD WHEN: Working on encryption, secrets management, or post-quantum crypto. SKIP WHEN: Not working on crypto or secrets. -->

# Quest: Post-Quantum Cryptography Implementation

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Open |
| **Priority** | High |
| **Created** | 2026-04-06 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |
| **Legacy #** | 03 |

## Objective

Evaluate and implement post-quantum cryptography for NiXium, specifically comparing Kyber (NIST ML-KEM) vs NTRU Prime for age/ragenix secret management.

## Background

**Current state:**
- Using rage (Rust implementation of age) for secrets
- Threat model includes post-quantum adversaries
- Q-day preparation is critical requirement
- CRYSTALS-Kyber currently untrusted by maintainer

**Key concerns:**
1. **Kyber (NIST ML-KEM):** NIST selection process controversial, NSA involvement raises red flags (Dual_EC_DRBG history), uses structured lattices (potential hidden weaknesses)
2. **NTRU Prime:** Designed explicitly to avoid Kyber's potential issues, based on older more studied NTRU, more conservative security margin
3. **Risk:** Maintainer has bias against Kyber, need academic validation

## Research Questions

### 1. Technical Comparison
- [ ] What are the specific security assumptions of Kyber vs NTRU Prime?
- [ ] What evidence exists for/against Kyber's structured lattice approach?
- [ ] What are the performance trade-offs (key size, speed, memory)?
- [ ] What library support exists in Nix ecosystem?

### 2. NIST Selection Controversy
- [ ] What were the original NTRU Prime vs Kyber evaluation criteria?
- [ ] Did NIST change selection rules mid-process?
- [ ] What cryptographers have published concerns?
- [ ] Are concerns technical or political?

### 3. Threat Model Alignment
- [ ] What is NiXium's specific post-quantum threat timeline?
- [ ] What data needs protection beyond Q-day?
- [ ] Do we need interoperability with NIST-standard-only systems?
- [ ] Should we use hybrid approach (multiple PQ algorithms)?

### 4. Implementation Options
- [ ] Is NTRU Prime available in nixpkgs?
- [ ] Is liboqs (Open Quantum Safe) packaged?
- [ ] Can we integrate with existing age/ragenix workflow?
- [ ] What's the migration path from current secrets?

## Proposed Solutions (To Evaluate)

### Option 1: NTRU Prime Only
**Pros:** Avoids Kyber controversy, more conservative security approach, aligns with maintainer's trust model
**Cons:** Less standardized (harder interop), potentially less library support, may need custom tooling

### Option 2: Kyber Only
**Pros:** NIST standard (easier interop), better library support, faster smaller keys
**Cons:** Trust concerns (NIST process, NSA involvement), structured lattice potential weaknesses, goes against zero-trust principle

### Option 3: Hybrid (Kyber + NTRU Prime)
**Pros:** Defense in depth — must break BOTH, hedges against either being compromised, aligns with zero-trust model
**Cons:** More complex implementation, larger keys, slower operations, increased maintenance burden

### Option 4: Hybrid (Classical + PQ)
**Pros:** Protected against quantum AND classical attacks, smooth migration path, works with current tooling
**Cons:** Still need to choose which PQ algorithm, larger overhead

## Secret Management Improvements

### Current Issues
1. **Outsider barrier:** Non-key-holders can't work on infrastructure
2. **Nix-store world-readable:** Secrets exposed if not careful
3. **Manual rotation:** Weekly rotation desired but not automated

### Proposed Improvements

1. **Automatic Secret Generation** — When outsider tries to deploy, automatically generate placeholder secrets
2. **Runtime Secret Injection** — Never store secrets in nix-store
3. **Automated Weekly Rotation** — Systemd timer for secret rotation

## Success Criteria

- [ ] Academic validation (not just bias) for algorithm choice
- [ ] Secrets never exposed in nix-store
- [ ] Outsiders can work on infrastructure without key access
- [ ] Weekly rotation happens automatically
- [ ] Post-quantum secure against conservative threat model
- [ ] Well-documented for future contributors

## References

- [NIST Post-Quantum Cryptography](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [NTRU Prime](https://ntruprime.cr.yp.to/)
- [Open Quantum Safe (liboqs)](https://openquantumsafe.org/)
- age format: https://age-encryption.org/
- ragenix: https://github.com/yaxitech/ragenix