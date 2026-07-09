{ config, lib, pkgs, ... }:

let
	inherit (lib) mkIf;
in {
	systemd.tmpfiles.rules = [
		"d /home/kreyren/.config 0755 kreyren users -"
		"d /home/kreyren/.local 0755 kreyren users -"
		"d /home/kreyren/.local/state 0755 kreyren users -"
	];
}
