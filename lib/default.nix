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
		mkVM = import ../src/nixos/lib/mkVM { inherit lib inputs self; };
	};
}