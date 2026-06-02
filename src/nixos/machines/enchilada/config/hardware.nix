{ pkgs, ... }:

# Temporary Hardware Definition prior to migration to NixWare

{
	zramSwap.enable = true;

	hardware.bluetooth.enable = true;


}
