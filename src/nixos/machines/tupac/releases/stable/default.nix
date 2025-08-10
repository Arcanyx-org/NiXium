{ inputs, lib, self, config, ... }:

# Declaration for STABLE release of NixOS for TUPAC

let
	inherit (lib) mkForce;
in {
	flake.nixosConfigurations."nixos-tupac-stable" = inputs.nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";

		pkgs = import inputs.nixpkgs {
			system = "x86_64-linux";
			config.allowUnfree = true;
			config.nvidia.acceptLicense = true; # Fuck You Nvidia! I am Forced into this!
			config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
				# FIXME-QA(Krey): Why the fuck is this needed for a steam controller?
				"steam"
			];
			overlays = [
				# self.overlays.default # Include overlays
			];
		};

		modules = [
			self.nixosModules."nixos-tupac"

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
				config.allowUnfree = true;
			};

			unstable = import inputs.nixpkgs-unstable {
				system = "x86_64-linux";
					config.allowUnfree = true;
			};

			staging = import inputs.nixpkgs-staging {
				system = "x86_64-linux";
					config.allowUnfree = true;
			};

			staging-next = import inputs.nixpkgs-staging-next {
				system = "x86_64-linux";
					config.allowUnfree = true;
			};
		};
	};

	# Task to perform installation of TUPAC in NixOS distribution, stable release
	perSystem = { system, pkgs, inputs', self', ... }: {
		packages.nixos-tupac-stable-install = pkgs.writeShellApplication {
				name = "nixos-tupac-stable-install";
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
					pkgs.openssh # ssh-keygen
					pkgs.nixos-rebuild
					pkgs.util-linux # mountpoint
				];
				runtimeEnv = {
					systemDevice = self.nixosConfigurations.nixos-tupac-stable.config.disko.devices.disk.system.device;

					secretPasswordPath = self.nixosConfigurations.nixos-tupac-stable.config.age.secrets.tupac-disks-password.file;

					secretSSHHostKeyPath = self.nixosConfigurations.nixos-tupac-stable.config.age.secrets.tupac-ssh-ed25519-private.file;
				};
				text = builtins.readFile ./tupac-nixos-stable-install.sh;
			};

		# Declare for `nix run`
		apps.nixos-tupac-stable-install.program = self'.packages.nixos-tupac-stable-install;

		# Unattended installer
		packages.nixos-tupac-stable-unattended-installer-iso = inputs.nixos-generators.nixosGenerate {
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
							ExecStart = "${pkgs.nix}/bin/nix run github:NiXium-org/NiXium#nixos-tupac-stable-install";
							StandardInput = "tty-force";  # Force interaction with TTY1
							StandardOutput = "tty";       # Show the output on the TTY
							StandardError = "tty";        # Display any errors on the TTY
							TTYPath = "/dev/tty1";        # Specify TTY1 for the interaction
							Restart = "always";
							RestartSec = 5; # Wait 5 second before trying again
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

		apps.nixos-tupac-stable-unattended-installer-iso.program = self'.packages.nixos-tupac-stable-unattended-installer-iso;
	};
}
