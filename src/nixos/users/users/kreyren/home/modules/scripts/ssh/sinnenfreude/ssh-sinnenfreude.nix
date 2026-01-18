{ pkgs, ... }:

let
	inherit (builtins) readFile;
in {
	# FIXME(Krey): Only apply this if SINNENFREUDE's status is OK
	home.file.".local/bin/ssh.sinnenfreude" = {
		target = ".local/bin/ssh.sinnenfreude";
		source = "${pkgs.writeShellApplication {
			name = "ssh.sinnenfreude";
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
			text = readFile ./ssh-sinnenfreude.sh;
		}}/bin/ssh.sinnenfreude";
		executable = true; # Make the script executable
	};
}
