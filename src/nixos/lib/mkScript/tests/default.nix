{ lib, pkgs, stdenv }:
let
	ms = import ../lib-mkScript.nix { inherit lib pkgs stdenv; };
in
	{
		basic = ms.mkScript {
			name = "test-basic";
			text = "echo 'hello world'";
		};
		hooks = import ./hooks.nix { inherit lib pkgs stdenv; };
		overrideNoReason = import ./override-no-reason.nix { inherit lib pkgs stdenv; };
		overrideWithReason = import ./override-with-reason.nix { inherit lib pkgs stdenv; };
		readonlyVars = import ./readonly-vars.nix { inherit lib pkgs stdenv; };
	}
