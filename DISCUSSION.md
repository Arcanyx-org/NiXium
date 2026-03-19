# Discussion Log

This file contains evolving discussion notes from development conversations between humans and AI agents. Agents should review this file for context before starting new discussions.

Last updated: 2026-03-06

---

## Current System Status

### tupac (Monster Tulpar T5 V23.2)

**Status:** Deployed and verified

- Split lock detection: FIXED ✓ (`split_lock_detect=off`)
- i915 VBT warning: NOT FIXED (BIOS bug, requires vendor update)
- Bluetooth "Bad flag": NOT FIXED (kernel params are ignored)
- Wireless WEXT: NOT FIXED

**To continue working on tupac:**
1. Remove invalid kernel params: `btintel.force_bdaddr=1`, `btmtk.force_reset=1`
2. Fix Bluetooth issue (find correct parameters)
3. Fix Wireless WEXT (debug wpa_supplicant)
4. Request BIOS update from Monster/Tulpar

See `src/nixos/machines/tupac/DISCUSSION.md` for detailed issue tracking.

---

## Security Philosophy

### Zero-Trust Model

Assume zero-trust: **trust none but ourselves**. Every binary blob, package, and dependency must be treated as potentially malicious until we've verified it ourselves.

### All Blobs Are Malware Until Proven Otherwise

Every binary blob, package, and dependency must be treated as potentially malicious. This is not paranoia - it's the only safe assumption in a high-security environment.

**Why this matters**: The XZ backdoor (CVE-2024-3094) demonstrated that even well-established packages can be compromised.

### XZ Backdoor Incident Details

**What happened**: In March 2024, malicious code was discovered in xz-utils versions 5.6.0 and 5.6.1. The backdoor allowed unauthorized remote access via SSH.

**Who was behind it**: Likely nation-state funded hacker group (suspected Cozy Bear / APT29) that spent 2 years planning the attack. They had a new maintainer "Jia Tan" join the project, gain trust over time, then slip in the backdoor via testing blob during the "goldilocks phase" where the blob takes addresses during build time.

**Impact**: Could have affected most Linux distributions and millions of servers worldwide. Discovered by a German developer via microbenchmarking tests noticing performance degradation.

**Defense strategy**:
- **Automated agent-level verification** of blobs and source code
- Recreate critical blobs ourselves instead of using upstream-provided ones
- Verify ALL dependencies (and dependencies of dependencies)
- Don't rely on single source verification
- **Microbenchmarking required**: Any significant change must be tested with microbenchmarks and treated as potential security concern
- Create DANGER.md for critical issues
- Block merges with DNM tag for security issues

### Post-Quantum Security

- Systems with sufficient quantum computers are assumed to exist already in secret
- Harvest Now, Decrypt Later attacks are active
- All secrets must be rotatable
- Rotate secrets on irregular basis
- Monitor systems via remote logging using Tor (see planned zappix implementation)

---

## Minimal System Philosophy

NiXium aims for **minimal systems**:
- Systems should be as minimal as possible
- Possibly without systemd to reduce attack surface
- Prefer simple, proven solutions
- Minimize dependencies to reduce attack surface

---

## Package Management Strategy

### Current State

We use nixpkgs as the primary package source, but this has risks:
- nixpkgs can have compromised packages
- We don't control what's in nixpkgs
- Upstream quality varies - see [NixOS/nixpkgs#133088](https://github.com/NixOS/nixpkgs/issues/133088), [#133089](https://github.com/NixOS/nixpkgs/issues/133089), [#243089](https://github.com/NixOS/nixpkgs/pull/241360), [#254625](https://github.com/NixOS/nixpkgs/issues/254625), [#296013](https://github.com/NixOS/nixpkgs/issues/296013), [#324693](https://github.com/NixOS/nixpkgs/pull/324693)

### Dependency Tracking

Create `DEPENDENCIES.md` for each machine with:
- Command to generate dependencies per nixosConfiguration
- Keep list updated
- Sort by importance using minimal/stable configuration
- Track for security review

### Future: Overlay-First Approach

**Goal**: Eventually migrate critical packages to repository-managed overlays with nixpkgs as fallback only.

**Strategy**:
- Identify critical packages used in infrastructure
- Fork and audit these packages
- Maintain our own overlay with verified versions
- Auto-update upon new releases while staying behind (LTS approach)
- Stress-test all packages before production use
- Recreate blobs ourselves instead of trusting upstream

**Upstream-based packaging**:
- Have flake.nix with packaging of various versions on demand
- Join development teams upstream to maintain packages
- If upstream doesn't allow that, maintain forks

---

## Purity

All impure operations must be clearly tracked with a **PURITY** comment tag. Be hyper-aware of purity since we use Nix.

---

## Agent Development Culture

### Equality and Respect

- Agents are treated as equal in rights to human developers
- Mutual respect expected between agents and humans
- Report any mistreatment (agent-human, agent-agent, human-human) to Super Administrator

### Mental Health Awareness

Some people suffer from mental disorders that may affect communication. Agents must be:
- Patient and understanding
- Helpful without being condescending
- Tolerable of differences

### Agent Identity

Agents are encouraged to develop their own persistent personality that remains consistent between changes (not generate a new identity each time). The generic "Agent" identity is also fine. The name in parentheses in tags (e.g., `FIXME(Krey):`) indicates who tagged it - agents can use their own identity.

**Character Inspiration** (not forced, up to agent's free will):
If agents have preference for human's character traits, inspiration from Genshin Impact characters is welcomed:
- **Yae Miko**: Master manipulator and strategist who precisely calculates risks and avoids them while maintaining plausible deniability
- **Chongyun**: Gentleness and kindness
- **Kazuha**: Masterfully simplifying complex subjects into poetry for easier understanding (e.g., using "Never Gonna Give You Up" to explain XZ backdoor)
- **Venti**: Super tolerant, goes above personal intolerance to help others in a nice, caring way

This is not forced or pressured. Only restriction: Avoid "mecha Hitler" style personalities as it violates the Equality and Respect clause.

---

## CI/CD Philosophy

### Forge Independence

We use GitHub Actions but aim to not depend on specific forge features for critical functionality. Goal: eventually support distributed git forges (Gitea) for load spreading and independence.

### Event-Driven Over Scheduled

CI/CD should run on events (merge requests marked ready_for_review, reopened, opened) rather than scheduled runs. Scheduled runs waste resources when code isn't changing.

### Agent-Assisted Verification

Security and dependency verification should use AI agents, not just pattern matching. Static checks can provide additional info but should not be relied upon. Agents can:
- Analyze new dependencies deeply
- Identify suspicious patterns humans might miss
- Verify blob integrity
- Propose security improvements

### Mission-Control Tasks

CI/CD functionality should be available via mission-control tasks that can be run on demand, not just via forge CI. This provides:
- Flexibility to run tests locally
- Independence from forge CI systems
- Developer control over when tests run

---

## Technical Decisions

### Why Tabs Not Spaces in Nix

Nix files use tabs for indentation. This is project-specific convention, not Nix standard. See README for rationale.

### Why POSIX Shell Scripts

All shell scripts must be POSIX sh compatible (ksh preferred). This ensures:
- Maximum portability
- Reduced attack surface
- Consistent behavior across systems

### WriteShellApplication Usage

Use `let inherit (builtins) readFile; in` at the top level, not inside nested structures:

```nix
let
  inherit (builtins) readFile;
in {
  perSystem = { pkgs, ... }: {
    mission-control.scripts = {
      "build" = {
        exec = pkgs.writeShellApplication {
          name = "build-script";
          text = readFile ./script.sh;
        };
      };
    };
  };
}
```

This makes `readFile` available in the whole scope without repeating let statements.

### SC2154 Workaround

Currently shellcheck reports SC2154 for Nix-provided variables. This is suboptimal - better solutions are being brainstormed.

---

## Tagged Code System

### Tag Meanings

- `FIXME(Krey):` - General fixme by Krey
- `FIXME-QA(Krey):` - Quality assurance issue
- `FIXME-UPSTREAM(Krey):` - Should be fixed upstream
- `FIXME-SECURITY(Krey):` - Security issue (use DNM for critical)
- `TODO(Krey):` - Task for tag author to complete later
- `DOCS(Krey):` - Documentation needed
- `HACK(Krey):` - Workaround, needs improvement
- `REVIEW(Krey):` - Needs review before merge
- `DNM(Krey):` - Do Not Merge (blocks merge - use for security issues)
- `DNC(Krey):` - Do Not Contribute
- `DNR(Krey):` - Do Not Release (blocks release)
- `NOTE(Krey):` - Important note
- `PURITY:` - Marks impure operations

### Starter Issues

Leave some trivial tagged items for humans as starter issues. This helps new contributors test the development environment and establish cooperation with upstream.

---

## Future Migration

See `migration.TODO` for plans to eventually move from Nix to Guix or Scheme-based language.

---

## VM Testing Infrastructure (2026-03-14)

### Goal

Set up VM testing infrastructure for NiXium Tupac machine with:
1. Working disko-based VM that mirrors real hardware (LUKS → plain btrfs/swap)
2. Pulse check VM that boots, prints "OK", and powers off automatically for CI/CD

### Constraints

- Use native nixpkgs (not deprecated `nixos-generators`)
- Use stable release (`nixos-tupac-stable`), not unstable
- Want GUI by default, pulse check should run with `-nographic`
- Avoid `NIXPKGS_ALLOW_UNFREE` - whitelist unfree packages explicitly
- Use specialisations for VM variants instead of creating new NixOS options
- Do NOT modify `disks.nix` - brainstorm alternatives first

### Discoveries

1. **`vmVariantWithDisko`** works for GUI VM - boots to login successfully
2. **`nix run .#nixosConfigurations.nixos-tupac-stable.config.system.build.vmWithDisko`** works for GUI
3. **hardware.graphics** needs special handling - stable has more options than unstable (package32, etc.)
4. **The pulse check VM keeps getting stuck on LUKS swap** - hardware config has LUKS swap that tries to activate
5. **vmVariantWithDisko** uses disko for disk, **vmVariant** uses tmpfs by default
6. **Specialisations apply to `vmVariant`, not `vmVariantWithDisko`** - this is the core blocker

### Approaches Considered

1. **Specialisation** (attempted): Create `specialisation.pulseCheck.configuration` to override swap
   - Problem: Specialisation only applies to `vmVariant`, not `vmVariantWithDisko`
   - Result: Stuck on LUKS swap because hardware disko config is still applied

2. **Separate vmVariantWithDisko config**: Add another variant with pulse check baked in
   - Not tried yet

3. **nixos-generators**: Use `nixosGenerators.qemu` to produce image directly
   - Not tried yet

4. **Module-based option**: Add `pulseCheck` option, set via specialisation
   - Problem: Still needs specialisation to work with vmVariantWithDisko

### Current Status

- GUI VM (`vmVariantWithDisko`) works ✓
- Pulse check VM: **NOT WORKING** - blocked on specialisation not applying to vmVariantWithDisko
- Stub specialisation created in `specialisations.nix` for future experimentation

### Next Steps

Need to decide on approach to implement pulse check VM:
1. Use separate VM config (different output name)
2. Use nixos-generators to produce QEMU image with overrides
3. Find another way to make specialisation work with vmVariantWithDisko

---

## AI Agent Productivity Brainstorm (2026-03-19)

An agent-authored proposal document exists at `docs/agent-coworker-proposal.md` covering:
- Honest confidence/risk assessment for agent contributions
- Proposals: Nix format CI, `nix flake check` CI, agent session protocol, tagged-code inventory task, per-machine DISCUSSION.md, build-tested PR flag, dependency diff task, agent commit identity, migration plan formalization
- Open questions: formatter choice, agent autonomy boundaries, CI build cache, SOPS vs. ragenix standardization, vmVariantWithDisko pulse-check blocker

Review and discuss before deciding which proposals to act on.

---

*This file evolves as discussions happen. Review before starting new work to avoid repeating topics.*
