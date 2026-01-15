{ self, lib, inputs, ... }:

# Experimental image

let
	inherit (lib) mkOverride;
in {
	perSystem = { system, pkgs, inputs', self', ... }: {
		packages.nixos-installer-minimal = inputs.nixos-generators.nixosGenerate {
			pkgs = import inputs.nixpkgs {
				inherit system;
				config.allowUnfree = true;
			};

			inherit system;

			modules = [
				# FIXME(Krey): It wants to create a 16GB ext4 partition for some reason
				# self.nixosModules.default # Include NiXium Modules
				{
					boot.kernelPackages = pkgs.linuxPackages_6_8;
					environment.systemPackages = [
						pkgs.git
					];
					nix.settings.experimental-features = "nix-command flakes";

				}

				# Principles
				self.inputs.ragenix.nixosModules.default
				self.inputs.sops.nixosModules.sops
				self.inputs.hm.nixosModules.home-manager
				self.inputs.disko.nixosModules.disko
				self.inputs.lanzaboote.nixosModules.lanzaboote
				self.inputs.impermanence.nixosModules.impermanence
				self.inputs.arkenfox.hmModules.default
				self.inputs.nixos-generators.nixosModules.all-formats

				{
					services.sshd.enable = true; # Start OpenSSH server
					users.users.root.openssh.authorizedKeys.keys = [
						"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
					];

					networking.wireless.enable = true; # Do Wireless
					networking.wireless.userControlled.enable = true; # Allow controlling wpa_supplicant via wpa_cli command
					systemd.services.wpa_supplicant.wantedBy = [ "multi-user.target" ]; # Start wpa_supplicant service on startup

					# CONFIDENTIAL!
					networking.wireless.networks."SSID" = {
						hidden = true;
						psk = "PSK"; # CONFIDENTIAL!
						};
				}
			];
			format = "sd-aarch64";

			specialArgs = {
				inherit self;

				# Priciple args
				stable = import inputs.nixpkgs {
					inherit system;
					config.allowUnfree = false; # Forbid proprietary code
				};

				unstable = import inputs.nixpkgs-unstable {
					inherit system;
					config.allowUnfree = false; # Forbid proprietary code
				};

				staging = import inputs.nixpkgs-staging {
					inherit system;
					config.allowUnfree = false; # Forbid proprietary code
				};

				staging-next = import inputs.nixpkgs-staging-next {
					inherit system;
					config.allowUnfree = false; # Forbid proprietary code
				};
			};
		};
	};
}
