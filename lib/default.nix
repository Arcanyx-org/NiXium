{ lib, inputs, self, ... }:

{
	imports = [
		./homeManagerModules.nix
	];

	flake.lib = {
		mkVimConfig = import ./mkVimConfig/mkVimConfig.nix;
		# mkVM is imported with lib, inputs, and self baked into its closure.
		# Call sites use: `let inherit (self.lib) mkVM; in mkVM { ... }`
		# No need to pass inputs or self — they're already in scope.
		mkVM = import ../src/nixos/lib/mkVM/lib-mkVM.nix { inherit lib inputs self; };
		# mkScript requires pkgs and stdenv which are not available in this
		# flake-parts module context.  Expose as a curried function so callers
		# in perSystem can write:
		#   let ms = self.lib.mkScript { inherit pkgs stdenv; }; in ms { ... }
		mkScript = { pkgs, stdenv }: import ../src/nixos/lib/mkScript { inherit lib pkgs stdenv; };
		# mkError only requires lib, which is available in this flake-parts context.
		# Call sites use: `throw (self.lib.mkError { what = "..."; why = "..."; how = "..."; })`
		mkError = import ../src/nixos/lib/mkError { inherit lib; };
	};
}