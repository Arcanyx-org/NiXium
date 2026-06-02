{ lib, pkgs, stdenv }:
let
	ms = import ../lib-mkScript.nix { inherit lib pkgs stdenv; };
in
	ms.mkScript {
		name = "test-hooks";
		text = "echo 'hook test'";
		derivationArgs = {
			preCheck = "echo 'running preCheck'";
			postCheck = "echo 'running postCheck'";
		};
		overrideReason = "Testing hooks requirement";
	}
