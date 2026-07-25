{ ... }:

# Hardware Management of TUPAC

# FIXME(Krey): This is temporary til nixware is implemented!

{
	# Compatible with tuxedo drivers assuming it uses the proprietary firware and not system76
		hardware.tuxedo-drivers.enable = true;
		hardware.tuxedo-rs.enable = true;
		hardware.tuxedo-rs.tailor-gui.enable = true;
		hardware.tuxedo-drivers.settings.charging-profile = "high_capacity";
}
