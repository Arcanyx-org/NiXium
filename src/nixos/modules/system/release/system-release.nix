{ config, lib, ...}:

# Global Release Management Module

let
	inherit (lib) mkIf;
in {
	# Impermanent setup does not have state
	system.stateVersion = mkIf config.boot.impermanence.enable config.system.nixos.release;
}
