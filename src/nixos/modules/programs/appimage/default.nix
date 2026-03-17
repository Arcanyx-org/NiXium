{ self, inputs, lib, ... }:

###! # Global Module for AppImage Management
###!
###! AppImages are designed for systems following the Filesystem Hierarchy Standard (FHS). Since NixOS utilizes a unique /nix/store structure, AppImages cannot natively locate required dynamic linkers and shared libraries (e.g., glibc, libstdc++).
###!
###! This module provides a bridge for AppImage execution and system integration by:
###! * 1. Implementing 'appimage-run' to emulate a transient FHS environment.
###! * 2. Managing necessary FHS-compatible shared library paths for binary execution.
###! * 3. Handling desktop integration to ensure seamless launcher support.
###!
###! ### PROJECTED USAGE
###! a. Run any AppImage via CLI: `appimage-run path/to/app.AppImage`
###! b. Execute directly via binfmt_misc registrations configured within this module.
###!
###! ### TECHNICAL NOTE:
###! * This approach bypasses the need for manual 'patchelf' operations, preserving the integrity of the original AppImage binary while ensuring NixOS compatibility.

# DNM(Krey): Figure out how to manage this file

let
	inherit (lib) mkMerge getName;
	inherit (builtins) concatStringsSep elem;

	modulePath = "$FLAKE_ROOT/src/nixos/modules/programs/appimage/";
in mkMerge [
	{
		flake.nixosModules.programs-appimage = ./programs-appimage.nix;
	}

	{
		perSystem = { system, pkgs, inputs', self', ... }:
			let
				checkTimeout = 180;
				programs-appimage = inputs.nixpkgs.lib.nixosSystem {
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
						self.inputs.arkenfox.hmModules.default

						self.nixosModules.users-tester

						{
							programs.appimage.enable = true;

							services.displayManager.gdm.enable = true;
							services.desktopManager.gnome.enable = true;

							services.displayManager.autoLogin.user = "tester";

							virtualisation.vmVariant = {
								virtualisation = {
									memorySize = 1024 * 8;
									cores = 4;
									diskSize = 1024 * 5;
									diskImage = "./src/nixos/modules/programs/appimage/programs-appimage.qcow2";
								};
							};

							system.stateVersion = lib.versions.majorMinor lib.version;

							age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
							services.openssh.enable = true;
						}
					];

					specialArgs = {
						inherit self;
					};
				};

				check-programs-appimage = inputs.nixpkgs.lib.nixosSystem {
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
						self.inputs.arkenfox.hmModules.default

						self.nixosModules.users-tester

						{
							programs.appimage.enable = true;

							boot.kernelParams = [ "console=ttyS0" ];

							virtualisation.vmVariant = {
								virtualisation = {
									memorySize = 1024 * 4;
									cores = 2;
									diskSize = 1024 * 5;
									graphics = false;
								};
							};

							systemd.services.appimage-check = {
								wantedBy = [ "multi-user.target" ];
								after = [ "network.target" ];
								serviceConfig = {
									Type = "oneshot";
									RemainAfterExit = true;
								};
								script = ''
									{
										echo "Running appimage-run checks..."
										[ -x ${pkgs.appimage-run}/bin/appimage-run ] || exit 1
										[ -d ${pkgs.appimage-run} ] || exit 1
										echo "appimage-run binary exists: OK"
										echo "appimage-run directory exists: OK"
									} > /dev/ttyS0 2>&1
									sync
									sleep 1
									systemctl poweroff
								'';
							};

							system.stateVersion = lib.versions.majorMinor lib.version;

							age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
							services.openssh.enable = true;
						}
					];

					specialArgs = {
						inherit self;
					};
				};

				check-programs-appimage-false = inputs.nixpkgs.lib.nixosSystem {
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
						self.inputs.arkenfox.hmModules.default

						self.nixosModules.users-tester

						{
							programs.appimage.enable = true;

							boot.kernelParams = [ "console=ttyS0" ];

							virtualisation.vmVariant = {
								virtualisation = {
									memorySize = 1024 * 4;
									cores = 2;
									diskSize = 1024 * 5;
									graphics = false;
								};
							};

							systemd.services.appimage-check = {
								wantedBy = [ "multi-user.target" ];
								after = [ "network.target" ];
								serviceConfig = {
									Type = "oneshot";
									RemainAfterExit = false;
								};
								script = ''
									{
										echo "This check is designed to fail for testing purposes"
										echo "intentional failure"
									} > /dev/ttyS0 2>&1
									sync
									sleep 1
									/run/current-system/sw/bin/systemctl poweroff
									exit 1
								'';
							};

							system.stateVersion = lib.versions.majorMinor lib.version;

							age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
							services.openssh.enable = true;
						}
					];

					specialArgs = {
						inherit self;
					};
				};
			in {
				packages.nixos-vm-programs-appimage = programs-appimage.config.system.build.vm;
				apps.nixos-vm-programs-appimage = self'.packages.nixos-vm-programs-appimage;

				packages.nixos-vm-impermanent-programs-appimage = pkgs.writeShellApplication {
					name = "nixos-vm-impermanent-programs-appimage";
					bashOptions = [ "errexit" ];
					runtimeInputs = [ pkgs.util-linux ];
					text = concatStringsSep "\n" [
						''export NIX_DISK_IMAGE="${modulePath}/nixos-vm-impermanent-programs-appimage.qcow2"''
						''[ ! -f "$NIX_DISK_IMAGE" ] || rm "$NIX_DISK_IMAGE"''
						''exec "${programs-appimage.config.system.build.vm}/bin/run-nixos-vm" "$@"''
					];
				};
				apps.nixos-vm-impermanent-programs-appimage = self'.packages.nixos-vm-impermanent-programs-appimage;

				checks.programs-appimage-pulse = pkgs.writeShellApplication {
					name = "check-programs-appimage-pulse";
					bashOptions = [ "errexit" ];
					runtimeInputs = [ pkgs.util-linux pkgs.coreutils ];
					text = concatStringsSep "\n" [
						''export NIX_DISK_IMAGE="${modulePath}/check-programs-appimage-pulse.qcow2"''
						''[ ! -f "$NIX_DISK_IMAGE" ] || rm "$NIX_DISK_IMAGE"''
						''exec stdbuf -oL -eL timeout ${toString checkTimeout} "${check-programs-appimage.config.system.build.vm}/bin/run-nixos-vm" -nographic''
					];
				};

				checks.programs-appimage-false = pkgs.writeShellApplication {
					name = "check-programs-appimage-false";
					runtimeInputs = [ pkgs.util-linux pkgs.coreutils ];
					text = concatStringsSep "\n" [
						''set +e''
						''export NIX_DISK_IMAGE="${modulePath}/check-programs-appimage-false.qcow2"''
						''[ ! -f "$NIX_DISK_IMAGE" ] || rm "$NIX_DISK_IMAGE"''
						''stdbuf -oL -eL timeout ${toString checkTimeout} "${check-programs-appimage-false.config.system.build.vm}/bin/run-nixos-vm" -nographic > /tmp/vm-output.log 2>&1''
						''cat /tmp/vm-output.log''
						''if grep -q "intentional failure" /tmp/vm-output.log; then echo "Exiting with 1"; exit 1; fi''
					];
				};
			};
	}
]
