{ inputs, lib, self, ... }:

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
				boot.impermanence.enable = true; # Whether To Use Impermanence
				boot.plymouth.enable = true; # Show eyecandy on bootup?
				nix.distributedBuilds = true; # Perform distributed builds

				programs.adb.enable = true;
				programs.gamemode.enable = true;
					# programs.gamemode.enableRenice = true;
					# programs.gamemode.settings = {
					# 	general = {
					# 		renice = 10;
					# 	};

					# 	# Warning: GPU optimisations have the potential to damage hardware
					# 	gpu = {
					# 		apply_gpu_optimisations = "accept-responsibility";
					# 		gpu_device = 1;
					# 	};

					# 	# custom = {
					# 	# 	start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
					# 	# 	end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
					# 	# };
					# };
				programs.steam.enable = true;
				programs.noisetorch.enable = true; # Microphone filtering
				programs.nix-ld.enable = true;
				# programs.appimage = {
				# 	enable = true;
				# 	binfmt = true;
				# 	package = inputs'.nixpkgs.legacyPackages.appimage-run.override {
				# 		extraPkgs = pkgs: [
				# 			# FIXME(Krey): Once we figure out what packages are in general needed for appimages then move this into a global configuration
				# 			# Some packages need this dependency, added for utility - https://github.com/NixOS/nixpkgs/issues/350383#issuecomment-2433316461
				# 			inputs'.nixpkgs.legacyPackages.libepoxy

				# 			# Required by Melon Launcher's AppImage (https://github.com/LykosAI/StabilityMatrix/issues/554)
				# 				# * Process terminated. Couldn't find a valid ICU package installed on the system. Please install libicu (or icu-libs) using your package manager and try again. Alternatively you can set the configuration flag System.Globalization.Invariant to true if you want to run with no globalization support. Please see https://aka.ms/dotnet-missing-libicu for more information.
				# 				# * May be by bypasseded with:
				# 				# ** DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
				# 				# ** DOTNET_SYSTEM_GLOBALIZATION_PREDEFINED_CULTURES_ONLY=false
				# 				inputs'.nixpkgs.legacyPackages.icu77
				# 				inputs'.nixpkgs.legacyPackages.libxcrypt-legacy # https://github.com/LykosAI/StabilityMatrix/issues/554#issuecomment-2798941427
				# 				inputs'.nixpkgs.legacyPackages.python312
				# 				inputs'.nixpkgs.legacyPackages.python312Packages.torch

				# 				inputs'.nixpkgs.legacyPackages.webkitgtk_4_1 # libwebkit2gtk-4.1.so.0
				# 				inputs'.nixpkgs.legacyPackages.webkitgtk_4_0 # libwebkit2gtk-4.0.so.0

				# 				inputs'.nixpkgs.legacyPackages.openxr-loader
				# 		];
				# 	};
				# };

				services.flatpak.enable = true;
				services.openssh.enable = true;
				services.tor.enable = true;
				services.hardware.openrgb.enable = false;
				services.gvfs.enable = true;
				# TODO(Krey): Pending Management
					services.usbguard.dbus.enable = false;
				services.smartd.enable = true;
				services.clamav.daemon.enable = true;
				# services.ollama.enable = false;
				# 	services.open-webui.enable = false;
				# 	users.users.alpaka = {
				# 		description = "Alpaka";
				# 		uid = 1050;
				# 		isNormalUser = true;
				# 		createHome = true;
				# 		extraGroups = [
				# 			# (mkIf config.virtualisation.docker.enable "docker")
				# 			(mkIf config.programs.adb.enable "adbusers")
				# 			"video"
				# 		];
				# 		openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHmtDqiOqgXx0WaJE3C+DWCdTegP6vC74/ICAcmA5xja kreyren@tupac" ];
				# 	};
				# FIXME(Krey): Pending work
				services.opensnitch.enable = false;
				services.printing.enable = true;
				services.sunshine.enable = true;
				programs.localsend.enable = true;
					programs.localsend.openFirewall = true;
				# services.rustdesk-server.enable = true;
				# 	services.rustdesk-server.openFirewall = tru
				services.usbmuxd.enable = true;
				# services.undervolt = {
				# 	enable = true;
				# 	tempAc = 97;
				# 	tempBat = 75;
				# 	# coreOffset = -100;
				# 	# gpuOffset = -30;
				# 	#uncoreOffset = -50;
				# 	#analogioOffset = -50;
				# };
				services.wivrn.enable = true;

				# Miracast
					networking.firewall.allowedTCPPorts = [7236 7250];
					networking.firewall.allowedUDPPorts = [7236 5353];

				# Desktop Environment
				services.displayManager.gdm.enable = true;
				services.desktopManager.gnome.enable = true;
					programs.dconf.enable = true; # Needed for home-manager to not fail deployment (https://github.com/nix-community/home-manager/issues/3113)
					services.displayManager.gdm.autoSuspend = false;
					# services.xserver.displayManager.gdm.wayland = false; # Do not use wayland as it has CONSTANT issues

				# Power Management
				powerManagement.enable = true;
				powerManagement.powertop.enable = true;
				services.tlp.enable = false;
					services.power-profiles-daemon.enable = true;

				# networking.wireguard.enable = false;

				hardware.steam-hardware.enable = true; # Compatibility for Steam Controller

				# Necessary Evil :(
				hardware.enableRedistributableFirmware = true;
				hardware.cpu.intel.updateMicrocode = true;

				system.autoUpgrade.enable = true;

				security.sudo.enable = false;
				security.sudo-rs.enable = true;

				virtualisation.waydroid.enable = true;
				virtualisation.docker.enable = true;

				nix.settings.trusted-users = [ "kreyren" ]; # Add Kreyren in Trusted-Users
				nix.channel.enable = true; # To be able to use nix repl :l <nixpkgs> as loading flake loads only 16 variables

				xdg.portal.xdgOpenUsePortal = true;

				# De-NixOSfy Experiment - Remove cache.nixos.org and build from source instead THE GOOD OLD GENTOO WAY!
				# FIXME(Krey): Pending infrastructural management as this is too computationally demanding rn
				# FIXME-INFRA(Krey): Figured out the hard way that even with GitHub OAuth Token set which significantly expands the API Rate Limit we still hit it in not even 5 min
				# nix.settings = {
				# 	substituters = mkForce [];
				# 	trusted-public-keys = mkForce [];
				# };
			}

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
