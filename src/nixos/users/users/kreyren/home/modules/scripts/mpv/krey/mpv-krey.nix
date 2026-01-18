{ pkgs, lib, ... }:

let
	inherit (builtins) readFile;
	inherit (lib) mkDefault;
in {
	home.file.".local/bin/mpv.krey" = {
		target = ".local/bin/mpv.krey";
		source = "${pkgs.writeShellApplication {
			name = "mpv.krey";
			bashOptions = [
				"errexit" # Exit on False Return
				"posix" # Run in POSIX mode
			];
			runtimeInputs = [
				pkgs.torsocks # Torify the command
				pkgs.mpv
			];
			runtimeEnv = {
				videoQuality = mkDefault "360"; # Expected video quality (1080, 720, 480, 360, 240, etc..)
			};
			text = readFile ./mpv-krey.sh;
		}}/bin/mpv.krey";
		executable = true; # Make the script executable
	};
}
