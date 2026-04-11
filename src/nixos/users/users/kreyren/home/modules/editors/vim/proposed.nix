{ self, builtins, lib, ... }:

let
	inherit (lib) mkMerge concatStringsSep writeShellApplication;
	inherit (self."...") mkVMGraphicalWayland mkVMMinimal mkVMGraphicalXorg;
in mkMerge [
	{
		flake.homeManagerModules.editors-vim-kreyren = ./vim.nix;
	}

	{
		# mkVMGraphicalWayland is meant to open auto-login cage for wayland session
		apps.nixos-home-editors-vim-kreyren-graphicalWaylandVM = mkVMGraphicalWayland {
			# FIXME(Krey): This should ideally just be optional and not be needed as it should just use reuse the name of the call..
				name = "nixos-home-editors-vim-kreyren-vm";
			modules = [
				self.nixosModules.default
				{
					home-manager = {
						users.kreyren = {
							imports = [
								self.homeManagerModules.editors-vim-kreyren
							];
							programs.vim.enable = true;
						};
					};

					# Test user configuration
					users.users.kreyren = {
						description = "Kreyren";
						uid = 1000;
						isNormalUser = true;
						createHome = true;
						password = "000000"; # Intentionally simple for test VM
					};
				}
			];
			# DESIGN(Krey): This is meant to be able to replace the content of apps."...".program.text with ability to suffix, prefix and supplement before the qemu command maybe? No idea how to implement this in flexbile way.. Maybe:
			# * Leaving program blank -> Default behavior
			# * `program = writeShellApplication "..." ++ default;` or `program = defailt ++ writeShellApplication "...";` somehow.. to be able to prefix before the whole script and suffix, but before the qemu command.
			program = writeShellApplication "...";
		};
	}

	{
		# FIXME(Krey): Implement mkVMMinimal that just opens in the CLI without graphical support
	}

	{
		# FIXME(Krey): Implement mkVMGraphicalXorg that implements Xorg
	}
]
