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

				nixosModules.programs-git
				nixosModules.programs-htop
				nixosModules.programs-vim
				nixosModules.programs-wakeonlan

				nixosModules.security
				nixosModules.security-nvidia
				nixosModules.security-sudo

				nixosModules.services-distributedBuilds
				nixosModules.services-monero
				nixosModules.services-sshd
				nixosModules.services-tor

				nixosModules.system-bootloader
				nixosModules.system-ccache
				nixosModules.system-clamav
				nixosModules.system-docker
				nixosModules.system-environment
				nixosModules.system-firewall
				nixosModules.system-impermenance
				nixosModules.system-kernel
				nixosModules.system-lanzaboote
				nixosModules.system-locale
				nixosModules.system-nix
				nixosModules.system-release
				nixosModules.system-time
				nixosModules.system-wifi

				nixosModules.machine-flexy
				nixosModules.machine-ignucius
				nixosModules.machine-lengo
				# nixosModules.machine-morph
				nixosModules.machine-mracek
				nixosModules.machine-sinnenfreude
				nixosModules.machine-tupac

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
