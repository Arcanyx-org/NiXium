{ pkgs, ... }:

{
	environment.systemPackages = [
		pkgs.vulkan-tools
	];
}
