{ config, pkgs, lib, unstable, ... }:

# Hardware management of LENGO

let
	inherit (lib) mkForce mkIf;
in {
	# Rotate screen
		boot.kernelParams = [
			"fbcon=rotate:3" # Rotate screen on landscape
			"amdgpu.ppfeaturemask=0xffffffff" # Enable overclocking
		];

	# Make sure that the controllers have the correct permissions
		#? [  +0.018043] input: Lenovo Legion Controller for Windows as /devices/pci0000:00/0000:00:08.1/0000:c2:00.3/usb1/1-3/1-3:1.0/input>
		#? [  +0.147181] usb 1-3: New USB device found, idVendor=17ef, idProduct=6182, bcdDevice= 1.00
		#? [  +0.000015] usb 1-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
		#? [  +0.000006] usb 1-3: Product: Legion Controller for Windows
		#? [  +0.028101] input:   Legion Controller for Windows  Touchpad as /devices/pci0000:00/0000:00:08.1/0000:c2:00.3/usb1/1-3/1-3:1.1/>
		services.udev.extraRules = builtins.concatStringsSep "\n" [
			"ACTION==\"add\", ATTRS{idVendor}==\"17ef\", ATTRS{idProduct}==\"6182\", RUN+=\"/sbin/modprobe xpad\" RUN+=\"/bin/sh -c 'echo 17ef 6182 > /sys/bus/usb/drivers/xpad/new_id'\""
		];

	# Overclocking
		# FIXME(Krey): Move this back on stable once stabilized, meaning that the version that has support for APUs is in stable
		systemd.services.lactd = {
			wantedBy = [ "multi-user.target" ];
			after = [ "multi-user.target" ];
			description = "AMDGPU Control Daemon";
			serviceConfig = {
				ExecStart = "${unstable.lact}/bin/lact daemon";
			};
		};
		environment.systemPackages = [ unstable.lact ];
}
