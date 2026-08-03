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

				nixosModules.overlays

				nixosModules.programs
				nixosModules.security
				nixosModules.services
				nixosModules.system

				# {
				# 	sops.defaultSopsFile = ./.sops.yaml;
				# }
			];
		}
	);

	imports = [
		./images
		./lib
		./machines
		./modules
		./overlays
		./users
	];
}
