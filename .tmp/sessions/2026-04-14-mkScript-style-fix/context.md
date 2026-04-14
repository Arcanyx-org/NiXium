# Task Context: mkScript style fix

Session ID: 2026-04-14-mkScript-style-fix
Created: 2026-04-14T08:40:00Z
Status: in_progress

## Current Request
User approved: fix remaining project-style violations in src/nixos/lib/mkScript/default.nix

## Context Files (Standards to Follow)
- .opencode/context/core/standards/code-quality.md
- docs/nx/standard.md
- .opencode/context/core/standards/nix.md
- .shellcheckrc
- .editorconfig

## Reference Files (Source Material)
- src/nixos/lib/mkScript/default.nix (WIP, edited)
- src/nixos/lib/mkVM/default.nix (migration consumer)
- src/nixos/lib/mkVM/runner.sh (validation target)
- flake.nix
- .opencode/quests/write-shell-app-ksh-shfmt/quest.md

## External Docs Fetched
None

## Components
- Style fix: convert Nix implementation to tabs, preserve ###! spec
- Validation: nix-instantiate --parse on the file
- Next validation: targeted mkScript build against runner.sh

## Changes performed so far
- Converted implementation portion of src/nixos/lib/mkScript/default.nix to use tabs for indentation
- Preserved the top `###!` spec block unchanged
- Verified nix-instantiate --parse succeeds for the updated file

## Constraints
- MUST follow docs/nx/standard.md (tabs for Nix indentation)
- MUST preserve the `###!` spec header verbatim
- MUST not auto-fix shellcheck issues in source files without explicit approval

## Exit Criteria
- [ ] Session directory created and context persisted
- [ ] Nix parse succeeded for updated file
- [ ] Targeted mkScript derivation build executed against src/nixos/lib/mkVM/runner.sh and results reported
