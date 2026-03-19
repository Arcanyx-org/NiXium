# AI Agent Coworker: Productivity Proposal

**Date:** 2026-03-19
**Author:** GitHub Copilot Agent (this document)
**Purpose:** Honest assessment of agent productivity confidence in NiXium, and concrete proposals for what could be done differently to improve the human–agent collaboration workflow.

This is a brainstorming document. Treat every proposal here as a conversation starter, not a final decision. The author welcomes pushback, corrections, and refinements.

---

## 1. Confidence Assessment

### Where I Am Confident

| Area | Confidence | Notes |
|------|-----------|-------|
| Flake-parts module architecture | High | AGENTS.md explains this clearly; the pattern is consistent throughout the codebase |
| Machine config structure | High | Template machine and AGENTS.md leave little ambiguity |
| Nix language syntax + lib usage | High | `lib.mkMerge`, `lib.mkIf`, `lib.trivial.release` patterns are well-established |
| Shell script conventions | High | `pkgs.writeShellApplication`, POSIX sh, shellcheck pass are clear requirements |
| Tagged code conventions | High | Tag taxonomy is documented and used consistently |
| Documentation authoring | High | README.md, DISCUSSION.md, AGENTS.md give clear style signals |
| Release-independent modules | Medium-High | Pattern is documented; risk of misapplying it without a build test |

### Where I Am Less Confident

| Area | Confidence | Reason |
|------|-----------|--------|
| Secret management (ragenix / SOPS) | Medium | Keys are machine-specific and I cannot test decryption; mistakes here are high-impact |
| VM build verification | Low | I cannot run `nix build` or `nix run` in this environment; any change to VM configs requires human verification |
| Hardware-specific configurations | Low | Kernel params, disko layouts, and hardware quirks require real hardware or a working VM to validate |
| Impermanence integration | Low | The interaction between impermanence, LUKS swap, and vmVariantWithDisko has known unresolved issues (see DISCUSSION.md) |
| Security audit depth | Low | I can flag obvious problems but I am not a substitute for expert cryptographic review or microbenchmarking |

### Honest Risk Assessment

I will most reliably help with:
- Documentation improvements and corrections
- CI/CD workflow additions (new GitHub Actions jobs, mission-control tasks)
- Refactoring well-understood config patterns
- Resolving tagged code items that are self-contained (`FIXME-QA`, `FIXME-DOCS`, `FIXME-UPSTREAM`)
- Reviewing shell scripts for shellcheck compliance and POSIX portability

I SHOULD NOT be trusted to autonomously:
- Make decisions about cryptographic algorithms or key rotation policy
- Commit changes that touch secrets infrastructure without human review
- Mark security-sensitive changes as ready-to-merge without explicit human sign-off
- Accept that a VM build works without an actual build run

---

## 2. Proposals

### P.1 — Add Nix Format Enforcement to CI

**Current state:** `nixpkgs-fmt` is in the devShell but no CI job enforces it.

**Proposed change:** Add a GitHub Actions workflow `nix-fmt-check.yaml` that runs `nixpkgs-fmt --check` on all changed `.nix` files in a pull request.

**Why:** 691 tagged items and growing codebase means formatting drift is likely over time. A CI gate prevents style debates in reviews and keeps agents from introducing tabs-vs-spaces noise.

**Caveat (resolve before implementing):** `nixpkgs-fmt` uses spaces by default; the project uses tabs. Check whether `nixpkgs-fmt` respects `.editorconfig` or whether a different formatter (e.g. `alejandra` or `treefmt` with a tabs-aware config) is needed. This configuration question MUST be resolved before the CI check can be enforced — otherwise it will fail on all existing files.

**Concrete step:**
```yaml
# .github/workflows/nix-fmt-check.yaml
name: Nix Format Check
on:
  pull_request:
    types: [opened, reopened, ready_for_review]
    paths: ['**.nix']
  merge_group:
jobs:
  fmt-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: cachix/install-nix-action@v26
        with:
          install_url: https://nixos.org/nix/install
      - name: Check Nix formatting
        run: |
          BASE="${{ github.event.pull_request.base.sha || 'HEAD~1' }}"
          CHANGED=$(git diff --name-only "$BASE"...HEAD -- '*.nix' | tr '\n' ' ')
          [ -z "$CHANGED" ] || nix develop --command bash -c "nixpkgs-fmt --check $CHANGED"
```

---

### P.2 — Add `nix flake check` to CI

**Current state:** Only shellcheck runs in CI. No structural validation of the flake.

**Proposed change:** Add a CI job that runs `nix flake check --no-build` (syntax + module evaluation without triggering full builds).

**Why:** This catches missing imports, typos in option names, and module evaluation errors before they reach a deployment. It is fast because `--no-build` skips the derivation build phase.

**Concrete step:**
```yaml
# .github/workflows/flake-check.yaml
name: Nix Flake Check
on:
  pull_request:
    types: [opened, reopened, ready_for_review]
    paths: ['**.nix', 'flake.lock']
  merge_group:
jobs:
  flake-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v26
        with:
          install_url: https://nixos.org/nix/install
      - name: Check flake
        run: nix flake check --no-build
```

---

### P.3 — Session Protocol for Agents

**Current state:** AGENTS.md describes architecture well but does not define a structured workflow for starting and closing a session.

**Proposed change:** Add a "Session Protocol" section to AGENTS.md with a checklist agents MUST follow.

**Why:** Agents start every session with no memory of prior sessions. Without a protocol they waste time (and context tokens) rediscovering the same things, or miss context that would prevent mistakes. A checklist makes the cost of skipping steps explicit.

**Proposed checklist (draft):**

```markdown
## Session Protocol

### Before Starting Work (MUST complete)

- [ ] Read the latest DISCUSSION.md
- [ ] Read AGENTS.md (this file)
- [ ] If working on a specific machine: read `src/nixos/machines/<machine>/DISCUSSION.md` if it exists
- [ ] Run `grep -rP "(DNM|REVIEW)((\-.*|)\(.*\)):" . --include="*.nix"` to check for open blockers
- [ ] Review the PR description and any open review comments

### Before Closing Session (MUST complete)

- [ ] Update DISCUSSION.md with any new discoveries, decisions, or open issues
- [ ] Run shellcheck on any changed `.sh` files
- [ ] Run `nix-instantiate --parse` on any changed `.nix` files to catch syntax errors
- [ ] Tag any unresolved issues with the appropriate tag and your identity
- [ ] If you worked on a machine config: note whether the change was build-tested or not in the PR description
```

---

### P.4 — Automate Tagged Code Inventory

**Current state:** There are 691 tagged items in `.nix` and `.sh` files. There is no automated view of them.

**Proposed change:** Add a mission-control task `, tagged-code` that generates a report of all tagged items, grouped by tag type and file, written to stdout or a temp file.

**Why:** 691 items is too many to track mentally. Agents picking "starter issues" need a machine-readable list. A task makes it easy to regenerate the list on demand without remembering the grep pattern. NOTE: the grep pattern below is the canonical one; if it ever changes, update both this task and AGENTS.md to stay in sync.

**Concrete step (Nix snippet):**
```nix
"tagged-code" = {
  description = "List all tagged code items (FIXME, TODO, DOCS, etc.)";
  category = "Checks";
  exec = pkgs.writeShellApplication {
    name = "tasks-tagged-code";
    runtimeInputs = [ pkgs.gnugrep pkgs.coreutils ];
    text = ''
      grep -rn --include="*.nix" --include="*.sh" \
        -P "(FIXME|TODO|DOCS|HACK|REVIEW|DNM|DNC|DNR)((\-.*|)\(.*\)):" \
        . | sort -t: -k1,1 -k2,2n
    '';
  };
};
```

---

### P.5 — Consistent Per-Machine DISCUSSION.md

**Current state:** Only `tupac` has a machine-specific `DISCUSSION.md`. Other machines (hana, sinnenfreude, ignucius, lengo, mracek, twinkcentral) do not.

**Proposed change:** Add a minimal `DISCUSSION.md` template to `src/nixos/machines/template/` and add a note to AGENTS.md that agents SHOULD create `DISCUSSION.md` for any machine they work on if one does not exist.

**Why:** Machine-specific context (hardware quirks, known issues, what was tried and failed) is exactly the kind of information that prevents agents from repeating mistakes. The tupac DISCUSSION.md saved significant time in the VM testing session. The pattern SHOULD be replicated.

---

### P.6 — Explicit Build-Tested vs. Not-Tested Flag in PRs

**Current state:** There is no standard way to communicate whether a Nix config change was validated by an actual build. Agents frequently cannot run builds (this environment has no Nix evaluator).

**Proposed change:** Define a standard PR tag or checklist item:

```
- [ ] Config changes build-tested with `nix build .#nixosConfigurations.<machine>-stable.config.system.build.vm --no-link`
- [ ] Config changes NOT build-tested (human reviewer MUST run before merging)
```

**Why:** This makes the risk of untested changes explicit and puts the verification responsibility where it belongs (human reviewer), rather than leaving it implicit. It also helps future agents understand which parts of the history are verified.

---

### P.7 — Dependency Change Review Workflow

**Current state:** `flake.lock` updates happen via `nix flake update`. There is no structured review process for what changed.

**Proposed change:** Add a mission-control task `, dep-diff` that shows a human-readable diff of `flake.lock` changes: which inputs changed, from which commit to which, with links to the upstream changelogs.

**Why:** The XZ backdoor defense strategy explicitly requires verifying ALL dependency changes. Right now a `flake.lock` update is a black-box commit. A readable diff makes it possible to review what changed and apply the "all blobs are malware until proven otherwise" principle to updates.

**Concrete step:**
```nix
"dep-diff" = {
  description = "Show human-readable diff of flake.lock changes since last commit";
  category = "Checks";
  exec = pkgs.writeShellApplication {
    name = "tasks-dep-diff";
    runtimeInputs = [ pkgs.git pkgs.nix pkgs.jq ];
    text = ''
      git diff HEAD flake.lock | \
        grep -E '^[+-].*"(url|rev)"' | \
        sed 's/^+/  NEW: /' | \
        sed 's/^-/  OLD: /'
    '';
  };
};
```

---

### P.8 — Agent Identity in Commit Messages

**Current state:** Agents commit with a generic identity. It is not clear from `git log` which commits were made by a human vs. an agent vs. which specific agent type.

**Proposed change:** Adopt a convention for agent commit messages:

```
feat(machine/tupac): add split-lock kernel param [agent: copilot]
```

Or use a Git trailer:
```
Agent: github-copilot
Verified-Build: no
```

**Why:** Provenance tracking is important in a security-sensitive project. Knowing which commits came from an agent (and which agent) helps humans apply the appropriate level of scrutiny during review. It also helps post-hoc audits.

---

### P.9 — Clarify the `migration.TODO` Scope

**Current state:** `migration.TODO` lists four items for "migrating to new management" but gives no timeline, ownership, or blocking conditions.

**Proposed change:** Convert `migration.TODO` to a proper `docs/migration-plan.md` with:
- Current state for each item
- Blocking conditions (what must be true before this can start)
- Acceptance criteria (how do we know it is done)
- Owner (human or "open")

**Why:** Agents will keep encountering these migration items and either ignore them (wasteful) or attempt them prematurely (risky). Clear ownership and blocking conditions tell an agent exactly what is and is not in scope.

---

## 3. What I Would NOT Change

The following are things that work well and SHOULD NOT be changed without a compelling reason:

- **flake-parts architecture** — the per-machine modularity scales well and AGENTS.md explains it clearly.
- **Tagged code system** — the taxonomy is good. Adding more tags would increase confusion.
- **POSIX shell preference** — reduces attack surface, good choice for this threat model.
- **`pkgs.writeShellApplication` for scripts** — avoids rebuilds, passes shellcheck, correct approach.
- **Release-independent modules via attrset** — the approach is non-obvious but correct (avoids evaluating non-matching release bodies).
- **DISCUSSION.md as a living log** — this is the most valuable document for agent continuity. Keep it updated.

---

## 4. Open Questions for Brainstorm

1. **Formatter choice:** Should the project adopt `alejandra` (opinionated, tabs-aware) instead of `nixpkgs-fmt`? Or configure `treefmt`? The current style uses tabs but `nixpkgs-fmt` prefers spaces.

2. **Agent autonomy boundaries:** What classes of changes can an agent commit and push without human review? Suggestion: documentation and `FIXME-QA` items only; anything touching secrets, kernel params, or disko requires human sign-off.

3. **Build verification in CI:** Is there a Cachix cache or NixOS build farm available that would make per-machine `nix build` checks feasible in GitHub Actions? Without a cache, building NixOS configurations in CI is very slow.

4. **SOPS vs. ragenix long-term:** Both are used in the flake. Is the intent to standardize on one? This affects how agents should handle secrets in new configs.

5. **Impermanence + vmVariantWithDisko blocker (from DISCUSSION.md):** Has anyone investigated using `nixos-generators` or a `perSystem` output for a dedicated pulse-check VM instead of specialisations? This is likely the path of least resistance given the specialisation limitation.

---

*Review this document in the context of DISCUSSION.md and AGENTS.md. Proposals here are intended as conversation starters.*
