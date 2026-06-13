{ lib, ... }:

# Firmware management of MRACEK

let
	inherit (lib) mkForce;
in {
	# FIXME-SECURITY(Krey): Pending management so that fwupd doesn't pull proprietary code on the system
	services.fwupd.enable = mkForce false; # Use FWUP daemon to keep firmware files up-to-date

	# Do not allow any kind of proprietary code on the device, fuck neccesary evil
		hardware.enableRedistributableFirmware = mkForce false;
		hardware.cpu.intel.updateMicrocode = mkForce false;
}
