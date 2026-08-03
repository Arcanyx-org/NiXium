<!-- SUMMARY: mkVM — single-function interface for building NixOS test VMs. LOAD WHEN: Creating a new VM module or understanding how to use mkVM. SKIP WHEN: Not working on VM modules. -->

# mkVM — NixOS Test VM Builder

## What is mkVM?

mkVM is a single-function library for building NixOS test VMs with Wayland/Xorg/CLI display, exit-code propagation, GPU passthrough, 3-mode disk strategy, and per-module persistent storage. It reduces ~140 lines of boilerplate per VM to ~15 lines.

## Return Value

mkVM returns a record with two building blocks — the call site decides what to expose:

```nix
{
  vm     = <derivation>;  # Raw NixOS VM image (vmSystem.config.system.build.vm)
  runner = <derivation>;  # Custom runner with disk strategy, GPU, timeout, exit codes
}
```

- **vm** — the raw NixOS VM derivation. Pass to QEMU directly, hand to upstream developers for reproduction, or build with `nix build`.
- **runner** — the opinionated wrapper. Handles 3-mode disk strategy, GPU passthrough, timeout, exit code propagation. Use for `nix run` apps and CI checks.

## Usage (within NiXium)

```nix
{ lib, self, inputs, ... }:

let
	inherit (self.lib) mkVM;
in mkMerge [
	{
		flake.homeManagerModules.my-app = ./my-app.nix;
	}

	{
		perSystem = { system, pkgs, ... }:
			let vm = mkVM {
				inherit pkgs system;
				name = "my-app-test-vm";
				command = "my-app";
				modulePath = "$FLAKE_ROOT/src/nixos/.../my-app";
				graphical = "wayland";
				homeManagerModules = [ self.homeManagerModules.my-app ];
				homeManagerConfig = { programs.my-app.enable = true; };
			}; in {
				packages."nixos-my-app-test-vm" = vm.vm;
				apps."nixos-my-app-test-vm" = {
					type = "app";
					program = "${vm.runner}/bin/nixos-my-app-test-vm";
				};
			};
	}
]
```

## Usage (from external flakes)

```nix
{
	inputs.nixium.url = "github:Arcanyx-org/NiXium";

	outputs = { nixium, nixpkgs, ... }:
		let
			inherit (nixium.lib) mkVM;
			pkgs = import nixpkgs { system = "x86_64-linux"; };
			vm = mkVM {
				inherit pkgs;
				system = "x86_64-linux";
				name = "my-external-vm";
				command = "vim";
				modulePath = "$FLAKE_ROOT/my-vm";
				graphical = null;
			};
		in {
			packages.x86_64-linux."nixos-my-external-vm" = vm.vm;
			apps.x86_64-linux."nixos-my-external-vm" = {
				type = "app";
				program = "${vm.runner}/bin/nixos-my-external-vm";
			};
		};
}
```

## Composing Outputs

The call site chooses what to expose — no forced outputs, no bloat:

```nix
# Package only — hand VM image to upstream for reproduction
let vm = mkVM { ... }; in {
	packages."nixos-quest3-debug-vm" = vm.vm;
}

# App only — interactive development
let vm = mkVM { name = "quest3-dev-vm"; exitMode = "shell"; timeout = null; ... }; in {
	apps."nixos-quest3-dev-vm" = {
		type = "app";
		program = "${vm.runner}/bin/nixos-quest3-dev-vm";
	};
}

# Check only — automated CI test
let vm = mkVM { name = "editors-vim-test-vm"; exitMode = "propagate"; timeout = 60; ... }; in {
	checks."editors-vim-kreyren" = pkgs.runCommand "check-editors-vim-kreyren" {} ''
		timeout 60 ${vm.runner}/bin/nixos-editors-vim-test-vm
		touch $out
	'';
}

# All three from one mkVM call
let vm = mkVM { ... }; in {
	packages."nixos-my-app-vm" = vm.vm;
	apps."nixos-my-app-vm" = {
		type = "app";
		program = "${vm.runner}/bin/nixos-my-app-vm";
	};
}
```

## nix repl

```nix
:lf .
vm = lib.mkVM { pkgs = null; system = "x86_64-linux"; name = "repl-test-vm"; command = "echo hello"; modulePath = "$FLAKE_ROOT/test"; graphical = null; exitMode = "propagate"; timeout = 60; }
vm.vm       # «derivation ...-nixos-vm.drv»
vm.runner    # «derivation ...-nixos-repl-test-vm.drv»
:b vm.vm    # build the VM image
:b vm.runner # build the runner
```

## Key Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `pkgs` | No | `null` (vanilla nixpkgs) | Package set for the guest system |
| `system` | Yes | — | Host system architecture |
| `name` | Yes | — | VM name (runner binary name, disk image filename). Convention: `<module-key>-vm` for NixOS modules, `home-<module-key>-vm` for home-manager modules — producing `nixos-<name>` runners |
| `command` | Yes | — | Command to run in the VM |
| `modulePath` | Yes | — | Path for dev-mode disk storage |
| `graphical` | No | `null` | `null`/`"machine"`/`"wayland"`/`"xorg"` |
| `exitMode` | No | `"propagate"` | `"propagate"`/`"poweroff"`/`"shell"` |
| `timeout` | No | `300` | Seconds before VM kill (null to disable) |
| `gpuPassthrough` | No | `null` | `null`/`"auto"`/PCI address |
| `networking` | No | `false` | Enable DHCP ethernet (eth0) in the guest |

## pkgs Override Examples

```nix
# Default: vanilla nixpkgs (no unfree)
mkVM { pkgs = null; ... }

# Unfree packages
mkVM {
	pkgs = import inputs.nixpkgs {
		system = "x86_64-linux";
		config.allowUnfree = true;
	};
	...
}

# Different nixpkgs version
mkVM {
	pkgs = import inputs.nixpkgs-unstable {
		system = "x86_64-linux";
	};
	...
}
```

## Display Modes

- **`null`** — CLI only. Autologin on tty1, run command, then exit/shell.
- **`"wayland"`** — Wayland kiosk. greetd → cage → foot → command.
- **`"xorg"`** — X11 kiosk. xinit → xterm -e command.

## Networking

Set `networking = true` to give the guest outbound internet. The qemu-vm NIC
(eth0, SLiRP user-mode NAT) is always present; this flag enables DHCP so the
guest gets `10.0.2.15` (gateway `10.0.2.2`, DNS `10.0.2.3`). The guest behaves
like a regular NixOS system — the firewall stays enabled and ports are opened
the standard way:

```nix
mkVM {
	networking = true;
	systemConfig = {
		networking.firewall.allowedTCPPorts = [ 8080 ];
	};
	...
}
```

No firewall or port-forwarding behavior is imposed by mkVM.

## Disk Strategy (3 modes)

1. **Dev mode** (`$FLAKE_ROOT` is valid): Persistent disk next to module
2. **User override** (`$NIX_DISK_IMAGE` set): User-chosen path
3. **Ephemeral** (neither): `${TMPDIR:-/var/tmp}` with QEMU `-snapshot`

## Exit Code Propagation

When `exitMode = "propagate"` (default), the VM forwards the command's exit code to the host via isa-debug-exit:

```bash
nix run .#nixos-my-app-vm
echo $?  # Returns the command's exit code
```

## Files

- `default.nix` — The mkVM library (this is the only file you need to understand)
- `runner.sh` — Standalone POSIX sh runner script (included via `builtins.readFile`)