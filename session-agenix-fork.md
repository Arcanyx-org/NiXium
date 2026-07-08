# Session: Fork agenix for NiXium

## Mission

Fork the vendored agenix (`vendor/agenix`, `Arcanyx-org/agenix`) to add:
1. **`age.secrets.<name>.script` option** — generate-or-fallback for secrets
2. **NTRU Prime via rage** — replace default encryption
3. **Service-based deployment** — avoid storing unencrypted secrets in nix store

## Current State

- `vendor/agenix/` — vendored agenix submodule from `git@github.com:Arcanyx-org/agenix.git`
- `vendor/ragenix/` — vendored ragenix submodule from `git@github.com:Arcanyx-org/ragenix.git`, which uses NiXium's agenix fork as flake input
- `flake.nix` still references upstream `github:yaxitech/ragenix` directly (line 111-112)
- `age.secrets.*` usage in `src/nixos/machines/sinnenfreude/` (search for `.age` files)

## Design Requirements

### 1. `age.secrets.<name>.script` option

```nix
age.secrets.sinnenfreude-onion-openssh-private = {
  file = ../secrets/sinnenfreude-onion-openssh-private.age;   # optional — if omitted, always runs script
  owner = "tor";
  group = "tor";
  path = "/var/lib/tor/onion/openssh/hs_ed25519_secret_key";
  symlink = false;
  mode = "600";                                                 # needs to be added
  script = pkgs.writeShellApplication {                        # NEW — generate if file absent or decrypt fails
    name = "gen-onion-key";
    runtimeInputs = [ pkgs.age pkgs.tor ];
    text = ''
      # Generate the secret
      # Encrypt with age using NTRU Prime
      # Output to the expected path
    '';
  };
};
```

**Behavior:**
- If `file` is omitted → always run `script` to generate + encrypt
- If `file` is provided but decryption fails (no matching identity) → run `script`
- The script receives `$out` (target path) and must produce the decrypted secret at `$out`
- Script should use NTRU Prime via rage for encryption

**Implementation approach:**
- Modify agenix's NixOS module to add `script` option in the secret submodule
- Modify agenix's activation script to:
  1. If `file` is set: try `age --decrypt` (current behavior)
  2. If decrypt fails AND `script` is set: run the script as fallback
  3. If `file` is not set AND `script` is set: always run the script
  4. If neither works: fail (current behavior)

### 2. NTRU Prime via rage

- agenix uses `age` CLI by default (or `rage` as alternative)
- rage has NTRU Prime support: `rage -r "age1ntru..."` or use the `NTRU-Prime` recipient type
- Either fork to default to NTRU Prime, or make it configurable
- `rage` is already packaged in nixpkgs

### 3. Service-based deployment (Replace Secrets at Runtime)

**Problem:** Current agenix decrypts secrets into `/run/secrets` during activation. The encrypted `.age` files must be referenced in the nix store, and if you're not careful, intermediate files leak.

**Goal:** Instead of storing secrets in the nix store at all, deploy them via a systemd service that:
- Runs after network target (or at a specific point in boot)
- Fetches/generates the secret
- Places it at the expected path with correct permissions
- Creates the expected symlinks

**Approach options:**
- Add `age.secrets.<name>.serviceOnly = true` flag — skips activation decrypt, creates a systemd service instead
- Or: modify agenix to always use a service for secrets with `script` set
- The service would:
  1. Try to decrypt `file` with available identities
  2. Fail over to `script` if decrypt fails
  3. Place result at `path` with `owner:group:mode`
  4. Handle symlink if requested

## Architecture Reference

```
vendor/agenix/              ← WORK HERE (fork)
├── modules/
│   ├── age.nix             ← NixOS module (add script option here)
│   ├── home-manager.nix    ← HM module
│   └── lib/
│       └── age-lib.nix     ← Common functions
├── pkgs/
│   ├── age/                ← age/rage package overlay
│   └── age-*/
├── flake.nix
├── pkgs.nix
└── ...
```

Key files in the agenix module:
- `modules/age.nix` — defines `age.secrets` option submodule, activation script
- The activation script is generated via `ageGenerateActivationScript` or similar
- Look for where `age --decrypt` is called and where the `$out` variable is set

### How ragenix wraps agenix

ragenix re-exports agenix's module verbatim:
```nix
# vendor/ragenix/flake.nix
ragenix.nixosModules.default = agenix.nixosModules.default;
```

So any changes to agenix's module automatically flow through ragenix.

## Integration Steps

1. **Hack on vendor/agenix** — add `script` option, modify activation script
2. **Update flake.nix** — switch from `github:yaxitech/ragenix` to vendored agenix + ragenix
3. **Test** — build `nixos-sinnenfreude-stable-vm-reduced` and verify:
   - `age.secrets.<name>.script` works as fallback
   - NTRU Prime encryption works
   - Secrets end up at correct paths with correct permissions
   - No secrets leak into nix store

## Key Files to Understand

| File | Purpose |
|------|---------|
| `vendor/agenix/modules/age.nix` | NixOS module — option definitions + activation script |
| `vendor/ragenix/flake.nix` | Wrapper that re-exports agenix |
| `flake.nix` | Top-level flake — currently references upstream ragenix |
| `src/nixos/machines/sinnenfreude/releases/stable/default.nix` | Where `age.secrets.*` are defined |
| `src/nixos/machines/sinnenfreude/secrets/*.age` | Encrypted secret files |

## Constraints

- Must work with NixOS 26.05 (`a037402`)
- Must work in VM (no age identity available — this is the whole reason for the script fallback)
- All existing secrets must continue to work (backward compatible)
- Don't use `fallback` sub-object or type-tagged enums — keep it as a flat `script` attribute

## Previous Context

- Sinnenfreude VM boots with 0 degraded services is the goal
- sshd fixed: `before = [ "sshd.service" ]` + `.pub` store symlink removal
- Impermanence fixed: tmpfiles rules create persistence source paths before mount units
- vconsole hang fixed: `TimeoutStartSec = "5s"`
- The only remaining failures are HM services failing because age secrets decryption fails (no keys in VM)
