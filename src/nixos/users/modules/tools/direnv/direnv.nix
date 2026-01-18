{ config, lib, ... }:

let
	inherit (lib) mkIf;
in mkIf config.programs.direnv.enable {
	programs.direnv = {
		# Always use nix-direnv with direnv
		nix-direnv.enable = true;
	};
}
