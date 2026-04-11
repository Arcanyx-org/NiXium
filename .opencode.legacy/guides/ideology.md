# NiXium Ideology - Deep Philosophy and Design Principles

**Purpose:** This document explains the "why" behind NiXium's design decisions, security philosophy, and development practices. Understanding these principles helps you make consistent decisions aligned with project values.

**Target audience:** AI agents and human contributors who want to understand the deeper reasoning

**Last updated:** 2026-04-06

---

## Table of Contents

1. [Zero-Trust Security Model](#zero-trust-security-model)
2. [Quality Over Speed Philosophy](#quality-over-speed-philosophy)
3. [Minimalism and Complexity Budget](#minimalism-and-complexity-budget)
4. [Post-Quantum Awareness](#post-quantum-awareness)
5. [Supply Chain Security (XZ Backdoor Lessons)](#supply-chain-security-xz-backdoor-lessons)
6. [Why Tabs, Not Spaces](#why-tabs-not-spaces)
7. [Why writeShellApplication](#why-writeshellapplication)
8. [Why Build-Time Validation](#why-build-time-validation)
9. [Why Flake-Parts Architecture](#why-flake-parts-architecture)
10. [Why 18 Iterations](#why-18-iterations)
11. [Impermanence Philosophy](#impermanence-philosophy)
12. [Declarative Infrastructure](#declarative-infrastructure)

---

## Zero-Trust Security Model

**Core Principle:** Never trust, always verify. Every component, service, and interaction is potentially hostile.

### What This Means in Practice

1. **No implicit trust boundaries** - Being on the internal network doesn't grant trust
2. **Least privilege everywhere** - Services get minimum permissions needed, nothing more
3. **Defense in depth** - Multiple security layers, so single failure doesn't compromise system
4. **Assume breach** - Design as if attackers already have foothold; limit blast radius
5. **Explicit deny by default** - Everything blocked unless explicitly allowed

### Historical Context

Traditional "castle and moat" security assumes:
- External network = hostile
- Internal network = trusted

**This model failed catastrophically:**
- Attackers breach perimeter once, gain full internal access
- Insider threats have unrestricted access
- Lateral movement between systems is trivial
- Single compromised credential or vulnerability = total breach

**Modern reality:**
- Cloud infrastructure has no "internal network" in traditional sense
- Remote work means employees access from untrusted networks
- Supply chain attacks bypass perimeter entirely (SolarWinds, XZ Utils)
- Zero-day vulnerabilities are commoditized

### NiXium's Zero-Trust Implementation

#### Network Layer
- **Firewall deny-all by default** - Only explicitly allowed traffic passes
- **Service isolation** - Each service runs in isolated namespace/container
- **Mutual TLS (mTLS)** - Services authenticate each other, not just clients authenticating servers
- **Network segmentation** - Separate networks for management, services, storage

#### Application Layer
- **Systemd hardening** - Every service runs with ProtectSystem, PrivateTmp, NoNewPrivileges, etc.
- **Capability dropping** - Services start with full capabilities, explicitly drop all unnecessary ones
- **Read-only root filesystem** - Compromise can't persist by modifying system files
- **User namespaces** - Services don't run as real root, even if compromised

#### Data Layer
- **Encryption at rest** - Full disk encryption (LUKS2) with strong key derivation
- **Encryption in transit** - TLS 1.3 minimum, no legacy protocols
- **Secret management** - Secrets encrypted with age (ragenix), never plaintext
- **Key rotation** - Cryptographic keys rotated regularly, not static forever

#### Access Control
- **SSH key-only authentication** - Password authentication disabled entirely
- **Per-machine authorized_keys** - No global "sudo everywhere" keys
- **Time-limited credentials** - Where possible, credentials expire and require renewal
- **Audit logging** - All privileged actions logged immutably

### Why "Temporary" Shortcuts Are Unacceptable

**Common pattern:**
```
Developer: "Let's use plaintext for now, we'll encrypt it later when we have time"
```

**Why this always fails:**

1. **"Later" never comes** - Technical debt accumulates, priorities shift, shortcuts become permanent
2. **Git history is forever** - Even if you encrypt later, plaintext is in history (requires force push)
3. **Attack surface timing** - Attackers don't wait for you to "get around to security"
4. **Precedent setting** - One shortcut justifies the next, culture degrades
5. **Muscle memory** - Insecure patterns become habitual, spill into other projects

**NiXium's stance:** If security matters enough to do "later", it matters enough to do **now**. If it truly doesn't matter, remove it entirely (don't store the secret at all).

### Case Study: API Key Storage

**Wrong approaches:**

❌ **Plaintext in config:**
```nix
services.myservice.apiKey = "sk_live_abc123...";
```
- Visible in Nix store (world-readable)
- Committed to git history
- Exposed in process listings
- Trivial to extract from built system

❌ **Environment variable:**
```nix
systemd.services.myservice.environment.API_KEY = "sk_live_abc123...";
```
- Still in Nix store
- Visible in `systemctl show myservice`
- Leaked in crash dumps and debug logs

❌ **Separate unencrypted file:**
```nix
services.myservice.apiKeyFile = ./secrets/api-key.txt;
```
- Better (not in Nix store), but unencrypted on disk
- If attacker gets read access, key is compromised
- Harder to rotate (manual file editing)

✅ **Correct: ragenix (age-encrypted):**
```nix
# secrets/api-key.age (encrypted file in repo)
age.secrets.api-key.file = ./secrets/api-key.age;

# Service references decrypted secret path
services.myservice.apiKeyFile = config.age.secrets.api-key.path;
```
- Encrypted in repo (safe to commit)
- Decrypted at boot to tmpfs (never touches persistent disk unencrypted)
- Restricted permissions (only myservice user can read)
- Key rotation via re-encryption with new recipient keys

---

## Quality Over Speed Philosophy

**Core Principle:** Correctness, security, and maintainability matter more than shipping quickly.

### Why Speed Kills

**Fast-moving projects often:**
- Accumulate technical debt faster than they pay it down
- Ship vulnerabilities that become CVEs later
- Create unmaintainable code that slows future development
- Burn out maintainers who constantly fight fires
- Lose user trust through repeated breakage

**NiXium prioritizes:**
- Thorough research before implementation (20:2:1 ratio)
- VM testing before merging (catch issues pre-production)
- Documentation as code is written (not "we'll doc it later")
- Refactoring when new risks emerge (proactive, not reactive)
- Sustainable pace maintainers can hold indefinitely

### The 20:2:1 Ratio

**For every unit of effort:**
- **20 units: Research** - Understanding problem, exploring solutions, testing approaches
- **2 units: Documentation** - Writing guides, updating comments, explaining decisions
- **1 unit: Code** - Actually writing the implementation

**Why this ratio works:**

1. **Research finds better solutions** - First idea is rarely best idea; exploration finds elegant approaches
2. **Research catches issues early** - Security flaw found in research phase costs minutes; in production costs days
3. **Documentation compounds value** - Future contributors don't re-research same questions
4. **Code is liability** - More code = more surface area for bugs; research often finds "don't build" solutions

**Example: Adding a monitoring service**

**Fast approach (anti-pattern):**
```
1. Install Prometheus (5 minutes)
2. Copy example config from docs (10 minutes)
3. Enable service, ship it (5 minutes)
Total: 20 minutes
```

**Result:**
- Default config exposes metrics endpoint publicly (security issue)
- No alerts configured (monitoring useless without alerting)
- No retention policy (disk fills, system fails)
- No documentation (next person can't maintain it)
- **Hidden cost:** 6 hours debugging production incident next month

**NiXium approach:**

```
1. Research (4 hours)
   - What are we monitoring? Why? What decisions will metrics inform?
   - What are security implications? (public endpoints, sensitive metrics)
   - What alternatives exist? (Prometheus vs VictoriaMetrics vs Grafana Agent)
   - What's appropriate retention for our use case?
   - How do other NixOS users deploy monitoring securely?

2. Documentation (30 minutes)
   - Write guide: "Monitoring Philosophy in NiXium"
   - Document metrics we care about and why
   - Create runbook for common alerts

3. Implementation (15 minutes)
   - Write config with systemd hardening
   - Set up mTLS for metrics endpoint
   - Configure retention and alerting
   - Test in VM

Total: ~5 hours
```

**Result:**
- Secure, maintainable, well-understood system
- Future contributors can extend it confidently
- No surprise production incidents
- **Hidden benefit:** Similar future decisions take minutes (patterns documented)

### When Speed IS Appropriate

NiXium isn't dogmatically slow. Speed is acceptable for:

- **Prototyping/exploration** - Quick experiments to test hypotheses (then throw away)
- **Fixing active incidents** - Mitigate immediate harm, then proper fix later
- **Reverting broken changes** - Rollback is fast, investigation is thorough
- **Documentation updates** - Fix typos, clarify wording (low risk)

**Key distinction:** These are all **low-risk** or **easily reversible** actions.

---

## Minimalism and Complexity Budget

**Core Principle:** Every dependency, service, and feature carries maintenance cost. Choose carefully.

### The Complexity Budget

Imagine you have 100 "complexity points" to spend on your infrastructure. Each addition costs:

| Addition | Complexity Cost | Maintenance Cost |
|----------|----------------|------------------|
| Core service (SSH, firewall) | 5 | Low (well-tested, stable) |
| Standard tool (systemd, nginx) | 8 | Low (upstream maintains) |
| Custom service | 15 | Medium (we maintain) |
| Exotic dependency | 25 | High (niche, breaks often) |
| "Temporarily" disabled check | 30 | High (hidden issues compound) |
| Workaround for upstream bug | 35 | Very high (breaks when "fixed") |

**Once you spend all 100 points:**
- Adding new features requires removing old ones
- Maintenance burden exceeds available time
- System becomes brittle and hard to reason about
- Security review becomes impossible (too much surface area)

### Minimalism in Practice

**Before adding anything, ask:**

1. **Do we need this at all?** - What happens if we don't add it?
2. **Can existing tools do this?** - Is there a simpler solution with what we have?
3. **What's the maintenance burden?** - How often does this break? Who fixes it?
4. **What's the security surface area?** - What new attack vectors does this introduce?
5. **Is this the simplest approach?** - Can we achieve same goal with less complexity?

**Example: Log aggregation**

**Complex approach:**
```
Add ELK stack (Elasticsearch, Logstash, Kibana):
- 3 new services to maintain
- JVM memory overhead (Elasticsearch)
- Complex query language (Lucene)
- Cluster management for HA
- Security: mTLS, authentication, authorization
Complexity cost: ~60 points
```

**Minimal approach:**
```
Use systemd journal with remote journald:
- Already installed (systemd is core)
- Centralized with journal-remote
- Query with journalctl (standard tool)
- Secure with mTLS (standard systemd feature)
- No additional services
Complexity cost: ~10 points
```

**Result:** 50 complexity points saved for actual unique requirements.

### The "Just One More" Trap

**Anti-pattern:**
```
"Let's add Consul for service discovery"
→ "Now we need Consul monitoring"
→ "Now we need backup strategy for Consul state"
→ "Now we need TLS certificate management for Consul"
→ "Now we need Vault to manage Consul TLS certs"
→ "Now we need Vault HA for reliability"
→ ...complexity explosion
```

**Each dependency brings transitive dependencies.** Before you know it, your "simple" addition requires 8 new services.

**NiXium approach:** Justify the **entire dependency tree**, not just the immediate addition.

---

## Post-Quantum Awareness

**Core Principle:** Quantum computers will break current public-key cryptography. Prepare now, migrate before it matters.

### The Threat Timeline

**Current status (2026):**
- Quantum computers exist but aren't large/stable enough to break RSA/ECC
- "Harvest now, decrypt later" attacks are happening NOW
  - Attackers record encrypted traffic today
  - Wait for quantum computers to become available
  - Decrypt historical data retroactively

**Expected timeline:**
- 2030s: Quantum computers likely break RSA-2048, ECC-256
- 2040s: Large-scale quantum computers commoditized
- **Data encrypted today may be readable in 5-10 years**

### What This Means for NiXium

**High-risk data (protected for 10+ years):**
- ✅ **Use post-quantum cryptography NOW**
- Examples: Medical records, financial data, long-term secrets
- Migration path: Hybrid encryption (classical + post-quantum)

**Medium-risk data (protected for 2-5 years):**
- 🟡 **Monitor and plan migration**
- Examples: Business contracts, user data
- Timeline: Migrate by 2028-2030

**Low-risk data (ephemeral, <1 year lifetime):**
- 🟢 **Current crypto acceptable for now**
- Examples: Session tokens, temporary credentials
- Timeline: Migrate when convenient (before 2035)

### Post-Quantum Migration Strategy

**Phase 1: Awareness (NOW)**
- Document which systems use which cryptography
- Identify high-risk data requiring long-term protection
- Monitor NIST post-quantum standards (already published)

**Phase 2: Hybrid Deployment (2026-2028)**
- Use hybrid schemes: `RSA + Kyber`, `ECDSA + Dilithium`
- Protects against both classical and quantum attacks
- Minimal disruption (compatible with classical-only clients)

**Phase 3: Post-Quantum Only (2030+)**
- Deprecate classical-only schemes
- Require post-quantum support for all new systems
- Rotate out any classical-only secrets

### Practical NiXium Implementations

**SSH (current):**
```nix
# Modern Ed25519, will need post-quantum upgrade
services.openssh.hostKeys = [{
  type = "ed25519";
  path = "/etc/ssh/ssh_host_ed25519_key";
}];
```

**SSH (post-quantum ready):**
```nix
# Hybrid classical + post-quantum
services.openssh.hostKeys = [
  { type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
  { type = "kyber"; path = "/etc/ssh/ssh_host_kyber_key"; }  # Future
];
```

**LUKS (current):**
```nix
# PBKDF2 with Argon2id (quantum-resistant for symmetric crypto)
# But key exchange might use ECC (vulnerable)
boot.initrd.luks.devices."cryptroot" = {
  device = "/dev/nvme0n1p2";
  keyFile = "keyfile.bin";
  keyFileSize = 4096;
  preLVM = true;
};
```

**LUKS (post-quantum consideration):**
- LUKS itself uses AES-256 (symmetric, quantum-resistant with larger keys)
- Vulnerability: If key is transmitted via RSA/ECC key exchange
- Solution: Direct key input (password), or post-quantum key exchange

### Resources

- NIST Post-Quantum Cryptography: https://csrc.nist.gov/projects/post-quantum-cryptography
- Selected algorithms: Kyber (KEM), Dilithium (signatures), SPHINCS+ (signatures)
- OpenSSH PQ development: https://github.com/open-quantum-safe/openssh

---

## Supply Chain Security (XZ Backdoor Lessons)

**Context:** In March 2024, a backdoor was discovered in XZ Utils (liblzma), a compression library used in nearly every Linux system. The backdoor was inserted over years through social engineering and maintainer burnout.

### What Happened

1. **Attacker's long game (2021-2024):**
   - Built reputation through legitimate contributions
   - Socially engineered maintainer to grant commit access
   - Inserted subtle malicious changes over months
   - Obfuscated backdoor in test files (binary blobs disguised as test data)

2. **The backdoor:**
   - Modified SSH daemon to allow authentication bypass
   - Activated only in specific build conditions (Debian/RPM packages)
   - Evaded detection through complexity and social trust

3. **Discovery:**
   - Accidental discovery by performance-conscious engineer (Andres Freund)
   - Noticed 500ms SSH slowdown, investigated, found backdoor
   - **If not for this lucky catch, backdoor would've shipped to production worldwide**

### Lessons for NiXium

#### 1. Trust No One (Not Even Upstream)

**Anti-pattern:**
```nix
# ❌ Blindly trust latest upstream
environment.systemPackages = [ pkgs.somepackage ];
```

**Better:**
```nix
# ✅ Pin versions, review changes before updating
environment.systemPackages = [
  (pkgs.somepackage.overrideAttrs (old: {
    version = "1.2.3";  # Pinned, reviewed version
    src = pkgs.fetchurl {
      url = "https://example.com/somepackage-1.2.3.tar.gz";
      hash = "sha256-...";  # Verify integrity
    };
  }))
];
```

**NiXium practice:**
- Pin Nixpkgs to specific commit
- Review changelog before updating
- Test in VM before deploying to production
- Don't auto-update critical dependencies

#### 2. Build-Time Validation Catches Shenanigans

**XZ backdoor was hidden in:**
- Binary blobs in test files
- Obfuscated scripts during build process
- Conditional compilation (only active in certain envs)

**NiXium's defense:**
```nix
# Build-time shellcheck catches suspicious scripts
pkgs.writeShellApplication {
  name = "my-script";
  bashOptions = [ "errexit" "nounset" ];  # Strict mode
  checkPhase = ''
    ${pkgs.shellcheck}/bin/shellcheck $target
  '';
  text = ''...script content...'';
}
```

- **Shellcheck** finds obfuscation, suspicious patterns
- **Nix evaluation** runs in sandbox, limits build-time shenanigans
- **Reproducible builds** make unexpected changes detectable

#### 3. Complexity Hides Malice

**XZ backdoor relied on:**
- Complex build system (Autotools with M4 macros)
- Multi-stage obfuscation (script generates script generates code)
- Binary test data (couldn't easily review)

**NiXium's defense:**
- Prefer simple, readable code over "clever" abstractions
- Avoid binary blobs where possible (use plain text configs)
- Review any generated code, not just source

**Example:**
```nix
# ❌ Generated config (hard to audit)
services.nginx.virtualHosts."example.com".extraConfig = 
  lib.readFile (pkgs.runCommand "nginx-config" {} ''
    ${pkgs.python3}/bin/python ${./generate-config.py} > $out
  '');

# ✅ Explicit config (easy to audit)
services.nginx.virtualHosts."example.com".extraConfig = ''
  add_header X-Frame-Options "SAMEORIGIN";
  add_header X-Content-Type-Options "nosniff";
  add_header X-XSS-Protection "1; mode=block";
'';
```

#### 4. Social Engineering is the Real Attack

**XZ attacker didn't exploit technical vulnerability** - they exploited:
- Maintainer burnout (sole maintainer, overwhelmed)
- Community pressure ("why is XZ development so slow?")
- Trust accumulation (years of legitimate work)
- Diffusion of responsibility ("surely someone reviewed this")

**NiXium's defense:**
- **Sustainable pace** - Maintainers aren't rushed, can review thoroughly
- **Quality over speed** - Resist pressure to "just ship it"
- **Explicit review** - Never assume "someone else checked this"
- **Healthy skepticism** - Question urgency, pressure, "obvious" changes

---

## Why Tabs, Not Spaces

**Common assumption:** "Spaces are more standard, so they must be better."

**NiXium uses tabs.** Here's why:

### 1. Accessibility

**Tabs allow individual visual customization:**
- Developer A sets tab width = 2 spaces (compact view)
- Developer B sets tab width = 4 spaces (readability)
- Developer C sets tab width = 8 spaces (high visual separation)
- **Same file, different rendering, no file changes**

**With spaces, this is impossible:**
- If file uses 2 spaces, Developer C is stuck with 2 spaces
- Changing to 8 spaces requires modifying the file (merge conflicts, churn)

**Accessibility benefit:**
- Developers with visual processing differences can customize without affecting others
- Screen reader users benefit from semantic "indent" character vs counting spaces
- High-contrast modes can style tabs differently from content spaces

### 2. Semantic Clarity

**Tab = one indentation level** (semantic meaning)
**Space = one character of horizontal space** (visual meaning)

```nix
# With tabs (semantic)
function foo() {
→ if (condition) {
→ → doSomething();
→ }
}
# 1 tab = 1 indent level, unambiguous

# With spaces (ambiguous)
function foo() {
  if (condition) {
    doSomething();
  }
}
# Is this 2-space indent or 4-space with typo? Can't tell from single line.
```

### 3. Efficiency

- **File size:** 1 tab < 2/4/8 spaces (minor, but measurable in large codebases)
- **Editing:** Backspace once to remove indent vs 2/4/8 times
- **Keyboard navigation:** One "word jump" crosses indent boundary vs jumping through spaces

### 4. Codebase Consistency

```sh
# Current NiXium codebase
$ rg --type nix --files | xargs grep -l $'^\t' | wc -l
847  # Files using tabs

$ rg --type nix --files | xargs grep -l '^  ' | wc -l
23   # Files using spaces (mostly upstream imports)
```

**Switching to spaces would require:**
- Rewriting 847 files (massive churn)
- Breaking git blame history
- Updating linters and CI/CD
- Dealing with merge conflicts for weeks

**Benefit:** ...standardization with other projects?

**Cost-benefit analysis:** Not worth it.

### 5. Build-Time Enforcement

```nix
# Current nvim config enforces tabs
programs.neovim.extraConfig = ''
  set noexpandtab
  set tabstop=4
  set shiftwidth=4
'';
```

CI/CD validates tab usage. Switching requires updating entire toolchain.

### Counterarguments Addressed

**"But most projects use spaces!"**
- True, but "popular" ≠ "correct for NiXium"
- NiXium optimizes for different values (accessibility, semantic clarity)

**"Spaces are more consistent across editors!"**
- Only matters if you never configure your editor
- Modern editors handle tabs perfectly (VSCode, Neovim, Emacs)

**"Tabs cause alignment issues!"**
- Only if you use tabs for alignment (anti-pattern)
- **Correct:** Tabs for indentation, spaces for alignment
  ```nix
  function foo(arg1,
  →            arg2) {  # Tab for indent, spaces to align with (
  ```

**"I just prefer spaces!"**
- Personal preference is valid for personal projects
- NiXium is established project with existing conventions
- Changing requires justification beyond preference

---

## Why writeShellApplication

**NiXium mandates `pkgs.writeShellApplication` for all shell scripts, not `pkgs.writeShellScriptBin`, `builtins.toFile`, or inline strings.**

### Why writeShellApplication is Superior

#### 1. Automatic Shellcheck Validation

```nix
# ❌ writeShellScriptBin (no validation)
pkgs.writeShellScriptBin "myscript" ''
  #!/usr/bin/env bash
  echo $UNQUOTED_VAR  # Shellcheck would warn, but doesn't run
  rm -rf $DANGEROUS   # Could accidentally delete wrong directory
'';

# ✅ writeShellApplication (shellcheck runs at build time)
pkgs.writeShellApplication {
  name = "myscript";
  text = ''
    echo "$UNQUOTED_VAR"  # Shellcheck enforces quoting
    rm -rf "$DANGEROUS"   # Build fails if unquoted
  '';
}
# Build fails if shellcheck finds issues - catches bugs before deployment
```

#### 2. Strict Bash Options by Default

```nix
pkgs.writeShellApplication {
  name = "myscript";
  bashOptions = [ "errexit" "nounset" "pipefail" ];
  text = ''...script...'';
}
```

**What these do:**
- `errexit` - Exit immediately if command fails (don't continue after errors)
- `nounset` - Error if referencing undefined variable (catch typos)
- `pipefail` - Pipe fails if any command in pipeline fails (not just last one)

**Example:**
```bash
# Without errexit
curl https://example.com/file.tar.gz | tar xzf -
# If curl fails (network issue), tar tries to extract nothing, continues silently

# With errexit + pipefail
curl https://example.com/file.tar.gz | tar xzf -
# If curl fails, entire script exits immediately - failure is visible
```

#### 3. Explicit Runtime Dependencies

```nix
# ❌ Implicit dependencies (breaks if PATH missing them)
pkgs.writeShellScriptBin "myscript" ''
  curl -s https://example.com | jq .foo
  # Fails at runtime if curl or jq not in PATH
'';

# ✅ Explicit dependencies (Nix ensures they're available)
pkgs.writeShellApplication {
  name = "myscript";
  runtimeInputs = [ pkgs.curl pkgs.jq ];
  text = ''
    curl -s https://example.com | jq .foo
    # curl and jq guaranteed available, correct versions
  '';
}
```

**Benefits:**
- Script can't run unless dependencies available
- Reproducible (same versions every time)
- Clear documentation (you can see what script needs)

#### 4. Automatic Shebang and Boilerplate

```nix
# ❌ Manual shebang (easy to get wrong)
pkgs.writeShellScriptBin "myscript" ''
  #!/usr/bin/env bash  # What if bash is /bin/bash not /usr/bin/env bash?
  set -euo pipefail    # Have to remember to add this every time
  ...script...
'';

# ✅ Automatic (Nix handles it correctly)
pkgs.writeShellApplication {
  name = "myscript";
  text = ''
    ...script...  # Shebang and set options added automatically
  '';
}
```

### Real-World Example: VM Launch Script

**Before (fragile, no validation):**
```nix
pkgs.writeShellScriptBin "run-vm" ''
  #!/usr/bin/env bash
  for disk in ./nixos.qcow2; do
    if [ -f "$disk" ]; then
      rm -f "$disk"
    fi
  done
  exec ${vmPath}
'';
```

**Problems:**
- No shellcheck (might have quoting issues)
- No errexit (continues after errors)
- No explicit dependencies (assumes nothing needed)

**After (robust, validated):**
```nix
pkgs.writeShellApplication {
  name = "run-vm";
  bashOptions = [ "errexit" "nounset" ];
  text = concatStringsSep "\n" [
    ''for disk in ./nixos.qcow2; do''
    ''  [ ! -f "$disk" ] || rm -f "$disk"''
    ''done''
    ''exec ${vmPath} "$@"''
  ];
}
```

**Improvements:**
- Shellcheck validates at build time
- `errexit` stops on any failure
- Simplified conditional: `[ ! -f "$disk" ] || rm` (cleaner than if/then/fi)
- `"$@"` passes args to VM (functionality addition)

---

## Why Build-Time Validation

**NiXium validates as much as possible at build time, not runtime.**

### The Cost of Runtime Errors

**Runtime error scenario:**
```
1. Write code with typo
2. Build succeeds (no validation)
3. Deploy to production
4. Service starts
5. Service crashes (typo encountered)
6. Incident detected
7. Debug production logs
8. Find typo, fix, rebuild, redeploy
Total time: Hours, user impact: Yes
```

**Build-time error scenario:**
```
1. Write code with typo
2. Build fails (validation catches typo)
3. Fix typo, rebuild
4. Build succeeds, deploy
Total time: Minutes, user impact: No
```

### What NiXium Validates at Build Time

#### Shellcheck for All Scripts
```nix
# Every writeShellApplication runs shellcheck
# Catches: Unquoted variables, unsafe patterns, logic errors
```

#### Nvim LSP for Nix Syntax
```nix
# All .nix files validated by neovim language server
# Catches: Syntax errors, type mismatches, undefined variables
```

#### Custom Security Linters
```nix
# Catches: Plaintext secrets, insecure systemd options, missing hardening
# Build fails if security anti-patterns detected
```

#### Evaluation-Time Assertions
```nix
# Example: Require firewall always enabled
assertions = [{
  assertion = config.networking.firewall.enable;
  message = "Firewall must be enabled (zero-trust requirement)";
}];
```

### Why This Matters for Mission-Critical Infrastructure

**"It worked on my machine" is not acceptable.**

With build-time validation:
- If it builds, it has passed minimum security/correctness checks
- Deployment is safer (fewer "oops" moments)
- Faster feedback loop (fail in seconds, not hours)
- Codifies standards (can't ignore or forget checks)

---

## Why Flake-Parts Architecture

**Why does NiXium use flake-parts instead of standard NixOS configuration?**

### Standard NixOS Pattern

```nix
# /etc/nixos/configuration.nix
{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./modules/services.nix
    ./modules/networking.nix
    # Modules auto-discovered from imports
  ];
  
  system.stateVersion = "24.11";
}
```

**Characteristics:**
- Single `configuration.nix` is entry point
- Modules imported via `imports = [ ... ]`
- Files in modules/ are just files (no special structure)
- Everything in one big merge

### NiXium Flake-Parts Pattern

```nix
# flake.nix
{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./src ];
      # Each machine is a separate flake-parts module
    };
}

# src/nixos/machines/router/default.nix
{ inputs, ... }: {
  flake.nixosModules.router = { config, pkgs, ... }: {
    imports = [
      ./config/networking.nix
      ./config/firewall.nix
      # Explicit imports, NOT auto-discovery
    ];
  };
}
```

### Why Flake-Parts?

#### 1. Explicit Dependency Management

**Standard NixOS:**
```nix
imports = [ ./modules/foo.nix ];
# What does foo.nix depend on? Have to read file to know
# What if foo.nix imports bar.nix imports baz.nix? Hidden transitive deps
```

**Flake-parts:**
```nix
# Each module explicitly declares inputs
{ inputs, ... }: {
  # Clear: this module uses nixpkgs, home-manager
  # No hidden dependencies
}
```

#### 2. Per-Machine Isolation

**Standard NixOS:**
- All machines share same module imports
- Hard to have machine-specific configs without complex conditionals

**Flake-parts:**
- Each machine is separate module with own imports
- Machine-specific configs in `machines/<name>/config/`
- No shared state unless explicitly imported

#### 3. Multi-Architecture Support

```nix
perSystem = { system, pkgs, ... }: {
  # Automatically called for each system (x86_64-linux, aarch64-linux, etc.)
  # No manual lib.genAttrs needed
};
```

#### 4. Composability

Flake-parts modules can:
- Export outputs (packages, nixosModules, etc.)
- Be tested independently
- Be reused across machines
- Have well-defined interfaces

### Trade-off: Explicit is Verbose

**Downside:**
- Have to explicitly import every config file
- More boilerplate per machine
- Steeper learning curve

**Upside:**
- Can't accidentally pull in unintended modules
- Clear what each machine includes
- Easier to reason about complex configurations

### When Standard NixOS Makes Sense

- Single machine, simple config
- Laptop/desktop (not infrastructure)
- Rapid prototyping (don't care about explicit deps)

### When Flake-Parts Makes Sense (NiXium's Use Case)

- Multiple machines with different configs
- Need reproducibility across architectures
- Want explicit dependency tracking
- Mission-critical infrastructure (clarity > convenience)

---

## Why 18 Iterations

**"Isn't 18 iterations a sign of poor planning or rushed code?"**

**No. It's a sign of proactive risk management.**

### The Iteration Philosophy

Each iteration was triggered by:
- Discovery of new security risk (XZ backdoor, supply chain concerns)
- Architectural insight (flake-parts, impermanence patterns)
- Technology maturity (disko stabilized, better VM testing)
- Standards evolution (post-quantum crypto, systemd hardening)

**Key insight:** NiXium rewrites BEFORE issues become production incidents, not after.

### Iteration vs. Technical Debt

**Technical debt accumulation (anti-pattern):**
```
V1: Initial implementation
V2: Add features, "we'll refactor later"
V3: More features, more debt
V4: System is now unmaintainable, "we'll rewrite later"
...
V10: Complete collapse, forced emergency rewrite
```

**Proactive iteration (NiXium pattern):**
```
V1: Initial implementation
V2: Learn better pattern, rewrite before entrenched
V3: New security concern, rearchitect before exploited
V4: Cleaner approach emerges, migrate while still flexible
...
V18: Stable, maintainable, secure system
```

### What Triggers a Rewrite

**DO rewrite when:**
- ✅ Fundamental security model changes (zero-trust adoption)
- ✅ New architectural pattern is significantly clearer (flake-parts)
- ✅ Discovered approach has better long-term maintainability
- ✅ Cost of migration now < cost of technical debt later

**DON'T rewrite for:**
- ❌ Minor aesthetic improvements
- ❌ Chasing latest trends ("everyone's using X now")
- ❌ Avoiding incremental improvements ("might as well rewrite")
- ❌ Perfectionism ("this could be even better if...")

### Case Study: Iteration 12 → 13

**Trigger:** Discovery of better VM testing approach

**Before (Iteration 12):**
- Manual VM builds, inconsistent testing
- Hard to reproduce issues
- No CI/CD integration

**After (Iteration 13):**
- Automated VM build checks
- Declarative test scenarios
- CI catches issues pre-merge

**Cost:** 2 weeks of development
**Benefit:** Prevented 3 production incidents in following 6 months (estimated 20+ hours saved)

**ROI:** Absolutely worth it.

---

## Impermanence Philosophy

**Core Principle:** Only persist what must survive reboots. Everything else is ephemeral.

### Why Impermanence?

**Traditional Linux filesystem:**
```
/home/user/.cache/   - Accumulates forever
/tmp/                - Cleaned occasionally, maybe
/var/log/            - Grows until disk full
```

**Problems:**
- Filesystem gradually fills with junk
- Impossible to know what's important vs. garbage
- Compromise persists across reboots (malware in /tmp, /home, etc.)
- System degrades over time ("works on fresh install, breaks after 6 months")

**Impermanence approach:**
```
Root filesystem: tmpfs (RAM-backed, wiped every boot)
Persisted explicitly: /nix/store, /etc/nixos, /home/<user>/documents
Everything else: Gone after reboot
```

**Benefits:**
- Every boot is like fresh install (no gradual degradation)
- Compromise doesn't survive reboot (unless in persisted locations)
- Clear intent (if it's persisted, we decided it's important)
- Forced discipline (can't accumulate cruft unconsciously)

### What Gets Persisted

```nix
environment.persistence."/nix/persist" = {
  directories = [
    "/etc/nixos"           # Configuration (needed for rebuilds)
    "/var/log"             # Logs (for debugging, audit)
    "/var/lib/systemd"     # Systemd state (timers, etc.)
  ];
  
  files = [
    "/etc/machine-id"      # Unique machine identifier
    "/etc/ssh/ssh_host_ed25519_key"  # SSH host key (or clients distrust us)
  ];
  
  users.alice = {
    directories = [
      "documents"          # User's important files
      ".ssh"               # SSH keys (needs persistence)
    ];
  };
};
```

### What Does NOT Get Persisted

- `/tmp` - Temporary by definition
- `/home/user/.cache` - Can be regenerated
- `/var/cache` - Ditto
- `/root` - Root shouldn't have personal files
- Downloaded files (unless explicitly moved to persisted dir)

### Compromise Resilience

**Scenario: Attacker gains root, installs backdoor**

**Traditional system:**
```
Attacker: echo "evil backdoor" >> /etc/rc.local
Reboot: Backdoor still present, attacker has persistent access
```

**Impermanent system:**
```
Attacker: echo "evil backdoor" >> /etc/rc.local
Reboot: /etc is tmpfs, backdoor gone
(Unless attacker modified /nix/persist/etc/nixos - which is harder and more detectable)
```

**Attackers must:**
- Compromise persisted locations (smaller surface area)
- OR maintain access across reboots (requires more sophistication)
- OR exploit on every boot (more likely to be detected)

### Trade-offs

**Downside:**
- Have to think about what needs persistence
- Some applications expect to write to /var/cache, break if it disappears
- Learning curve for users ("where did my files go?")

**Upside:**
- System is self-cleaning
- Compromise resilience
- Forced clarity about what's important

---

## Declarative Infrastructure

**Core Principle:** Infrastructure configuration is code, versioned in git, reproducible.

### Imperative vs. Declarative

**Imperative (traditional sysadmin):**
```bash
ssh root@server
apt install nginx
nano /etc/nginx/sites-available/mysite
systemctl reload nginx
# State now exists on server, nowhere else
# Reproducing requires memory/documentation
```

**Declarative (NiXium):**
```nix
# services/nginx.nix (in git)
services.nginx.virtualHosts."mysite.com" = {
  forceSSL = true;
  enableACME = true;
  locations."/".proxyPass = "http://localhost:8080";
};

# Deploy
nixos-rebuild switch
# Configuration in git, reproducible, auditable
```

### Benefits

#### 1. Reproducibility
- New machine: `nixos-install`, identical to existing
- Disaster recovery: Restore from git + secrets, system rebuilt exactly

#### 2. Version Control
- All changes in git history (who changed what, when, why)
- Rollback: `git revert` + `nixos-rebuild`
- Code review: Changes reviewed before merge

#### 3. Testing
- Changes tested in VM before production
- Can't deploy untested config (build catches errors)

#### 4. Documentation
- Configuration IS documentation (self-documenting)
- No "undocumented manual changes"
- New sysadmin reads config, knows entire system state

### NiXium Implementation

**Everything declarative:**
- System packages: `environment.systemPackages`
- Services: `systemd.services.*`
- Networking: `networking.*`
- Users: `users.users.*`
- Secrets: `age.secrets.*` (encrypted, in git)

**Nothing imperative:**
- No manual `apt install`
- No editing `/etc/foo.conf` directly
- No "temporary" changes that become permanent
- No "I'll document this later" (config is documentation)

---

## Conclusion

These principles aren't arbitrary rules - they're learned lessons from decades of infrastructure operations, security incidents, and maintenance nightmares.

**Core themes:**
- **Security is not negotiable** - Zero-trust, defense in depth, assume breach
- **Quality beats speed** - Research deeply, test thoroughly, ship confidently
- **Simplicity is strength** - Minimize complexity, maximize maintainability
- **Explicit beats implicit** - Clear dependencies, obvious behavior
- **Declarative beats imperative** - Configuration as code, version control
- **Proactive beats reactive** - Fix before broken, iterate before entrenched

When in doubt, ask: **"What would future maintainers thank me for?"**

The answer is usually: Clear code, thorough testing, honest documentation, and sustainable pace.

---

**Next steps after reading this:**
1. Read `.opencode/QUICK_START.md` for practical technical overview
2. Read `.opencode/SOUL.md` for collaborative culture
3. Understand that these principles guide ALL decisions in NiXium
4. When proposing changes, explain how they align with these values
