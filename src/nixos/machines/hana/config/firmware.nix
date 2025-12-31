{ lib, ... }:

# Firmware management of HANA

let
	inherit (lib) mkForce;
in {
	services.fwupd.enable = true; # Use FWUP daemon to keep firmware files up-to-date
}
