{ lib, config, nixosConfig, ... }:

let
	inherit (lib) mkIf;
in {
	home.persistence."/nix/persist/users/kreyren" = mkIf config.home.impermanence.enable {
		directories = [
			"Monero" # For Monero Wallet
			"src" # For project files
			"Games" # Gaming

			# FIXME-UPSTREAM(Krey): anime-game-launcher and airshipper use sysinfo::Disks
			# to check free space, which excludes tmpfs. On impermanence with tmpfs root,
			# this causes "Path is not mounted" errors. Until upstream switches to statvfs(),
			# these cache dirs must be on persistent (real) storage so their device number
			# matches a disk that sysinfo detects.
			".cache/anime-game-launcher"
			".cache/airshipper"
		];
		files = [];
	};
}
