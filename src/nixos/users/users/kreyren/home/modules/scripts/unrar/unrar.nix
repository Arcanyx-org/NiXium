{ pkgs, ... }:

let
	inherit (builtins) readFile;
in {
	# FIXME(Krey): Only apply this if morph's status is OK
	home.file.".local/bin/unrar" = {
		target = ".local/bin/unrar";
		source = "${pkgs.writeShellApplication {
			name = "unrar";
			bashOptions = [
				"errexit" # Exit on False Return
				"posix" # Run in POSIX mode
			];
			runtimeInputs = [
				pkgs.libarchive # To perform the extraction
			];
			text = readFile ./unrar.sh;
		}}/bin/unrar";
		executable = true; # Make the script executable
	};
}
