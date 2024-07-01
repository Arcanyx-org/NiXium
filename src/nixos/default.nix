{ config, moduleWithSystem, ... }:

# Management of NixOS systems

let
	inherit (config.flake) nixosModules;
in {

# {
# 	flake.homeManagerModules.web-browsers-firefox-kreyren = moduleWithSystem (
# 		perSystem@{ config }:
# 		{
# 			# services.foo.package = perSystem.config.packages.foo;
# 			imports = [ ./firefox.nix ];
# 		}
# 	);
# }

	flake.nixosModules.default = moduleWithSystem (
		perSystem@{ system }:
		{ ... }:
		{
			# Keep this sorted
			imports = [
				nixosModules.programs-git

				nixosModules.security
				nixosModules.security-nvidia

				nixosModules.services-distributedBuilds
				nixosModules.services-monero
				nixosModules.services-sshd
				nixosModules.services-tor

				nixosModules.system-bootloader
				nixosModules.system-ccache
				nixosModules.system-clamav
				nixosModules.system-environment
				nixosModules.system-firewall
				nixosModules.system-impermenance
				nixosModules.system-kernel
				nixosModules.system-lanzaboote
				nixosModules.system-locale
				nixosModules.system-nix
				nixosModules.system-release
				nixosModules.system-security
				nixosModules.system-security-nvidia
				nixosModules.system-time
				nixosModules.system-wifi

				nixosModules.machine-mracek
				nixosModules.machine-sinnenfreude

				# {
				# 	sops.defaultSopsFile = ./.sops.yaml;
				# }
			];
		}
	);

	imports = [
		./machines
		./modules
		./users
	];
}
