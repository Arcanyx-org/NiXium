# NiXium (N/X)

Transparent Nix-based Open-Source Infrastructure as Code (OSS IaaC) for mission-critical tasks in paranoid, high-security environments. All configurations are declarative and version-controlled.

> **This is the experimental branch** - experiments conducted here prior to submission to central branch.

- [disko](https://github.com/nix-community/disko) — Declarative Filesystem Management
- [impermanence](https://github.com/nix-community/impermanence) — Enforce Declarative Setup
- [flake-parts](https://github.com/hercules-ci/flake-parts) — Nix Flake Management
- [home-manager](https://github.com/nix-community/home-manager) — User Configuration
- [ragenix](https://github.com/yaxitech/ragenix) — Secrets Management
- [mission-control](https://github.com/Platonic-Systems/mission-control) — Task Runner
- [lanzaboote](https://github.com/nix-community/lanzaboote) — Declarative Secure Boot
- [nixos-generators](https://github.com/nix-community/nixos-generators) — Filesystem Images
- [Release-independent Modules](#release-independent-modules) — Cross-release compatibility

## Directory Structure

Run `, tree` to generate this structure:

├── **config** -- Project Configuration<br/>
├── **lib** -- Project-Oriented Libraries<br/>
├── **src** -- Source Code Files<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **nixos** -- Source Files Relevant to the NixOS Distribution<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **images** -- Custom tools to manage the NixOS Distribution<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **machines** -- Machine Management in the NixOS Distribution<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **template** -- Example of Machine Management<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **config** -- Invidual System configuration<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **lib** -- Libraries Exported by the Machine to Others<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **releases** -- Management across releases for the invidual machine<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **secrets** -- Machine-invidual secrets<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **services** -- Machine managed services<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **modules** -- NixOS-related Modules<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **programs** -- NixOS-related Programs Adjustments<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **security** -- NixOS-related Security Management<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **services** -- NixOS-related Service Adjustments<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **system** -- NixOS-related System Management<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **impermenance** -- NixOS-related management of impermanence<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **overlays** -- Overlay Management<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **packages** -- Changes to individual packages repository-wide<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **users** -- Management of Users in NixOS Distribution<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **modules** -- Home-Manager specific modules applied to all users<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **users** -- Invidual User Management<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **kreyren** -- Management of Kreyren User<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **home** -- User Kreyren's Home Management<br/>
├── **tasks** -- Routines to work with the project<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **shellcheck** -- Run shellcheck on all shell scripts in the repository<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **docs** -- Tasks related to the project documentation<br/>
&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├── **tree** -- Task used to generate this file hierarchy output<br/>
├── **vendor** -- 3rd party repos used in this projects<br/>

---

## Services (Provided to Community)

All services via Tor onion routing. Configure [MapAddress](https://manpages.org/tor) for memorable URLs (e.g., `monero.nx`).

### Monero Node

```
Hostname: jj6qehtyrfvvi4gtwttpg2qyaukqzxwaoxvak534nidlnnelmqtlm3qd.onion
Port: 18081
Username: Monerochan
Password: iL0VEMoNeRoChan<3
```

> **Security:** Transactions may be deanonymized if using insecure OS, misconfigured Tor, shared nodes (lose Dandelion++), identifiable fee rates, or KYC exchanges. Post-quantum risk exists until FCMP++/Carrot is implemented.

<details>
<summary><strong>Security Details (click to expand)</strong></summary>

**Deanonymization Risks:**
- Insecure OS with proprietary components
- Not using Tor or misconfigured
- Not running your own node (lose Dandelion++ benefits)
- Changing default fee rate in identifiable ways
- Using KYC exchanges

**Post-Quantum Threat:** Transactions likely harvested for "Harvest Now, Decrypt Later". Monero vulnerable until FCMP++/Carrot is implemented.

References:
- [Monerochain presentation](http://dreadytofatroptsdj6io7l3xptbet6onoyno2yv7jicoxknyazubrad.onion/monero-chain.mp4)
- [Detailed analysis](http://dreadytofatroptsdj6io7l3xptbet6onoyno2yv7jicoxknyazubrad.onion/post/6de54b143e669e368af6)
</details>

### Vikunja (Internal Todo)

```
Hostname: u65cyt3tdc66u7ciin55atl5sattytx3rjzzrzhlfdfc2t7pqbhyd6qd.onion
Port: 80
```

Access upon request. Consider [Vikunja Cloud](https://vikunja.cloud) to support upstream.

---

## Contributing

### Getting Started

This is a hardened codebase with strict checks. Start with small contributions fixing "tagged code" to learn the process.

**Never submit new features without issue tracking and assignment.**

```sh
# Install direnv for automatic environment loading
# Then:
cd /path/to/NiXium
, <task-name>    # direnv auto-loads (recommended)

# Examples:
, verify    # Verify system configuration
, codium    # Open in VSCodium
, tree      # Show directory structure
```

Without direnv: `nix develop` then `, <task-name>`

### RFC 2119 Keywords

This repository uses [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119) keywords: MUST, SHOULD, MAY. See [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119) for definitions.

### Tagged Code

```nix
# FIXME-QA(Krey): Make it possible to accept list of strings
# FIXME-UPSTREAM(Krey): These options should be added to NixOS Module
services.monero.extraConfig = toString [
  "prune-blockchain=1"
  "proxy=127.0.0.1:9050"
];
```

| Tag | Meaning |
|-----|---------|
| `FIXME:` | General fixme |
| `FIXME-QA:` | Quality assurance |
| `FIXME-SECURITY:` | Security issue |
| `FIXME-UPSTREAM:` | Fix upstream |
| `TODO:` | Task for author |
| `DOCS:` | Documentation needed |
| `HACK:` | Workaround |
| `REVIEW:` | Needs review |
| `DNM:` | Do Not Merge (blocks merge) |
| `DNC:` | Do Not Contribute |
| `DNR:` | Do Not Release |
| `NOTE:` | Important note |
| `PURITY:` | Impure operation |

Search for starter issues:
```sh
grep -rP "(FIXME|TODO|DOCS|HACK|REVIEW|DNM|DNC|DNR)((\-.*|)\(.*\)):" .
```

**Leave some trivial tagged items for humans as starter issues.**

---

## Implementation Notes

### Nix Language

We write Nix differently from upstream due to security concerns (see [nixpkgs#133088](https://github.com/NixOS/nixpkgs/issues/133088) and related issues).

**Indentation:** Tabs, not spaces.

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

Use `let inherit (builtins) readFile; in` at top level.

### Shell Scripts

We prefer POSIX-compliant scripts (ksh93 preferred) over bash for portability and reduced attack surface.

**Requirements:**
- Include `# shellcheck shell=sh # POSIX` at first line for complex scripts
- Use `pkgs.writeShellApplication` — avoids package rebuilds when changing scripts
- All shellcheck warnings are errors
- Mark impure operations with `# PURITY`

**Why POSIX/ksh:**
- Works on any Unix-like system
- Easier to reason about security
- No bash-specific features needed for our use cases

### Release-Independent Modules

Support multiple NixOS releases using attrsets as case/switch. This is different from `mkIf` or `if` — it **does NOT evaluate** the body for non-matching releases (prevents build failures).

```nix
let
	inherit (lib) elem optionalString mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" ]) release}" = { /* ... */ };
		"25.11" = { /* ... */ };
	}."${release}"
]
```

<details>
<summary><strong>Edge Case: Feature-Gate Changes Between Releases</strong></summary>

When an option used for feature-gating changes between releases, maintain backwards compatibility:

```nix
let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		# Old option name
		"23.11" = mkIf nixosConfig.services.xserver.desktopManager.gnome.enable {
			home.packages = [ pkgs.gnome.dconf-editor ];
		};

		# New option name (25.11+)
		"25.11" = mkIf nixosConfig.services.desktopManager.gnome.enable {
			home.packages = [ pkgs.dconf-editor ];
		};
	}."${release}"
]
```

Full example: https://github.com/Arcanyx-org/NiXium/blob/experimental/src/nixos/machines/sinnenfreude/config/power-management.nix
</details>

---

## Security Philosophy

### Zero-Trust

**All blobs are malware until proven otherwise.**

XZ Backdoor (CVE-2024-3094):
- Discovered in March 2024 in xz-utils 5.6.0/5.6.1
- New maintainer "Jia Tan" joined 2 years prior
- Inserted via testing blob during build time ("goldilocks phase")
- Discovered via microbenchmarking by German developer

<details>
<summary><strong>Defense Strategy</strong></summary>

- Verify ALL dependencies (and their dependencies)
- Recreate critical blobs ourselves
- Use DNM tag for security issues
- Static checks only as additional info
- **Microbenchmarking required** for significant changes
</details>

### Post-Quantum

- Assume quantum computers may exist in secret
- Harvest Now, Decrypt Later attacks are active
- Rotate secrets on irregular basis

---

## Claim of "NX" Custom TLD

We claim "NX" as cTLD. We don't recognize ICANN's authority due to monopolistic position and unreasonable fees.

---

## Krey Nix Tips

### Update your NixOS and other inputs

To update NixOS (and other inputs) run `nix flake update`

You may also update a subset of inputs, e.g.

```console
$ nix flake lock --update-input nixpkgs --update-input home-manager
```

Credit: [Samuel Sung](https://codeberg.org/samuelsung)

### Free Up The Disk Space

To free up disk space you can clear unused nixos generations

```console
# nix-env -p /nix/var/nix/profiles/system --delete-generations +2 # Remove all NixOS Generations but last 2
# nixos-rebuild boot # Build a new generation and deploy it on next reboot
```

This can easily safe you few Gigabytes if you don't have set maximum number of generations.

Credit: [Samuel Sung](https://codeberg.org/samuelsung)

### Find Missing libraries in Packages

If you have issue opening a binary, because it requires a missing library like:

```console
~/.../SP_Flash_Tool_v5.2228_Linux $ ./flash_tool.sh
error while loading shared libraries: libXrender.so.1: cannot open shared object file: No such file or directory
```

Then you can search for the missing file via mic92's `nix-index-database` which will output the packages that contain it:

```console
$ nix run github:mic92/nix-index-database libXrender.so.1
pyfa.out   52,368 x /nix/store/...-pyfa-2.65.0/share/pyfa/app/libXrender.so.1
libxrender.out  0 s /nix/store/...-libxrender-0.9.12/lib/libXrender.so.1
```

For you to then provide this library:

```console
$ nix shell nixpkgs#libxrender --command ./flash_tool.sh
```

To avoid doing this dance per project, use flakes with FHS environment:

```nix
{
	description = "FHS environment for SP Flash Tool";
	inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

	outputs = { self, nixpkgs }:
		let
			system = "x86_64-linux";
			pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
			fhs = pkgs.buildFHSEnv {
				name = "sp-flash-tool-fhs";
				targetPkgs = pkgs: with pkgs; [ libXrender ];
				runScript = "bash";
			};
		in {
			devShells.${system}.default = fhs.env;
		};
}
```

Then just `cd` to the directory and run `nix develop`.

### Wrapping packages the right way

The NixOS-recommended way to wrap packages is to use `overrideAttrs`:

```nix
(pkgs.dissent.overrideAttrs (super: {
	nativeBuildInputs = (super.nativeBuildInputs or []) ++ [ pkgs.proxychains-ng ];

	postInstall = (super.postInstall or "") + builtins.concatStringsSep "\n" [
		''mv "$out/bin/dissent" "$out/bin/.dissent-wrapped"''
		''cat > "$out/bin/dissent" <<-SCRIPT''
			''#!${pkgs.busybox}/bin/sh''
			''exec proxychains4 "$out/bin/.dissent-wrapped" "$@"''
		''SCRIPT''
		''chmod +x "$out/bin/dissent"''
	];
}))
```

Which is not optimal as it will trigger a rebuild of the package. Instead, consider using `writeShellApplication`:

```nix
pkgs.writeShellApplication {
	name = "dissent";

	runtimeEnv = {
		ALL_PROXY = "socks5://127.0.0.1:25344";
		HTTPS_PROXY = "socks5://127.0.0.1:25344";
	};

	runtimeInputs = [ pkgs.dissent pkgs.proxychains-ng ];

	text = ''exec proxychains4 dissent "$@"'';
}
```

This wraps the package as a shell application which avoids the rebuild and is therefore more resource efficient.

---

## References

### Manuals
- [home-manager options](https://nix-community.github.io/home-manager/options.html)

### Guides
- [NixOS Flakes Wiki](https://nixos.wiki/wiki/Flakes)
- [Shell Scripts with Nix](https://ertt.ca/nix/shell-scripts/)
- [Paranoid NixOS Setup](https://xeiaso.net/blog/paranoid-nixos-2021-07-18)
- [Nix Flakes, Part 3: Managing NixOS systems](https://www.tweag.io/blog/2020-07-31-nixos-flakes/)
- [NixOS Configuration with Flakes](https://jdisaacs.com/series/nixos-desktop/)
- [Shell Style Guide - Google](https://google.github.io/styleguide/shellguide.html)
- [POSIX Parameter Expansion](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02)

### Security
- [OpenSSH security and hardening - Linux Audit](https://linux-audit.com/audit-and-harden-your-ssh-configuration)
- [sshd_config - How to configure OpenSSH](https://www.ssh.com/academy/ssh/sshd_config)
- [Mozilla OpenSSH guidelines](https://infosec.mozilla.org/guidelines/openssh.html)
- [Arch security wiki](https://wiki.archlinux.org/title/security)

### External NixOS Configs

<details>
<summary><strong>Click to expand</strong></summary>

- [Mic92's dotfiles](https://github.com/Mic92/dotfiles)
- [jordanisaacs's dotfiles](https://github.com/jordanisaacs/dotfiles)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [gvolpe/nix-config](https://github.com/gvolpe/nix-config)
- [divnix/digga](https://github.com/divnix/digga)
- [cole-h/nixos-config](https://github.com/cole-h/nixos-config)
- [Mic92/nixos-hardware](https://github.com/NixOS/nixos-hardware)

See source for more.
</details>

---

For detailed discussion context, see [DISCUSSION.md](DISCUSSION.md).

---

*Read [AGENTS.md](AGENTS.md) for agent guidance. Maintain README.md and DISCUSSION.md as you work.*
