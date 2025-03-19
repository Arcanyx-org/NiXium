{ inputs, lib, self, config, ... }:

# Declaration for UNSTABLE release of NixOS for LENGO

let
	inherit (lib) mkForce;
in {
	flake.nixosConfigurations."nixos-lengo-unstable" = inputs.nixpkgs-unstable.lib.nixosSystem {
		system = "x86_64-linux";

		pkgs = import inputs.nixpkgs-unstable {
			system = "x86_64-linux";
			config.allowUnfree = mkForce false; # Forbid proprietary code
			config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
				"steamdeck-hw-theme"
				"steam-jupiter-unwrapped"
				"steam"
			];
		};

		modules = [
			self.nixosModules."nixos-lengo"

			{
				nix.nixPath = [
					"nixpkgs=${self.inputs.nixpkgs}"
				];

				nix.registry = {
					nixpkgs = { flake = self.inputs.nixpkgs; };
				};
			}

			# Principles
			self.inputs.ragenix-unstable.nixosModules.default
			self.inputs.sops-unstable.nixosModules.sops
			self.inputs.hm-unstable.nixosModules.home-manager
			self.inputs.disko-unstable.nixosModules.disko
			self.inputs.lanzaboote.nixosModules.lanzaboote
			self.inputs.impermanence.nixosModules.impermanence
			self.inputs.arkenfox-unstable.hmModules.default

			# An Anime Game
			self.inputs.aagl-unstable.nixosModules.default {
				networking.mihoyo-telemetry.block = true; # Block miHoYo telemetry servers
				nix.settings = {
					substituters = [ "https://ezkea.cachix.org" ];
					trusted-public-keys = [ "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=" ];
				};
			}
		];

		specialArgs = {
			inherit self;

			# Priciple args
			stable = import inputs.nixpkgs {
				system = "x86_64-linux";
				config.allowUnfree = mkForce false; # Forbid proprietary code
			};

			unstable = import inputs.nixpkgs-unstable {
				system = "x86_64-linux";
				config.allowUnfree = mkForce false; # Forbid proprietary code
			};

			staging = import inputs.nixpkgs-staging {
				system = "x86_64-linux";
				config.allowUnfree = mkForce false; # Forbid proprietary code
			};

			staging-next = import inputs.nixpkgs-staging-next {
				system = "x86_64-linux";
				config.allowUnfree = mkForce false; # Forbid proprietary code
			};
		};
	};

	# Task to perform installation of LENGO in NixOS distribution, stable release
	perSystem = { system, pkgs, inputs', self', ... }: {
		packages.nixos-lengo-unstable-install = pkgs.writeShellApplication {
				name = "nixos-lengo-unstable-install";
				bashOptions = [
					"errexit" # Exit on False Return
					"posix" # Run in POSIX mode
				];
				runtimeInputs = [
					inputs'.disko.packages.disko # disko
					pkgs.age # age
					pkgs.nixos-install-tools # nixos-install
					pkgs.gawk # awk
					pkgs.curl
					pkgs.jq
					pkgs.openssh # ssh-keygen
					pkgs.nixos-rebuild
					pkgs.util-linux # mountpoint
				];
				runtimeEnv = {
					systemDevice = self.nixosConfigurations.nixos-lengo-unstable.config.disko.devices.disk.system.device;

					systemSwapDevice = self.nixosConfigurations.nixos-lengo-unstable.config.disko.devices.disk.system.content.partitions.swap.device;

					secretPasswordPath = self.nixosConfigurations.nixos-lengo-unstable.config.age.secrets.lengo-disks-password.file;

					secretSSHHostKeyPath = self.nixosConfigurations.nixos-lengo-unstable.config.age.secrets.lengo-ssh-ed25519-private.file;

					derivation = "nixos-lengo-unstable";

					machineName = "lengo";
				};
				text = builtins.readFile ./lengo-nixos-unstable-install.sh;
			};

		# Declare for `nix run`
		apps.nixos-lengo-unstable-install.program = self'.packages.nixos-lengo-unstable-install;

		# Unattended installer
		packages.nixos-lengo-unstable-unattended-installer-iso = inputs.nixos-generators.nixosGenerate {
			pkgs = import inputs.nixpkgs-unstable {
				inherit system;
				config.allowUnfree = true;
			};

			inherit system;

			modules = [
				{
					boot.loader.timeout = mkForce 0;

					boot.kernelParams = [
						"copytoram" # Run the installer from the Random Access Memory
					];

					environment.systemPackages = [
						pkgs.git
					];

					nix.settings.experimental-features = "nix-command flakes";

					services.getty.loginProgram = "${pkgs.util-linux}/bin/nologin"; # Do not permit login on ttys

					services.getty.greetingLine = ''<<< Welcome To The NiXium Installer >>>'';

					systemd.services.inception = {
						description = "NiXium Installation";
						after = [ "multi-user.target" ];
						wantedBy = [ "network-online.target" ];
						path = [
							inputs'.disko.packages.disko-install # disko-install
							pkgs.age # age
							pkgs.nixos-install-tools # nixos-install
							pkgs.gawk # awk
							pkgs.curl
							pkgs.jq
							pkgs.openssh # ssh-keygen
							pkgs.nixos-rebuild
							pkgs.util-linux # mountpoint
						];

						serviceConfig = {
							ExecStart = "${pkgs.nix}/bin/nix run github:kreyren/nixos-config/add-lengo#nixos-lengo-unstable-install";
							StandardInput = "tty-force";  # Force interaction with TTY1
							StandardOutput = "tty";       # Show the output on the TTY
							StandardError = "tty";        # Display any errors on the TTY
							TTYPath = "/dev/tty1";        # Specify TTY1 for the interaction
							Restart = "always";
							RestartSec = 30; # Wait 30 second before trying again to avoid hitting timeouts on GitHub
						};
					};

					# Connect to FreeNet if the system doesn't have access to the internet by itself
					networking.wireless.enable = true;
					networking.wireless.networks."FreeNet" = { };
				}

				{
					services.sshd.enable = true; # Start OpenSSH server
					users.users.root.openssh.authorizedKeys.keys = [
						"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
					];
				}
			];
			format = "iso";

			specialArgs = {
				inherit self;
			};
		};

		apps.nixos-lengo-unstable-unattended-installer-iso.program = self'.packages.nixos-lengo-unstable-unattended-installer-iso;
	};
}
