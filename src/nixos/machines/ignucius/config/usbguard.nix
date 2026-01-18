{ lib, config, pkgs, ... }:

# USB Guard Management of IGNUCIUS

let
	inherit (lib) mkMerge mkForce mkDefault mkIf;
in mkIf config.services.usbguard.dbus.enable {
	# Rule Management
		# FIXME(Krey): This needs a management for privacy as I don't want to publish the serial numbers of the devices
		# services.usbguard.rules = builtins.concatStringsSep "\n" [
		# 	# EHCI Host Controller Authorization
		# 	''allow id 1d6b:0002 serial "0000:00:1d.0" name "EHCI Host Controller" with-interface 09:00:00 with-connect-type ""''
		# 	''allow id 1d6b:0002 serial "0000:00:1a.0" name "EHCI Host Controller" with-interface 09:00:00 with-connect-type ""''

		# 	# XHCI Host Controller Authorization
		# 	''allow id 1d6b:0002 serial "0000:00:14.0" name "xHCI Host Controller" with-interface 09:00:00 with-connect-type ""''
		# 	''allow id 1d6b:0003 serial "0000:00:14.0" name "xHCI Host Controller" with-interface 09:00:00 with-connect-type ""''

		# 	# PRIVACY(Krey): This contains serial identifier which is considered confidential
		# 	# Authorize the WWAN Card (H5321)
		# 	''allow id 0bdb:1926 serial "REDACTED" name "H5321 gw" with-interface { 02:08:00 02:02:01 0a:00:00 02:02:01 0a:00:00 02:09:01 02:0d:00 0a:00:01 0a:00:01 02:09:01 02:02:01 0a:00:00 02:08:00 02:02:01 0a:00:00 02:02:01 0a:00:00 02:09:01 02:0d:00 0a:00:01 0a:00:01 02:09:01 } with-connect-type "unknown"''

		# 	# Authorize the Biometric Coprocessor
		# 	''allow id 147e:2020 serial "" name "Biometric Coprocessor" via-port "2-1.3" with-interface ff:00:00 with-connect-type "unknown"''

		# 	# PRIVACY(Krey): This contains serial identifier which is considered confidential
		# 	# Authorize the WiFi Device
		# 	''allow id 0a5c:21e6 serial "REDACTED" name "BCM20702A0" with-interface { ff:01:01 ff:01:01 ff:01:01 ff:01:01 ff:01:01 ff:01:01 ff:01:01 ff:ff:ff fe:01:01 } with-connect-type "unknown"''

		# 	# Authorize the camera
		# 	''allow id 5986:02d2 serial "" name "Integrated Camera" via-port "2-1.6" with-interface { 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 } with-connect-type "unknown"''
		# ];

		# Temporary less transparent management
		age.secrets.ignucius-usbguard-config = {
				file = ../secrets/ignucius-usbguard-config.age;

				owner = "root";
				group = "root";

				# path = "${config.services.usbguard.ruleFile}";

				symlink = true;
			};
		services.usbguard.ruleFile = config.age.secrets.ignucius-usbguard-config.path;

	# SECURITY(Krey): Enforce to use the rules file on currently connected devices
	services.usbguard.presentDevicePolicy = mkForce "apply-policy";
	services.usbguard.presentControllerPolicy = mkForce "apply-policy";
	services.usbguard.insertedDevicePolicy = mkForce "apply-policy";

	# SECURITY(Krey): Block All Devices That Do Not Match The Rules
	services.usbguard.implicitPolicyTarget = mkForce "block";

	# FIXME-QA(Krey): Outsource to global configuration
	# SECURITY(Krey): User Groups that are allowed to do IPC calls
	services.usbguard.IPCAllowedGroups = [ "wheel" ];
}
