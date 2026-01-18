{ pkgs, ... }:

let
	inherit (builtins) readFile;
in {
	# FIXME(Krey): Only apply this if IGNUCIUS's status is OK
	home.file.".local/bin/ssh.ignucius" = {
		target = ".local/bin/ssh.ignucius";
		source = "${pkgs.writeShellApplication {
			name = "ssh.ignucius";
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
			text = readFile ./ssh-ignucius.sh;
		}}/bin/ssh.ignucius";
		executable = true; # Make the script executable
	};
}
