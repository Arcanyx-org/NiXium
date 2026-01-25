{ inputs, lib, self, pkgs, ... }:

# Declaration for STABLE release of NixOS for SINNENFREUDE

let
	inherit (lib) mkForce;
in {
	flake.nixosConfigurations."nixos-sinnenfreude-stable" = inputs.nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";

		pkgs = import inputs.nixpkgs {
			system = "x86_64-linux";
			config.allowUnfree = mkForce false; # Forbid proprietary code
			config.nvidia.acceptLicense = false; # Nvidia, Fuck You!
		};

		modules = [
			self.nixosModules."nixos-sinnenfreude"

			{
				boot.impermanence.enable = true; # Impermanence
				boot.plymouth.enable = true; # Eye Candy Boot Animation

				nix.distributedBuilds = true; # Perform distributed builds

				programs.adb.enable = true; # Android Debug Bridge
				programs.appimage.enable = true; # Enable compatibility layer for appimages
				programs.nix-ld.enable = true;
				programs.noisetorch.enable = true;

				# Desktop Environment
				# services.xserver.enable = true;
				services.displayManager.gdm.enable = true;
				services.desktopManager.gnome.enable = true;
					programs.dconf.enable = true; # Needed for home-manager to not fail deployment (https://github.com/nix-community/home-manager/issues/3113)
					services.displayManager.gdm.autoSuspend = false;
					# services.xserver.displayManager.gdm.wayland = false; # Do not use wayland as it has CONSTANT issues

				services.flatpak.enable = true;
				services.openssh.enable = true;
				services.tor.enable = true;
				# TODO(Krey): Pending Management
					services.usbguard.dbus.enable = false;
				services.smartd.enable = true;
				services.clamav.daemon.enable = true;
				services.printing.enable = true;
				# services.rustdesk-server.enable = true;
				# 	services.rustdesk-server.openFirewall = tru
				services.usbmuxd.enable = true;

				# Japanese Keyboard Input
				i18n.inputMethod.enable = true;
					i18n.inputMethod.type = "fcitx5";
					# i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-mozc ];
				i18n.defaultLocale = "en_US.UTF-8";

				powerManagement.powertop.enable = true;

				security.sudo.enable = false;
				security.sudo-rs.enable = true;

				# Miracast
					networking.firewall.allowedTCPPorts = [7236 7250];
					networking.firewall.allowedUDPPorts = [7236 5353];

				virtualisation.waydroid.enable = true;
				virtualisation.docker.enable = true;

				nix.channel.enable = true; # To be able to use nix repl :l <nixpkgs> as loading flake loads only 16 variables
			}

			{
				nix.nixPath = [
					"nixpkgs=${self.inputs.nixpkgs}"
				];

				nix.registry = {
					nixpkgs = { flake = self.inputs.nixpkgs; };
				};
			}

			{
				# De-NixOSfy Experiment - Remove cache.nixos.org and build from source instead THE GOOD OLD GENTOO WAY!
				# FIXME(Krey): Pending infrastructural management as this is too computationally demanding rn
				# FIXME-INFRA(Krey): Figured out the hard way that even with GitHub OAuth Token set which significantly expands the API Rate Limit we still hit it in not even 5 min
				# nix.settings = {
				# 	substituters = mkForce [];
				# 	trusted-public-keys = mkForce [];
				# };
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

	# Task to perform installation of SINNENFREUDE in NixOS distribution, stable release
	perSystem = { system, pkgs, inputs', self', ... }: {
		packages.nixos-sinnenfreude-stable-install = pkgs.writeShellApplication {
				name = "nixos-sinnenfreude-stable-install";
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
					systemDevice = self.nixosConfigurations.nixos-sinnenfreude-stable.config.disko.devices.disk.system.device;

					secretPasswordPath = self.nixosConfigurations.nixos-sinnenfreude-stable.config.age.secrets.sinnenfreude-disks-password.file;

					secretSSHHostKeyPath = self.nixosConfigurations.nixos-sinnenfreude-stable.config.age.secrets.sinnenfreude-ssh-ed25519-private.file;
				};
				text = builtins.readFile ./sinnenfreude-nixos-stable-install.sh;
			};

		# Declare for `nix run`
		apps.nixos-sinnenfreude-stable-install.program = self'.packages.nixos-sinnenfreude-stable-install;

		# Unattended installer
		packages.nixos-sinnenfreude-stable-unattended-installer-iso = inputs.nixos-generators.nixosGenerate {
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
							ExecStart = "${pkgs.nix}/bin/nix run github:NiXium-org/NiXium#nixos-sinnenfreude-stable-install";
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

		apps.nixos-sinnenfreude-stable-unattended-installer-iso.program = self'.packages.nixos-sinnenfreude-stable-unattended-installer-iso;
	};
}
