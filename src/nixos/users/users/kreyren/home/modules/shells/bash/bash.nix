{ config, lib, ... }:

let
	inherit (lib) mkIf;
in mkIf config.programs.bash.enable {
	programs.bash = {
		enableCompletion = true;
	};
}
