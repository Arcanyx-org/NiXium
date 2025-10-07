{ pkgs, ... }:

# System vim configuration

{
	environment.systemPackages = [ pkgs.vim ]; # Install vim On All Systems
}
