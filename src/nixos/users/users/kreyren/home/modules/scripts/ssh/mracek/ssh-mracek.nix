{ pkgs, ... }:

let
	inherit (builtins) readFile;
in {
	# FIXME(Krey): Only apply this if MRACEK's status is OK
	home.file.".local/bin/ssh.mracek" = {
		target = ".local/bin/ssh.mracek";
		source = "${pkgs.writeShellApplication {
			name = "ssh.mracek";
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
			text = readFile ./ssh-mracek.sh;
		}}/bin/ssh.mracek";
		executable = true; # Make the script executable
	};
}
