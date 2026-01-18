{ inputs, lib, self, ... }:

# Customized rescueImage to work with the NixOS Distribution

let
	inherit (builtins) concatStringsSep;
	inherit (lib) mkForce;
in {
	perSystem = { system, pkgs, inputs', self', ... }: {
		packages.nixos-rescueImage = inputs.nixos-generators.nixosGenerate {
			pkgs = import inputs.nixpkgs {
				inherit system;
				config.allowUnfree = true;
			};

			inherit system;

			modules = [
				{
					boot.loader.timeout = mkForce 0; # Skip Bootloader unless the spacebar is held down during boot

					boot.kernelParams = [
						"copytoram" # Run the installer from the Random Access Memory
					];

					environment.systemPackages = [
						pkgs.git
					];

					nix.settings.experimental-features = "nix-command flakes";

					services.getty.greetingLine = ''<<< Welcome To The NiXium Rescue >>>'';

					networking.wireless.networks."FreeNet" = { }; # Connect to FreeNet if the system doesn't have access to the internet by itself

					system.stateVersion = lib.versions.majorMinor lib.version; # Silence the state version warning
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

		# apps.nixos-rescueImage ={
		# 	meta.description = "Builder for the NiXium Rescue Image";
		# 	type = "app";
		# 	program = pkgs.writeShellScript "nixos-rescueImage" (concatStringsSep "/n"
		# 		"echo \"ISO located at: ${self'.packages.nixos-rescueImage}\""
		# 	);
		# };
	};
}
