{ lib, pkgs, ... }:

# Global Kernel Module

let
	inherit (lib) mkDefault;
in {
	# FIXME-HARDENING(Krey): We used to use the hardened kernel, but it's too demanding for maintenance and gives us a little of benefit.. We need to make a kernel changes here that just cherry-pick the patches we want
	# boot.kernelPackages = mkDefault pkgs.linuxPackages; # Prefer mainline kernel

	security.lockKernelModules = mkDefault true; # Prefer to Lock Kernel Modules by default

	security.protectKernelImage = mkDefault true; # Prefer to Protect Kernel Image by default
}
