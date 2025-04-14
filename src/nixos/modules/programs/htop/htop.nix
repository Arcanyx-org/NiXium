{ lib, config, pkgs, ... }:

# System htop configuration

{
	environment.systemPackages = [ pkgs.htop ]; # Install hop On All Systems
}
