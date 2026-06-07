{ inputs, lib, self, config, ... }:

# Declaration for STABLE release of NixOS for ENCHILADA

let
	inherit (builtins) elem;
	inherit (lib) concatStringsSep mkForce getName;
in {
	flake.nixosConfigurations."nixos-enchilada-stable" = inputs.nixpkgs.lib.nixosSystem {
		system = "aarch64-linux";

		pkgs = import inputs.nixpkgs {
			system = "aarch64-linux";
			# UNFREE(Krey): Identify these binaries so that we can try to implement them in open-source way
				config.allowUnfreePredicate = pkg: elem (getName pkg) [
					"oneplus-sdm845-firmware-zstd"
					"oneplus-sdm845-firmware"
				];
			# config.allowUnfree = mkForce false; # Forbid proprietary code
		};

		modules = [
			self.nixosModules."nixos-enchilada"

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
				system = "aarch64-linux";
				config.allowUnfree = mkForce false; # Forbid proprietary code
			};

			unstable = import inputs.nixpkgs-unstable {
				system = "aarch64-linux";
				config.allowUnfree = mkForce false; # Forbid proprietary code
			};

			staging = import inputs.nixpkgs-staging {
				system = "aarch64-linux";
				config.allowUnfree = mkForce false; # Forbid proprietary code
			};

			staging-next = import inputs.nixpkgs-staging-next {
				system = "aarch64-linux";
				config.allowUnfree = mkForce false; # Forbid proprietary code
			};
		};
	};

	# Task to make flashable image via fastboot
	perSystem = { system, pkgs, inputs', self', ... }: {
		packages.nixos-enchilada-stable-fastboot = self.nixosConfigurations.nixos-enchilada-stable.config.mobile.outputs.android.android-fastboot-images;

		apps.nixos-enchilada-stable-fastboot ={
			meta.description = "Builder for Enchilada System's fastboot deployment";
			type = "app";
			program = "${pkgs.writeShellApplication {
				name = "nixos-enchilada-stable-fastboot";
				# runtimeInputs = [ ];
				text = concatStringsSep "\n" [
					"echo \"ISO located at: ${self'.packages.nixos-enchilada-stable-fastboot}\""
				];
			}}/bin/nixos-enchilada-stable-fastboot";
		};
	};

	# Task to perform installation of enchilada in NixOS distribution, stable release
	# perSystem = { system, pkgs, inputs', self', ... }: {
	# 	packages.nixos-enchilada-stable-install = pkgs.writeShellApplication {
	# 			name = "nixos-enchilada-stable-install";
	# 			bashOptions = [
	# 				"errexit" # Exit on False Return
	# 				"posix" # Run in POSIX mode
	# 			];
	# 			runtimeInputs = [
	# 				inputs'.disko.packages.disko # disko
	# 				pkgs.age # age
	# 				pkgs.nixos-install-tools # nixos-install
	# 				pkgs.gawk # awk
	# 				pkgs.curl
	# 				pkgs.jq
	# 				pkgs.openssh # ssh-keygen
	# 				pkgs.nixos-rebuild
	# 				pkgs.util-linux # mountpoint
	# 			];
	# 			runtimeEnv = {
	# 				systemDevice = self.nixosConfigurations.nixos-enchilada-stable.config.disko.devices.disk.system.device;

	# 				systemSwapDevice = self.nixosConfigurations.nixos-enchilada-stable.config.disko.devices.disk.system.content.partitions.swap.device;

	# 				secretPasswordPath = self.nixosConfigurations.nixos-enchilada-stable.config.age.secrets.enchilada-disks-password.file;

	# 				secretSSHHostKeyPath = self.nixosConfigurations.nixos-enchilada-stable.config.age.secrets.enchilada-ssh-ed25519-private.file;

	# 				derivation = "nixos-enchilada-stable";

	# 				machineName = "enchilada";
	# 			};
	# 			text = builtins.readFile ./enchilada-nixos-stable-install.sh;
	# 		};

	# 	# Declare for `nix run`
	# 	apps.nixos-enchilada-stable-install.program = self'.packages.nixos-enchilada-stable-install;

	# 	# Unattended installer
	# 	packages.nixos-enchilada-stable-unattended-installer-iso = inputs.nixos-generators.nixosGenerate {
	# 		pkgs = import inputs.nixpkgs {
	# 			inherit system;
	# 			config.allowUnfree = true;
	# 		};

	# 		inherit system;

	# 		modules = [
	# 			{
	# 				boot.loader.timeout = mkForce 0;

	# 				boot.kernelParams = [
	# 					"copytoram" # Run the installer from the Random Access Memory
	# 				];

	# 				environment.systemPackages = [
	# 					pkgs.git
	# 				];

	# 				nix.settings.experimental-features = "nix-command flakes";

	# 				services.getty.loginProgram = "${pkgs.util-linux}/bin/nologin"; # Do not permit login on ttys

	# 				services.getty.greetingLine = ''<<< Welcome To The NiXium Installer >>>'';

	# 				systemd.services.inception = {
	# 					description = "NiXium Installation";
	# 					after = [ "multi-user.target" ];
	# 					wantedBy = [ "network-online.target" ];
	# 					path = [
	# 						inputs'.disko.packages.disko-install # disko-install
	# 						pkgs.age # age
	# 						pkgs.nixos-install-tools # nixos-install
	# 						pkgs.gawk # awk
	# 						pkgs.curl
	# 						pkgs.jq
	# 						pkgs.openssh # ssh-keygen
	# 						pkgs.nixos-rebuild
	# 						pkgs.util-linux # mountpoint
	# 					];

	# 					serviceConfig = {
	# 						ExecStart = "${pkgs.nix}/bin/nix run github:NiXium-org/NiXium#nixos-enchilada-stable-install";
	# 						StandardInput = "tty-force";  # Force interaction with TTY1
	# 						StandardOutput = "tty";       # Show the output on the TTY
	# 						StandardError = "tty";        # Display any errors on the TTY
	# 						TTYPath = "/dev/tty1";        # Specify TTY1 for the interaction
	# 						Restart = "always";
	# 						RestartSec = 5; # Wait 5 second before trying again
	# 					};
	# 				};

	# 				# Connect to FreeNet if the system doesn't have access to the internet by itself
	# 				networking.wireless.networks."FreeNet" = { };
	# 			}

	# 			{
	# 				services.sshd.enable = true; # Start OpenSSH server
	# 				users.users.root.openssh.authorizedKeys.keys = [
	# 					"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
	# 				];
	# 			}
	# 		];
	# 		format = "iso";

	# 		specialArgs = {
	# 			inherit self;
	# 		};
	# 	};

	# 	apps.nixos-enchilada-stable-unattended-installer-iso.program = self'.packages.nixos-enchilada-stable-unattended-installer-iso;
	# };
}
