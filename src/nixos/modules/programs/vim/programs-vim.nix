{ pkgs, ... }:

# System vim configuration

{
	environment.systemPackages = [ pkgs.vim ];
}
