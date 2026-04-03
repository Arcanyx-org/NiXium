{ lib, self, inputs, ... }:

###! # Neovim Editor Configuration for Kreyren
###!
###! This module provides:
###! 1. A home-manager module (nvim.nix) for Kreyren's neovim configuration
###! 2. A minimal VM test environment for validating nvim changes
###!
###! ## VM TEST ENVIRONMENT
###!
###! The VM uses a minimal Wayland kiosk setup:
###! - greetd: Display manager with autologin
###! - cage: Wayland kiosk compositor
###! - foot: Lightweight Wayland terminal
###! - nvim: The editor being tested
###!
###! Usage:
###!   nix run .#nixos-vm-editors-nvim-kreyren

let
	inherit (lib) mkMerge concatStringsSep;
	inherit (builtins) elem getName;
in mkMerge [
	{
		flake.homeManagerModules.editors-nvim-kreyren = ./nvim.nix;
	}

	{
		perSystem = { system, pkgs, inputs', self', ... }:
			let
				modulePath = "$FLAKE_ROOT/src/nixos/users/users/kreyren/home/modules/editors/nvim/";

				test-nvim = inputs.nixpkgs.lib.nixosSystem {
					inherit system;

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
							boot.lanzaboote.enable = false;

							# Ensure required packages are installed
							environment.systemPackages = with pkgs; [ cage foot neovim ];

						home-manager = {
							useGlobalPkgs = true;
							useUserPackages = true;
							# Pass self so nvim.nix can reach self.lib.mkVimConfig
							extraSpecialArgs = { inherit self; };
							users.kreyren = {
								imports = [
									self.homeManagerModules.editors-nvim-kreyren
								];
								programs.neovim.enable = true;
								home.stateVersion = "25.11";
							};
						};

							users.users.kreyren = {
								description = "Kreyren";
								uid = 1000;
								isNormalUser = true;
								createHome = true;
								password = "000000";
								extraGroups = [ "video" "wheel" ];
							};

							# Minimal Wayland kiosk stack: greetd -> cage -> foot -> nvim
							services.greetd = {
								enable = true;
								settings.default_session = {
									command = "${pkgs.cage}/bin/cage -- ${pkgs.foot}/bin/foot -e nvim";
									user = "kreyren";
								};
							};

							# greetd tries to restart on failure which causes issues in VM
							# Cage exits when nvim closes, so we disable restart to avoid loops
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

							virtualisation.vmVariant = {
								virtualisation = {
									memorySize = 1024 * 2; # 2GB RAM (increased from 1GB)
									cores = 2; # 2 cores (increased from 1)
									diskSize = 1024 * 4; # 4GB disk (increased from 2GB)
									graphics = true;
								};
							};

							boot.impermanence.enable = lib.mkForce false;
							boot.kernelParams = [ "console=ttyS0" ];
							system.stateVersion = "25.11";

							age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
							services.openssh = {
								enable = true;
								settings = {
									PermitRootLogin = "yes";
									PasswordAuthentication = true;
								};
							};

							users.users.root.password = "root";
						}
					];

					specialArgs = {
						inherit self;
					};
				};
			in {
				packages.nixos-vm-editors-nvim-kreyren = test-nvim.config.system.build.vm;

				apps.nixos-vm-editors-nvim-kreyren = {
					type = "app";
					program = pkgs.writeShellApplication {
						name = "nixos-vm-editors-nvim-kreyren";
						bashOptions = [ "errexit" ];
						runtimeInputs = [ pkgs.coreutils ];
						text = concatStringsSep "\n" [
							''export NIX_DISK_IMAGE="${modulePath}/nixos-vm-editors-nvim-kreyren.qcow2"''
							''exec "${test-nvim.config.system.build.vm}/bin/run-nixos-vm" "$@"''
						];
					};
				};
			};
	}
]