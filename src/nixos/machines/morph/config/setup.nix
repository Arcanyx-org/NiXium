{ config, lib, ... }:

# Setup of MORPH

let
	inherit (lib) mkIf;
in {
	networking.hostName = "morph";

	boot.impermanence.enable = true; # Use impermanence

	boot.plymouth.enable = true;

	nix.distributedBuilds = true; # Perform distributed builds if requested

	services.openssh.enable = true;
	services.sunshine.enable = true;
	services.tor.enable = true;
	# FIXME(Krey): Kernel Panic on wake-up
	services.autosuspend.enable = false;
		services.autosuspend.settings = {
			interval = 30; # How often the wakeups are checked
			idle_time = 120; # How long would it take to suspend if all wakeups are inactive
		};
		services.autosuspend.checks.ActiveConnection.ports = builtins.concatStringsSep "," [ "22" ]; # Do Not Suspend On Active SSH Connection

	users.users.root.openssh.authorizedKeys.keys = mkIf config.services.openssh.enable [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" # Allow root access for the Super Administrator (KREYREN)
	];

	age.secrets.morph-ssh-ed25519-private.file = ../secrets/morph-ssh-ed25519-private.age; # Declare private key

	nixpkgs.hostPlatform = "x86_64-linux";
}
