<!-- SUMMARY: How to use mkVM from nix repl for ad-hoc VM testing without code changes. LOAD WHEN: Testing NixOS configurations interactively, debugging VM issues, or exploring mkVM parameters. SKIP WHEN: Not doing interactive VM testing. -->

# Quest: nix repl VM Testing with mkVM

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Priority** | High |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Why This Exists

mkVM returns `{ vm; runner; }` — two independent building blocks. This design enables ad-hoc VM testing from `nix repl` without modifying any files. AI agents can iterate on configurations, test integrations, and validate changes entirely from the repl.

## Quick Reference

### Start a repl session

```bash
cd /path/to/NiXium
nix repl
:lf .
```

### Build a VM from repl

```nix
# Define a VM with custom config
vm = lib.mkVM {
  pkgs = null;  # vanilla nixpkgs, or pass your own
  system = "x86_64-linux";
  name = "my-test";
  command = "vim";
  modulePath = "$FLAKE_ROOT/src/nixos/.../my-module";
  graphical = "wayland";
  homeManagerConfig = { programs.vim.enable = true; };
}

# Inspect the return value
vm        # { runner = <derivation>; vm = <derivation>; }
vm.vm     # the raw NixOS VM image derivation
vm.runner  # the custom runner script derivation
```

### Build and run from command line

```bash
# Build the VM image (for upstream developers, reproduction, etc.)
nix build --impure --expr 'let flake = builtins.getFlake (toString ./.); inherit (flake) lib; mkVM = lib.mkVM; pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; }; in (mkVM { inherit pkgs; system = "x86_64-linux"; name = "my-test"; command = "vim"; modulePath = "$FLAKE_ROOT/src/nixos/.../my-module"; graphical = "wayland"; homeManagerConfig = { programs.vim.enable = true; }; }).vm' --no-link --print-out-paths

# Build the runner (for nix run, checks, etc.)
nix build --impure --expr '...same but .runner at the end' --no-link --print-out-paths

# Run the VM
nix run --impure --expr '...same but .runner at the end'
```

### Run with custom config (no code changes)

```bash
# Example: vim with red background
nix run --impure --expr 'let flake = builtins.getFlake (toString ./.); inherit (flake) lib; mkVM = lib.mkVM; pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; }; in (mkVM { inherit pkgs; system = "x86_64-linux"; name = "vim-red-bg-test"; command = "vim"; modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/editors/vim"; graphical = "wayland"; exitMode = "shell"; timeout = null; homeManagerConfig = { programs.vim.enable = true; programs.vim.extraConfig = "hi Normal ctermbg=red guibg=red"; }; }).runner'
```

## Agent Workflow

### 1. Identify what to test

```
"I need to verify that vim's checkhealth passes"
→ command = "vim -c checkhealth -c qa!";
→ exitMode = "propagate";
→ graphical = null;  # CLI mode, no display needed
→ timeout = 60;
```

### 2. Build and run from repl

```nix
:lf .
vm = lib.mkVM {
  pkgs = null;
  system = "x86_64-linux";
  name = "vim-checkhealth-test";
  command = "vim -c checkhealth -c qa!";
  modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/editors/vim";
  graphical = null;
  exitMode = "propagate";
  timeout = 60;
  homeManagerModules = [ self.homeManagerModules.editors-vim-kreyren ];
  homeManagerConfig = { programs.vim.enable = true; };
}
:b vm.runner
```

### 3. Run and check exit code

```bash
/nix/store/.../nixos-vm-vim-checkhealth-test/bin/nixos-vm-vim-checkhealth-test
echo $?  # 0 = success, non-zero = failure
```

### 4. Iterate — change parameters, rebuild, retest

No code changes needed. Just change the mkVM parameters in the repl.

## Key Parameters for Testing

| Parameter | CLI Testing | Interactive Dev |
|-----------|-------------|------------------|
| `graphical` | `null` (CLI) | `"wayland"` or `"xorg"` |
| `exitMode` | `"propagate"` | `"shell"` |
| `timeout` | `60` (fast CI) | `null` (no kill) |
| `command` | `"vim -c checkhealth -c qa!"` | `"vim"` |

## Common Patterns

### Test a home-manager module

```nix
vm = lib.mkVM {
  pkgs = null;
  system = "x86_64-linux";
  name = "test-my-module";
  command = "my-app --test";
  modulePath = "$FLAKE_ROOT/test";
  graphical = null;
  exitMode = "propagate";
  timeout = 120;
  homeManagerModules = [ self.homeManagerModules.my-module ];
  homeManagerConfig = { programs.my-app.enable = true; };
}
```

### Test with unfree packages

```nix
vm = lib.mkVM {
  pkgs = import inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
  system = "x86_64-linux";
  name = "unfree-test";
  command = "steam";
  modulePath = "$FLAKE_ROOT/test";
  graphical = "wayland";
  exitMode = "shell";
  timeout = null;
}
```

### Test system-level config (networking, services)

```nix
vm = lib.mkVM {
  pkgs = null;
  system = "x86_64-linux";
  name = "nginx-test";
  command = "curl http://localhost && exit 0 || exit 1";
  modulePath = "$FLAKE_ROOT/test";
  graphical = null;
  exitMode = "propagate";
  timeout = 60;
  systemConfig = {
    services.nginx.enable = true;
    services.nginx.virtualHosts.localhost.locations."/" = { root = "/var/www"; };
    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
```

### Cross-architecture testing

```nix
vm = lib.mkVM {
  pkgs = null;
  system = "x86_64-linux";
  guestSystem = "aarch64-linux";
  name = "aarch64-test";
  command = "uname -m";
  modulePath = "$FLAKE_ROOT/test";
  graphical = null;
  exitMode = "propagate";
  timeout = 300;  # cross-arch is slow
}
```

## Important Notes

- `modulePath` must start with `$FLAKE_ROOT/` — the runner strips this prefix and reconstructs the path at runtime
- Short module paths like `$FLAKE_ROOT/test` may trigger a shellcheck false-positive (SC2209) in the runner. Use real paths for production.
- `pkgs = null` creates a vanilla nixpkgs import. Pass your own `pkgs` for unfree, overlays, or different nixpkgs versions.
- `exitMode = "shell"` drops to an interactive shell after the command exits — useful for debugging.
- `timeout = null` disables the timeout — the VM runs until you close it or kill the process.
- The `--impure` flag is required when using `builtins.getFlake` in nix build/run expressions because the flake reference is unlocked.

## Related Quests

- [disk-strategy-portability](../disk-strategy-portability/quest.md) — Disk strategy portability
- [env-vars-over-command-construction](../env-vars-over-command-construction/quest.md) — Environment variables over command construction