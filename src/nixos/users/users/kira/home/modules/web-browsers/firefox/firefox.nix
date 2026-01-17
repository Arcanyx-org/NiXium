{ config, lib, ... }:

# Kira's Firefox Configuration

let
	inherit (lib) mkIf;
in mkIf config.programs.firefox.enable {
}
