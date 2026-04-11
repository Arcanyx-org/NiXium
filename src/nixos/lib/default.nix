{ lib, ... }:

# flake-parts module: exposes self.lib.vm
#
# VM utilities (mkVmSystem, mkVmRunner, mkWaylandKioskModule) are NixOS-specific
# so they live in src/nixos/lib/ rather than lib/.
{
	flake.lib.vm = import ./vm;
}
