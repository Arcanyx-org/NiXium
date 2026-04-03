{ lib, self, inputs, ... }:

###! # Vim Editor Configuration for Kreyren
###!
###! This module provides:
###! 1. A home-manager module (vim.nix) for Kreyren's vim configuration
###! 2. A VM test environment for validating vim changes without bare-metal deployment
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor (runs single maximized app)
###! - foot: Lightweight Wayland terminal
###! - vim: The editor being tested
###!
###! Usage:
###!   nix run .#nixos-vm-editors-vim-kreyren
###!
###! The VM will boot directly into vim via: greetd -> cage -> foot -e vim

let
	inherit (lib) mkMerge concatStringsSep;
	inherit (builtins) elem getName;
in mkMerge [
	{
		flake.homeManagerModules.editors-vim-kreyren = ./vim.nix;
	}

	{
		perSystem = { system, pkgs, inputs', self', ... }:
			let
				# Path where VM disk image will be stored
				# Using module-relative path keeps disk images organized per-module
				modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/editors/vim/";

				test-vim = inputs.nixpkgs.lib.nixosSystem {
					inherit system;

					# Standard NiXium pkgs configuration
					# Disabling unfree packages for reproducibility and compliance
					pkgs = import inputs.nixpkgs {
						inherit system;
						config.allowUnfree = false;
						config.nvidia.acceptLicense = false;
						config.allowUnfreePredicate = pkg: elem (getName pkg) [];
						overlays = [];
					};

					modules = [
						self.nixosModules.default

						self.inputs.ragenix.nixosModules.default
						self.inputs.sops.nixosModules.sops
						self.inputs.hm.nixosModules.home-manager
						self.inputs.disko.nixosModules.disko
						self.inputs.lanzaboote.nixosModules.lanzaboote
						self.inputs.impermanence.nixosModules.impermanence

						{
							# Disable secure boot for testing VM
							boot.lanzaboote.enable = false;

							# Home-manager configuration
							# useGlobalPkgs/useUserPackages required for home-manager to access system packages
							home-manager = {
								useGlobalPkgs = true;
								useUserPackages = true;
								users.kreyren = {
									imports = [
										self.homeManagerModules.editors-vim-kreyren
									];
									# Enable vim in home-manager so vim.nix settings apply
									# vim.nix uses: mkIf config.programs.vim.enable { ... }
									programs.vim.enable = true;
									# FIXME-UPSTREAM(Krey): home-manager doesn't recognize 26.05 stateVersion yet.
									# lib.trivial.release returns "26.05" (unstable development after 25.11 stable)
									# but home-manager's stateVersion only accepts stable release identifiers (up to 25.11).
									# Use latest known stable version until home-manager adds 26.05 support.
									home.stateVersion = "25.11";
								};
							};

							# Test user configuration
							users.users.kreyren = {
								description = "Kreyren";
								uid = 1000;
								isNormalUser = true;
								createHome = true;
								password = "000000"; # Intentionally simple for test VM
								extraGroups = [ "video" "wheel" ];
							};

							# Minimal Wayland kiosk stack: greetd -> cage -> foot -> vim
							# greetd: Lightweight display manager with autologin support
							# cage: Wayland kiosk compositor that runs a single maximized application
							# foot: Fast, lightweight Wayland-native terminal
							services.greetd = {
								enable = true;
								settings.default_session = {
									# cage runs foot which executes vim
									command = "${pkgs.cage}/bin/cage -- ${pkgs.foot}/bin/foot -e vim";
									user = "kreyren";
								};
							};

							# greetd tries to restart on failure which causes issues in VM
							# Cage exits when vim closes, so we disable restart to avoid loops
							systemd.services.greetd.serviceConfig.Restart = lib.mkForce "no";

							# Foot terminal configuration
							# Dark theme for readability, monospace font for code editing
							environment.etc."xdg/foot/foot.ini".text = ''
								[main]
								font=monospace:size=12

								[colors]
								background=1a1a1a
								foreground=dcdccc
							'';

							# VM configuration - minimal resources for testing
							virtualisation.vmVariant = {
								virtualisation = {
									memorySize = 1024 * 2; # 2GB RAM
									cores = 2;
									diskSize = 1024 * 5; # 5GB disk
									graphics = true; # Required for Wayland/cage
								};
							};

							# Disable impermanence and disko for VM testing
							boot.impermanence.enable = lib.mkForce false;

							# Enable console output for debugging
							boot.kernelParams = [ "console=ttyS0" ];

							system.stateVersion = "25.11";

							# Required for age secrets (ragenix)
							age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
							services.openssh.enable = true;
						}
					];

					specialArgs = {
						inherit self;
					};
				};
			in {
				# The VM package - build with: nix build .#nixos-vm-editors-vim-kreyren
				packages.nixos-vm-editors-vim-kreyren = test-vim.config.system.build.vm;

				# The app runner - execute with: nix run .#nixos-vm-editors-vim-kreyren
				# Disk image persists in module directory for iterative testing
				apps.nixos-vm-editors-vim-kreyren = {
					type = "app";
					program = pkgs.writeShellApplication {
						name = "nixos-vm-editors-vim-kreyren";
						bashOptions = [ "errexit" ];
						runtimeInputs = [ pkgs.coreutils ];
						text = concatStringsSep "\n" [
							''export NIX_DISK_IMAGE="${modulePath}/nixos-vm-editors-vim-kreyren.qcow2"''
							''# Let VM create disk image if it doesn't exist''
							''exec "${test-vim.config.system.build.vm}/bin/run-nixos-vm" "$@"''
						];
					};
				};
			};
	}
]
