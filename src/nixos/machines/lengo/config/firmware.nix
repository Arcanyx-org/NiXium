{ lib, ... }:

# Firmware management of LENGO

let
	inherit (lib) mkForce;
in {
	services.fwupd.enable = false; # Use FWUP daemon to keep firmware files up-to-date

	# SECURITY(Krey): This introduces blobs that likely have backdoor in them, but the CPU won't work without it :(
	hardware.enableRedistributableFirmware = true;
	hardware.cpu.amd.updateMicrocode = true;
}
