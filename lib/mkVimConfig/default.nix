{ lib, ... }:

# flake-parts module: exposes mkVimConfig on flake.lib.mkVimConfig
#
# This makes mkVimConfig available as self.lib.mkVimConfig throughout the
# flake.  Consumers (e.g. home-manager modules) that receive `self` via
# specialArgs can call:
#
#   let mkVimConfig = self.lib.mkVimConfig pkgs;
#   in mkVimConfig { content = "..."; name = "my-config"; }
#
# The function is curried: first argument is `pkgs`, second is the
# { content, name } attrset.  This mirrors the convention used by
# pkgs.writeShellApplication: the builder function lives in the library
# and is specialised to a particular pkgs when called.

{
	flake.lib.mkVimConfig = import ./mkVimConfig.nix;
}
