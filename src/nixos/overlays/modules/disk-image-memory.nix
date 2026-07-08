{ config, lib, pkgs, ... }:

# ---------------------------------------------------------------------------
# Override: vmTools memory for nixos-disk-image (cptofs builder)
#
# PROBLEM
# When building a VM with useBootLoader=true, nixpkgs constructs a disk
# image via nixos/lib/make-disk-image.nix.  This boots a tiny Linux VM
# (pkgs.vmTools.runInLinuxVM) that:
#   1. Partitions the disk (ESP + root)
#   2. Creates filesystems
#   3. Copies the entire NixOS closure onto it via 9p/virtio (cptofs)
#
# With the default memSize=1024 (MiB), copying a ~42GB closure (GNOME +
# flatpak + waydroid + ollama + docker + clamav + all machine configs)
# is extremely slow — the VM spends most of its time in page reclaim,
# and there is no progress output, making the build appear hung.
#
# FIX
# Raise memSize to 4096 MiB (4 GB) so the kernel has room for page
# cache during the 9p copy.  This is safe — the host has 16 GB.
#
# MECHANISM
# pkgs.vmTools.runInLinuxVM wraps pkgs.runCommand derivations, reading
# the memSize attribute from the derivation's drvAttrs and passing it
# as QEMU's -m flag.  The default memSize in runInLinuxVM is 512, but
# make-disk-image.nix explicitly passes inherit memSize (default 1024
# from its own parameter, line 164 of that file).
#
# Our overlay intercepts every call to runInLinuxVM and uses
# lib.overrideDerivation to bump memSize to 4096 on the derivation
# before the original runInLinuxVM reads it.  QEMU then receives
# -m 4096 instead of -m 1024.
#
# NOTE
# This overlay is injected via nixpkgs.overlays inside the NixOS
# module system, NOT as a flake-level package overlay.  It lives in
# src/nixos/overlays/modules/ and is wired into nixosModules.default
# via src/nixos/modules/overlays/default.nix.
# ---------------------------------------------------------------------------

{
	nixpkgs.overlays = [(final: prev: {
		vmTools = prev.vmTools // {
			runInLinuxVM = drv: prev.vmTools.runInLinuxVM (
				prev.lib.overrideDerivation drv (attrs: {
					memSize = 4096;
				})
			);
		};
	})];
}
