{ lib, ... }:

# Firmware management of LENGO

let
	inherit (lib) mkForce;
in {
	services.fwupd.enable = false; # Use FWUP daemon to keep firmware files up-to-date

	# SECURITY(Krey): This introduces blobs that can't be reviewed beyond a reasonable doubt to not include malicious code, but the APU will not work without them :( - Pending https://github.com/openSIL/openSIL/issues/24 to improve that
	hardware.enableRedistributableFirmware = true;
	hardware.cpu.amd.updateMicrocode = true;
}
