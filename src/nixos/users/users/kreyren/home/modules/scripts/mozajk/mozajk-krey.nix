{ pkgs, lib, ... }:

let
	inherit (builtins) readFile;
	inherit (lib) mkDefault;
in {
	home.file.".local/bin/mozajk" = {
		target = ".local/bin/mozajk";
		source = "${pkgs.writeShellApplication {
			name = "mozajk";
			bashOptions = [
				"errexit" # Exit on False Return
				"posix" # Run in POSIX mode
			];
			runtimeInputs = [];
			runtimeEnv = {};
			text = readFile ./mozajk-krey.sh;
		}}/bin/mozajk";
		executable = true; # Make the script executable
	};
}
