{ pkgs, ... }:

# System wakeonlan configuration

{
	# NiXium dependency needed to awaken other systems
	environment.systemPackages = [ pkgs.wakeonlan ]; # Install wakeonlan On All Systems
}
