{ pkgs, ... }:

# System htop configuration

{
	environment.systemPackages = [ pkgs.htop ]; # Install htop On All Systems
}
