{ inputs, lib, self, self', ... }:

# Declaration for STABLE release of NixOS for MORPH

let
	inherit (lib) mkForce;
in {
	flake.nixosConfigurations."nixos-morph-stable" = inputs.nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";

		pkgs = import inputs.nixpkgs {
			system = "x86_64-linux";
			config.allowUnfree = mkForce true; # Allow unfree as the GPU won't init without it.. Thanks AMD.. Getting intel GPU as soon as I can
			config.nvidia.acceptLicense = mkForce false; # Nvidia, Fuck You!
		};

		modules = [
			self.nixosModules."nixos-morph"

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

	# Task to perform installation of morph in NixOS distribution, stable release
	perSystem = { system, pkgs, inputs', self', ... }: {
		packages.nixos-morph-stable-install = pkgs.writeShellApplication {
				name = "nixos-morph-stable-install";
				bashOptions = [
					"errexit" # Exit on False Return
					"posix" # Run in POSIX mode
				];
				runtimeInputs = [
					inputs'.disko.packages.disko-install # disko-install
					pkgs.age # age
					pkgs.nixos-install-tools # nixos-install
					pkgs.gawk # awk
					pkgs.curl
					pkgs.jq
				];
				runtimeEnv = {
					systemDevice = self.nixosConfigurations.nixos-morph-stable.config.disko.devices.disk.system.device;

					secretPasswordPath = self.nixosConfigurations.nixos-morph-stable.config.age.secrets.morph-disks-password.file;

					secretSSHHostKeyPath = self.nixosConfigurations.nixos-morph-stable.config.age.secrets.morph-ssh-ed25519-private.file;
				};
				text = builtins.readFile ./morph-nixos-stable-install.sh;
			};

		# Declare for `nix run`
		apps.nixos-morph-stable-install.program = self'.packages.nixos-morph-stable-install;

		# Unattended installer
		packages.nixos-morph-stable-unattended-installer-iso = inputs.nixos-generators.nixosGenerate {
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
							ExecStart = "${pkgs.nix}/bin/nix run github:kreyren/nixos-config/morph-changes#nixos-morph-stable-install";
							StandardInput = "tty-force";  # Force interaction with TTY1
							StandardOutput = "tty";       # Show the output on the TTY
							StandardError = "tty";        # Display any errors on the TTY
							TTYPath = "/dev/tty1";        # Specify TTY1 for the interaction
							Restart = "always";
							# Make it wait 30 sec so that we don't blow past the API rate limits in case there is an error
							RestartSec = 30; # Wait 30 second before trying again
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

		apps.nixos-morph-stable-unattended-installer-iso.program = self'.packages.nixos-morph-stable-unattended-installer-iso;
	};
}
