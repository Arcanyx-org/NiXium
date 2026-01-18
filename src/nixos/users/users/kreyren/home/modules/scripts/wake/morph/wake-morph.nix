{ pkgs, ... }:

let
	inherit (builtins) readFile;
in {
	# FIXME(Krey): Only apply this if morph's status is OK
	home.file.".local/bin/wake.morph" = {
		target = ".local/bin/wake.morph";
		source = "${pkgs.writeShellApplication {
			name = "wake.morph";
			bashOptions = [
				"errexit" # Exit on False Return
				"posix" # Run in POSIX mode
			];
			runtimeInputs = [
				pkgs.openssh # To perform the SSH call
			];
			runtimeEnv = {
				targetMAC = "e0:d5:5e:82:ef:ba"; # MAC Address of The Target Device
			};
			text = readFile ./wake-morph.sh;
		}}/bin/wake.morph";
		executable = true; # Make the script executable
	};
}
