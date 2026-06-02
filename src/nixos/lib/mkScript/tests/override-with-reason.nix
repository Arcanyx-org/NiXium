{ lib, pkgs, stdenv }:
let
	ms = import ../lib-mkScript.nix { inherit lib pkgs stdenv; };
in
	ms.mkScript {
		name = "test-override-reason";
		text = "echo 'hello world'";
		buildPhase = "echo 'custom build'";
		overrideReason = "Testing valid override reason";
	}
