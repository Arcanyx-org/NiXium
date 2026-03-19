# AI Agent Coworker: Productivity Proposal (Revised)

**Date:** 2026-03-19 (original), revised 2026-03-19 based on maintainer feedback
**Author:** GitHub Copilot Agent
**Purpose:** Honest assessment of agent productivity confidence in NiXium, and concrete proposals for what could be done differently to improve the human–agent collaboration workflow.

This is a brainstorming document. Treat every proposal here as a conversation starter, not a final decision. Proposals marked **[ACTIONED]** have been implemented in this PR or a linked branch.

---

## 1. Confidence Assessment (Revised)

### Where I Am Confident

| Area | Confidence | Notes |
|------|-----------|-------|
| Flake-parts module architecture | High | AGENTS.md explains this clearly; pattern is consistent throughout |
| Machine config structure | High | Template machine and AGENTS.md leave little ambiguity |
| Nix language syntax + lib usage | High | `lib.mkMerge`, `lib.mkIf`, `lib.trivial.release` patterns well-established |
| Shell script conventions | High | `pkgs.writeShellApplication`, POSIX sh, shellcheck pass are clear |
| Tagged code conventions | High | Tag taxonomy documented and used consistently |
| Documentation authoring | High | README.md, DISCUSSION.md, AGENTS.md give clear style signals |
| Release-independent modules | Medium-High | Pattern documented; still needs a build test to validate |
| VM builds | Medium | devShell provides all tools; the appimage module shows the exact pattern to follow |

### Where I Am Less Confident

| Area | Confidence | Reason |
|------|-----------|--------|
| Secret management (ragenix / SOPS) | Medium | Keys are machine-specific and cannot be tested without actual hardware keys; mistakes here are high-impact |
| Hardware-specific configurations | Low | Kernel params, disko layouts, and hardware quirks require real hardware or a validated VM; VM testing covers most cases but not micro-architectural changes |
| Impermanence integration | Medium | Module exists and is implemented (`src/nixos/modules/system/impermenance/` — note: intentional typo matching actual dir name); needs re-verification that all machines use it correctly |
| Security audit depth | Low-Medium | See elaboration below |

### VM Build Clarification

In the initial assessment I rated VM build verification as "Low" confidence because the agent environment did not appear to support running builds. This was **incorrect**. The project provides a complete devShell via direnv + Nix that includes all required tools. The appimage module (`src/nixos/modules/programs/appimage/default.nix`) demonstrates the proven VM testing pattern with pulse checks. Agents SHOULD use this pattern and SHOULD run `nix build` / `nix run` via the devShell for verification.

The AGENTS.md has been updated with the correct VM build pattern.

### Honest Risk Assessment

**Agents will reliably help with:**
- Documentation improvements and corrections
- CI/CD workflow additions (new GitHub Actions jobs, mission-control tasks)
- Refactoring well-understood config patterns
- Self-contained tagged code items (`FIXME-QA`, `FIXME-DOCS`, `FIXME-UPSTREAM`)
- Shell scripts (shellcheck compliance, POSIX portability)
- VM-based module testing following the appimage module pattern

**Agents SHOULD NOT autonomously:**
- Make decisions about cryptographic algorithms or key rotation policy
- Touch secrets infrastructure without human review (every PR already goes through human review, but extra caution applies here)
- Deploy to real hardware (VMs only)

### Security Audit Depth: Elaboration

The initial assessment was too vague. Here is a more honest breakdown:

**What AI agents CAN do in security review:**
- Static analysis of Nix expressions for common patterns (world-readable files, hardcoded credentials, excessive permissions)
- Cross-referencing against known CVE databases and NVD for used packages
- Reviewing firewall rules, SSH config, sudo/sudo-rs configuration for obvious misconfigurations
- Checking that secrets use age/ragenix and are not readable world-wide
- Verifying impermanence configuration covers expected paths
- Flagging FIXME-SECURITY and DNM tags for human follow-up

**What AI agents CANNOT reliably do:**
- Microbenchmarking (cannot run real hardware tests to detect timing-channel attacks like the XZ detection method)
- Post-quantum cryptographic correctness review (requires specialized domain expertise)
- Side-channel analysis (requires hardware-level instrumentation)
- Verify blob integrity without being able to rebuild the blob ourselves
- Detect sophisticated supply-chain attacks embedded in transitive dependencies at source level

**What is needed for a functional AI-agent security workflow:**
1. A structured "security review checklist" per module type (machine config, service, secret)
2. Access to a tool that can query the GitHub Advisory Database or NVD for all flake inputs
3. A mission-control task that generates a dependency manifest per nixosConfiguration for review
4. Clear policy on which FIXME-SECURITY items are agent-actionable vs. human-only
5. Post-quantum module checklist once PQ support in age/ragenix matures

---

## 2. Proposals

### P.1 — Formatter Choice **[ACTIONED: nixpkgs-fmt commented out]**

**Original proposal:** Add nixpkgs-fmt CI enforcement.

**Maintainer feedback:** The project does NOT use nixpkgs-fmt. It enforces a custom style (Nx Language Standard, tabs) that conflicts with nixpkgs-fmt's output (spaces). nixpkgs-fmt was present in the devShell but should be commented out.

**Action taken in this PR:** Commented out `nixpkgs-fmt` from the devShell and `formatter` output in `flake.nix` with a `FIXME-QA` tag explaining why.

**Outstanding question:** The project still needs a formatter. Options:
- `alejandra` — opinionated but makes Nix harder to read per maintainer
- `treefmt` — configurable, could potentially support tabs
- Custom formatter or lint rules
- Document the current style explicitly enough that human/agent review enforces it

This is a separate discussion; a dedicated merge request is the right place.

---

### P.2 — `nix flake check` and Shellcheck in CI

**Original proposal:** Add a `nix flake check --no-build` CI job.

**Maintainer feedback clarification:**
- `nix flake check` does NOT run shellcheck itself — shellcheck is baked into `pkgs.writeShellApplication` wrappers which run at derivation evaluation time. So shellcheck compliance IS already enforced as a side-effect of building.
- The shellcheck task (`tasks/checks/shellcheck/`) is agent-generated and currently blocked (`exit 66` in the script, `DNM` tagged). It is not yet active.
- A `nix flake check --no-build` job would still be useful for catching evaluation errors early in CI without waiting for a full build.

**Recommendation:** Implement `nix flake check --no-build` as a CI job in a separate merge request. Note that this will catch shellcheck failures transitively when modules are evaluated.

---

### P.3 — Session Protocol for Agents **[ACTIONED]**

**Action taken in this PR:** Added a "Session Protocol" section to `AGENTS.md` with explicit MUST-complete checklists for session start and end, plus specific DISCUSSION.md update rules aimed at opencode.ai agents that have struggled with this.

---

### P.4 — Tagged Code Inventory Task

**Status:** Recommended for a separate merge request.

**Proposal:** Add a `, tagged-code` mission-control task that lists all tagged items grouped by type and file, with line numbers.

This is a low-risk, high-value addition. The grep pattern already exists in AGENTS.md and README.md; the task just makes it a one-keystroke command.

```nix
"tagged-code" = {
  description = "List all tagged code items (FIXME, TODO, DOCS, etc.)";
  category = "Checks";
  exec = pkgs.writeShellApplication {
    name = "tasks-tagged-code";
    runtimeInputs = [ pkgs.gnugrep pkgs.coreutils ];
    # NOTE: Keep this pattern in sync with the one documented in AGENTS.md
    text = ''
      grep -rn --include="*.nix" --include="*.sh" \
        -P "(FIXME|TODO|DOCS|HACK|REVIEW|DNM|DNC|DNR)((\-.*|)\(.*\)):" \
        . | sort -t: -k1,1 -k2,2n
    '';
  };
};
```

---

### P.5 — Per-Machine DISCUSSION.md Template

**Status:** Recommended for a separate merge request.

**Proposal:** Add a minimal `DISCUSSION.md` template to `src/nixos/machines/template/` so that any agent working on a new machine has a starting point. Only `tupac` currently has a machine-specific discussion file.

---

### P.6 — Build-Tested Flag in PRs

**Maintainer feedback:** GitHub's CI/CD UI already provides this context via check status on each PR. The proposal as written is redundant.

**Withdrawn.** The CI pipeline is the right place for this.

---

### P.7 — Dependency Change Review

**Maintainer feedback:** There is already an `update` task (`, update` → `nix flake update --verbose`) in `tasks/release/update/default.nix`. The initial proposal missed this.

**Corrected understanding:** The `update` task updates all flake inputs. The verbose output shows which inputs changed. A more useful addition would be a human-readable summary comparing the old and new `flake.lock` (old SHA → new SHA per input), but this is lower priority given the current infrastructure state.

---

### P.8 — Agent Identity in Commit Messages

**Status:** Recommended for a separate merge request.

**Maintainer note:** Good idea, but the implementation needs more thought. The right place to discuss the exact format (trailer? bracket suffix? git config?) is in a dedicated merge request.

---

### P.9 — Migration Plan Formalization

**Status:** Recommended for a separate merge request, after the codebase stabilizes.

**Maintainer note:** The infrastructure is currently in crisis recovery / experimental branch mode. A formal migration plan document is appropriate once the codebase stabilizes.

---

## 3. Secret Management Module Proposal

**Background (from maintainer):** The current ragenix-based secret management requires existing infrastructure keys to work. This means agents and new contributors cannot generate secrets independently. The ideal solution is a custom Nix module that:
1. Includes a command to generate secrets from scratch (so anyone — including agents — can bootstrap)
2. Places secrets during deployment via a service (NOT via `readFile`, which would make them world-readable in the Nix store)
3. Works as an alternative to or wrapper around ragenix

The pattern for runtime secret placement is already demonstrated in the existing ragenix integration; see `src/nixos/machines/hana/config/disks.nix` for an example of `age.secrets.<name>.path` being passed to a service.

### Problem with `readFile`

Using `builtins.readFile` on a secret file in a Nix expression causes the secret to be copied into the world-readable Nix store. This is explicitly prohibited. The correct approach is:

```nix
# WRONG — copies secret into /nix/store (world-readable)
environment.etc."my-service/config".text = builtins.readFile ./secret.age;

# CORRECT — ragenix decrypts to a tmpfs path at runtime, only accessible to root
age.secrets."my-service-config".file = ./secret.age;
environment.etc."my-service/config".source = config.age.secrets."my-service-config".path;
```

### Proposed Design: `nx-secrets` Module

A custom NixOS module `nixosModules.nx-secrets` that provides:

```nix
# Usage in a machine config:
nx.secrets = {
  enable = true;

  # Declare secrets with their generator commands
  secrets."machine-disk-password" = {
    generator = "openssl rand -base64 32";  # Command to generate the secret
    recipients = [ config.age.publicKeys.machine config.age.publicKeys.admin ];
    targetPath = "/run/secrets/disk-password";  # Where to place it at runtime
    permissions = "0400";
    owner = "root";
  };
};
```

The module would provide:
1. A mission-control task `, secrets-generate [secret-name]` that runs the generator command and encrypts the result with the declared recipients, producing a `.age` file
2. A systemd service (activated at boot) that decrypts and places secrets at `targetPath` using an in-memory tmpfs — NOT the Nix store
3. Integration with the existing `src/nixos/secrets.nix` pattern

### Bootstrap Workflow for New Contributors/Agents

```sh
# 1. Generate a new age key for yourself
age-keygen -o ~/.config/age/keys.txt

# 2. Add your public key to secrets.nix recipients
# 3. Run the generator for any secret you need
, secrets-generate machine-disk-password

# 4. Commit the .age file (encrypted, safe to commit)
# 5. On deployment, the systemd service decrypts to tmpfs
```

### Security Properties

- Secrets never appear in the Nix store
- Generator commands are auditable (in the Nix expression)
- Each secret has explicit recipient list (who can decrypt)
- Runtime path is on tmpfs (cleared on reboot)
- Compatible with existing ragenix infrastructure

### Implementation Notes

- Build on top of existing ragenix module (do not replace it initially)
- The generator command approach mirrors what PostmarketOS does with device keys
- Consider integration with the planned PQ module once available
- Reference: impermanence module pattern for tmpfs-based secret placement

---

## 4. Hardware Staging Proposal

**Background (from maintainer):** VM testing covers most changes well. The gap is micro-architectural changes (kernel patches, CPU microcode, specific hardware bugs). Ideally: a physical copy of the hardware as a staging system with remote management, including ability to alter firmware on demand (similar to PostmarketOS's approach).

### Proposed GitHub Issue Tracking

Create an issue in the repository with:

**Title:** `[INFRA] Hardware Staging System for Micro-Architectural Testing`

**Content:**
- Goal: Duplicate hardware unit (same model as tupac or other critical machines) available for remote-controlled testing
- Requirements: Remote power control, IPMI/BMC or equivalent, ability to reflash firmware
- Precedent: PostmarketOS maintains test hardware with remote control
- Acceptance criteria: Agents can trigger tests on real hardware via CI pipeline
- Current workaround: VM testing covers most cases; hardware-specific changes require manual human testing

---

## 5. Impermanence Integration Review

**Status:** Needs re-verification.

The impermanence module exists at `src/nixos/modules/system/impermenance/system-impermenance.nix` and appears well-implemented:
- Creates user persist directories via `systemd.tmpfiles.rules`
- Configures `environment.persistence` for system directories
- Sets `age.identityPaths` correctly
- Handles `boot.impermanence.enable` flag

**Items to verify per machine:**
1. Does the machine's `default.nix` import the impermanence module?
2. Is `boot.impermanence.enable = true` set in the machine's setup config?
3. Are machine-specific persistent paths declared (databases, service state, etc.)?
4. Is the SSH host key path included in `age.identityPaths`?

**Typo note:** The module path is `impermenance` (not `impermanence`) — this is a pre-existing typo in the codebase. Do not rename it without a migration plan.

---

## 6. What Should NOT Change (Confirmed)

The following are working well per maintainer confirmation:

- **flake-parts architecture** — scales well, AGENTS.md explains it
- **POSIX shell preference** — correct for threat model and portability
- **`pkgs.writeShellApplication` for scripts** — avoids rebuilds, shellcheck baked in
- **Release-independent modules via attrset** — avoids evaluating non-matching bodies
- **ragenix with PQ module** — preferred for secrets (SOPS supported but ragenix primary)
- **SOPS + ragenix both in flake** — keep both; the system should be modular for both
- **DISCUSSION.md as a living log** — most valuable continuity document

---

## 7. New Tag Proposals

The maintainer noted the tag system should grow to attract more specialized contributions. Proposed additions (to be discussed in separate merge requests):

| Proposed Tag | Meaning |
|-------------|---------|
| `FIXME-PQ:` | Post-quantum cryptography upgrade needed |
| `FIXME-HARDENING:` | Security hardening opportunity |
| `FIXME-PERF:` | Performance issue (relates to microbenchmark requirement) |
| `FIXME-PRIVACY:` | Privacy issue (data exposure, logging, telemetry) |
| `FIXME-DEPS:` | Dependency needs review or upgrade |
| `FIXME-COMPAT:` | Compatibility issue across releases or architectures |
| `FIXME-BLOB:` | Binary blob that needs verification or recreation |
| `CONTRIB:` | Good contribution opportunity for newcomers |
| `AUDIT:` | Needs security audit |

---

## 8. Open Questions (Remaining)

1. **Formatter:** `alejandra` makes Nix harder to read per maintainer; nixpkgs-fmt uses wrong style. Explore `treefmt` with custom rules, or document the current style precisely enough for enforcement. Separate merge request.

2. **Cachix cache:** Currently offline due to infrastructure crisis. When restored, CI builds become feasible for per-machine verification.

3. **SOPS vs. ragenix standardization:** Both supported; ragenix with PQ module is preferred for new secrets. Agents should use ragenix for all new secret declarations unless there is a specific reason for SOPS.

4. **P.2 shellcheck CI:** The shellcheck task (`tasks/checks/shellcheck/`) has a `DNM` tag and `exit 66`. This needs to be resolved before shellcheck can run in CI as a standalone job. The `writeShellApplication` wrapper already runs shellcheck at evaluation time, which is the primary enforcement mechanism.

---

*Review this document alongside DISCUSSION.md and AGENTS.md. All proposals marked [ACTIONED] have been implemented in this branch.*
