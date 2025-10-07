{ lib, ... }:

# Global Environment Management

let
	inherit (lib) mkDefault;
in {
	environment.localBinInPath = mkDefault true; # Include ~/.local/bin in PATH
}
