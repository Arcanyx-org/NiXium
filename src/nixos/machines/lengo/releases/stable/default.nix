{ inputs, lib, self, config, ... }:

# Declaration for STABLE release of NixOS for LENGO

let
	inherit (lib) mkForce;
in {
	flake.nixosConfigurations."nixos-lengo-stable" = inputs.nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";

		pkgs = import inputs.nixpkgs {
			system = "x86_64-linux";
			config.allowUnfree = mkForce false; # Forbid proprietary code
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
			self.inputs.ragenix.nixosModules.default
			self.inputs.sops.nixosModules.sops
			self.inputs.hm.nixosModules.home-manager
			self.inputs.disko.nixosModules.disko
			self.inputs.lanzaboote.nixosModules.lanzaboote
			self.inputs.impermanence.nixosModules.impermanence
			self.inputs.arkenfox.hmModules.default

			# An Anime Game
			self.inputs.aagl.nixosModules.default {
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
		packages.nixos-lengo-stable-install = pkgs.writeShellApplication {
				name = "nixos-lengo-stable-install";
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
					systemDevice = self.nixosConfigurations.nixos-lengo-stable.config.disko.devices.disk.system.device;

					systemSwapDevice = self.nixosConfigurations.nixos-lengo-stable.config.disko.devices.disk.system.content.partitions.swap.device;

					secretPasswordPath = self.nixosConfigurations.nixos-lengo-stable.config.age.secrets.lengo-disks-password.file;

					secretSSHHostKeyPath = self.nixosConfigurations.nixos-lengo-stable.config.age.secrets.lengo-ssh-ed25519-private.file;

					derivation = "nixos-lengo-stable";

					machineName = "lengo";
				};
				text = builtins.readFile ./lengo-nixos-stable-install.sh;
			};

		# Declare for `nix run`
		apps.nixos-lengo-stable-install.program = self'.packages.nixos-lengo-stable-install;

		# Unattended installer
		packages.nixos-lengo-stable-unattended-installer-iso = inputs.nixos-generators.nixosGenerate {
			pkgs = import inputs.nixpkgs {
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
							ExecStart = "${pkgs.nix}/bin/nix run github:NiXium-org/NiXium#nixos-lengo-stable-install";
							StandardInput = "tty-force";  # Force interaction with TTY1
							StandardOutput = "tty";       # Show the output on the TTY
							StandardError = "tty";        # Display any errors on the TTY
							TTYPath = "/dev/tty1";        # Specify TTY1 for the interaction
							Restart = "always";
							RestartSec = 30; # Wait 30 second before trying again to avoid hitting timeouts on GitHub
						};
					};

					# Connect to FreeNet if the system doesn't have access to the internet by itself
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

		apps.nixos-lengo-stable-unattended-installer-iso.program = self'.packages.nixos-lengo-stable-unattended-installer-iso;
	};
}
