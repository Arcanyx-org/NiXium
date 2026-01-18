{ pkgs, ... }:

let
	inherit (builtins) readFile;
in {
	# FIXME(Krey): Only apply this if morph's status is OK
	home.file.".local/bin/ssh.morph" = {
		target = ".local/bin/ssh.morph";
		source = "${pkgs.writeShellApplication {
			name = "ssh.morph";
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
			text = readFile ./ssh-morph.sh;
		}}/bin/ssh.morph";
		executable = true; # Make the script executable
	};
}
