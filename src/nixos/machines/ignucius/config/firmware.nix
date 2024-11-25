{ lib, ... }:

# Firmware management of IGNUCIUS

let
	inherit (lib) mkForce;
in {
	# NOTE(Krey): Hardened device, do not load any kind of 3rd party firmware that is not explicitly declared
	services.fwupd.enable = false; # Use FWUP daemon to keep firmware files up-to-date

	# Required at the time to use the WiFi Adapter, pending a different one
	hardware.enableRedistributableFirmware = mkForce true; # Whether to load propritary firmware files
}
