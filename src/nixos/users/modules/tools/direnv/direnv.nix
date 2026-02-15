{ config, lib, ... }:

let
	inherit (lib) mkDefault mkIf;
in mkIf config.programs.direnv.enable {
	programs.direnv = {
		nix-direnv.enable = mkDefault true; # Always use nix-direnv with direnv
	};
}
