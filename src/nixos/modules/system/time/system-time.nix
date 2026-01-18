{ self, lib, ... }:

# Time Management Module

let
	inherit (lib) mkDefault;
in {
	time.timeZone = mkDefault "UTC"; # Use UTC by default
}
