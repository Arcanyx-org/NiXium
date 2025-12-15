{ self, config, moduleWithSystem, ... }:

# Management of NixOS systems

let
	inherit (config.flake) nixosModules;
in {
	flake.nixosModules.default = moduleWithSystem (
		perSystem@{ system }:
		{ ... }:
		{
			# Keep this sorted
			imports = [
				# self.inputs.jovian.nixosModules.default
				self.inputs.nixified-ai.nixosModules.comfyui

				nixosModules.programs
				nixosModules.security
				nixosModules.services
				nixosModules.system

				nixosModules.machine-flexy
				# nixosModules.machine-ignucius
				nixosModules.machine-lengo
				# nixosModules.machine-morph
				nixosModules.machine-mracek
				nixosModules.machine-sinnenfreude
				# nixosModules.machine-tupac
				nixosModules.machine-twinkcentral

				# {
				# 	sops.defaultSopsFile = ./.sops.yaml;
				# }
			];
		}
	);

	imports = [
		./machines
		./modules
		./overlays
		./users
	];
}
