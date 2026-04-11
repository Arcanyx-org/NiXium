# Quest: Post-Quantum Cryptography Implementation

**Priority:** HIGH  
**Status:** Not Started  
**Assigned:** TBD

---

## Objective

Evaluate and implement post-quantum cryptography for NiXium, specifically comparing Kyber (NIST ML-KEM) vs NTRU Prime for age/ragenix secret management.

## Background

**Current state:**
- Using rage (Rust implementation of age) for secrets
- Threat model includes post-quantum adversaries
- Q-day preparation is critical requirement
- CRYSTALS-Kyber currently untrusted by maintainer

**Key concerns:**
1. **Kyber (NIST ML-KEM):**
   - NIST selection process controversial
   - NSA involvement raises red flags (Dual_EC_DRBG history)
   - Uses structured lattices (potential hidden weaknesses)
   - Reports that NIST changed rules to favor Kyber over NTRU Prime

2. **NTRU Prime:**
   - Designed explicitly to avoid Kyber's potential issues
   - Based on older, more studied NTRU
   - More conservative security margin
   - Preferred by open-source crypto community members

3. **Risk:** Maintainer has bias against Kyber, need academic validation

---

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

---

## Proposed Solutions (To Evaluate)

### Option 1: NTRU Prime Only
**Pros:**
- Avoids Kyber controversy
- More conservative security approach
- Aligns with maintainer's trust model

**Cons:**
- Less standardized (harder interop)
- Potentially less library support
- May need custom tooling

### Option 2: Kyber Only
**Pros:**
- NIST standard (easier interop)
- Better library support
- Faster, smaller keys

**Cons:**
- Trust concerns (NIST process, NSA involvement)
- Structured lattice potential weaknesses
- Goes against zero-trust principle

### Option 3: Hybrid (Kyber + NTRU Prime)
**Pros:**
- Defense in depth - must break BOTH
- Hedges against either being compromised
- Aligns with zero-trust model

**Cons:**
- More complex implementation
- Larger keys, slower operations
- Increased maintenance burden

### Option 4: Hybrid (Classical + PQ)
**Pros:**
- Protected against quantum AND classical attacks
- Smooth migration path
- Works with current tooling

**Cons:**
- Still need to choose which PQ algorithm
- Larger overhead

---

## Secret Management Improvements

### Current Issues
1. **Outsider barrier:** Non-key-holders can't work on infrastructure
2. **Nix-store world-readable:** Secrets exposed if not careful
3. **Manual rotation:** Weekly rotation desired but not automated

### Proposed Improvements

#### 1. Automatic Secret Generation
When outsider tries to deploy, automatically generate placeholder secrets:

```nix
age.secrets.myservice-key = {
  file = ./secrets/myservice-key.age;
  generator = pkgs.writeShellApplication {
    name = "generate-myservice-key";
    text = ''
      # If can't decrypt, generate new placeholder
      if ! age --decrypt ${./secrets/myservice-key.age} 2>/dev/null; then
        echo "Generating placeholder secret for development..."
        openssl rand -hex 32 | age --encrypt -o ${./secrets/myservice-key.age}
      fi
    '';
  };
};
```

#### 2. Runtime Secret Injection
Never store secrets in nix-store:

```nix
systemd.services.myservice = {
  preStart = ''
    # Fetch/generate at runtime
    SECRET=$(fetch-or-generate-secret myservice-key)
    echo "$SECRET" > /run/secrets/myservice-key
    chmod 600 /run/secrets/myservice-key
  '';
  
  serviceConfig = {
    RuntimeDirectory = "secrets";
    ExecStart = "${pkg}/bin/myservice --secret-file /run/secrets/myservice-key";
  };
};
```

#### 3. Automated Weekly Rotation
```nix
systemd.services.secret-rotation = {
  description = "Weekly secret rotation";
  
  script = ''
    for secret in ${config.age.secrets}; do
      # Generate new key
      NEW_KEY=$(generate-key)
      # Re-encrypt with new key
      age --decrypt "$secret" | age --encrypt -r "$NEW_KEY" > "$secret.new"
      mv "$secret.new" "$secret"
    done
    
    # Deploy to infrastructure
    nixos-rebuild switch
  '';
  
  serviceConfig = {
    Type = "oneshot";
    User = "root";
  };
  
  startAt = "weekly";
};
```

---

## Deliverables

1. **Research report:**
   - Technical comparison of Kyber vs NTRU Prime
   - NIST selection controversy analysis
   - Academic validation of security claims
   - Recommendation with rationale

2. **Implementation plan:**
   - Chosen algorithm(s) with justification
   - Migration strategy from current age setup
   - Testing approach (VM, then production)

3. **Secret management improvements:**
   - Automatic placeholder generation
   - Runtime injection (no nix-store exposure)
   - Weekly rotation automation
   - Documentation for contributors

4. **Benchmarks:**
   - Performance comparison (Kyber vs NTRU Prime vs hybrid)
   - Key size comparison
   - Interoperability testing

---

## Success Criteria

- [ ] Academic validation (not just bias) for algorithm choice
- [ ] Secrets never exposed in nix-store
- [ ] Outsiders can work on infrastructure without key access
- [ ] Weekly rotation happens automatically
- [ ] Post-quantum secure against conservative threat model
- [ ] Well-documented for future contributors

---

## Notes

- Maintainer has strong bias against Kyber (NIST/NSA distrust)
- Need to separate bias from technical analysis
- Zero-trust model suggests hybrid approach (don't trust single algorithm)
- Consider: If NIST is compromised, what ELSE is compromised? (OS, compiler, etc.)

---

## References

- [NIST Post-Quantum Cryptography](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [NTRU Prime](https://ntruprime.cr.yp.to/)
- [Open Quantum Safe (liboqs)](https://openquantumsafe.org/)
- age format: https://age-encryption.org/
- ragenix: https://github.com/yaxitech/ragenix

---

**Created:** 2026-04-06  
**Last updated:** 2026-04-06
