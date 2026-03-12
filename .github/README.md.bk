# CI/CD Configuration

This directory contains CI/CD workflows designed to be forge-independent while leveraging GitHub Actions when available.

## Philosophy

- CI/CD should run on events (pushes, PRs) rather than schedules
- Event-driven is more efficient than scheduled runs when code isn't changing
- Critical functionality available via mission-control tasks for on-demand execution
- Security verification should use AI agents, not just static checks

## Available Workflows

### flake-check.yaml

Validates Nix flake:
- `nix flake check` - Validates flake outputs
- `nix flake show` - Displays flake structure
- Dry-run build test

Runs on: push, pull_request (ready_for_review), merge_group

### shellcheck.yaml

Lints shell scripts:
- Uses project `.shellcheckrc` configuration
- Checks POSIX sh compliance
- All warnings treated as errors

Runs on: push, pull_request (when .sh files change)

### format-check.yaml

Validates code formatting:
- Nix files formatted with `nixpkgs-fmt`
- Checks for tabs (not spaces) in Nix files

Runs on: push, pull_request (when .nix files change)

### security.yaml

Security-focused checks:
- Verify flake inputs
- Check for sensitive data exposure patterns
- Verify age-encrypted secrets
- Build test (dry-run)
- Agent dependency review prompt

Runs on: push, pull_request (ready_for_review), merge_group

## Mission-Control Tasks

Critical CI/CD also available as mission-control tasks:

```sh
nix develop ,
, verify    # Verify system configuration (safe)
, build     # Build system configuration
```

These can be run on-demand without relying on forge CI.

## Forge Independence

To migrate to another forge (e.g., Gitea):
1. Export workflows as compatible format
2. Keep validation logic in mission-control tasks
3. Use forge-specific features only for notifications/metadata

## Security Verification

**Important**: Static checks are not sufficient. All new dependencies must be:
- Reviewed by AI agent
- Checked for source legitimacy
- Verified for maintainer reputation
- Looked up for security advisories

**Rule**: All blobs are malware until proven otherwise.
