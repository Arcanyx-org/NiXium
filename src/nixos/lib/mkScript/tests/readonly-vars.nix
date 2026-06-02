{ lib, pkgs, stdenv }:
let
	ms = import ../lib-mkScript.nix { inherit lib pkgs stdenv; };
in
	ms.mkScript {
		name = "test-readonly";
		text = "echo 'checking vars'";
		readonlyVars = [ "PATH" "SHELL" "MY_READONLY_VAR" ];
	}
