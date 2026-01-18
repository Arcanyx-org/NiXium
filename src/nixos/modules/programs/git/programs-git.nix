{ lib, config, pkgs, ... }:

# System git configuration

let
	inherit (lib) mkIf;
in {
	# NiXium dependency needed to manage systems
	environment.systemPackages = [ pkgs.git ]; # Install Git On All Systems

	programs.git.config.init.defaultBranch = "central"; # Set Arcanyx's default branch preference

	programs.git.config.url."https://github.com/".insteadOf = [ "gh:" "github:" ]; # Set shorthands for github

	programs.git.config.safe.directory = "/nix/persist/NiXium"; # Consider NiXium Directory Safe

	# OpenSnitch
		# FIXME-PRIVACY(Krey): Git should go over VPN
	services.opensnitch.rules.git-remote-http = mkIf config.services.opensnitch.enable {
		name = "Permit Git-Remote-Http";
		enabled = true;
		action = "allow";
		duration = "always";
		operator = {
			type = "simple";
			sensitive = false;
			operand = "process.path";
			data = "${lib.getBin pkgs.git}/libexec/git-core/git-remote-http";
		};
	};
}
