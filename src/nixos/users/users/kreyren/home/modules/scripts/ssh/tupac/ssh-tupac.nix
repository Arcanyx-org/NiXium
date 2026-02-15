{ pkgs, ... }:

let
	inherit (builtins) readFile;
in {
	# FIXME(Krey): Only apply this if SINNENFREUDE's status is OK
	home.file.".local/bin/ssh.tupac" = {
		target = ".local/bin/ssh.tupac";
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
				# FIXME-PRIVACY(Krey): This should be kept confidential
				targetMAC = "f4:6d:3f:67:55:fc"; # MAC Address of The Target Device
			};
			text = readFile ./ssh-tupac.sh;
		}}/bin/ssh.sinnenfreude";
		executable = true; # Make the script executable
	};
}
