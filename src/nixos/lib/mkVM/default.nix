{ inputs, ... }:

{
	# Flake lib export — callerSelf wires self.nixosModules/self.inputs.* from the calling flake:
	#   let inherit (nixium.lib) mkVM; in (mkVM self) { name = ...; command = ...; }
	#   External flakes supply their own self: (mkVM externalSelf) { ... }
	flake.lib.mkVM = callerSelf:
		import ./lib-mkVM.nix {
			lib  = inputs.nixpkgs.lib;
			inherit inputs;
			self = callerSelf;
		};
}
