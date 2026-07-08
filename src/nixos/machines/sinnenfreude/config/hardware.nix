{ pkgs, lib, ... }:

# Hardware-specific fixes for SINNENFREUDE

let
	inherit (lib) concatStringsSep;
	in {
	# Acer laptop keyboard sends phantom scancode 0x7c during boot (6x in dmesg).
	# No physical key maps to this — it's a BIOS/keyboard controller POST artifact.
	# Map it to KEY_RESERVED (0) to suppress "Unknown key released" warnings.
	services.udev.extraRules = concatStringsSep "\n" [
		''ACTION=="add", SUBSYSTEM=="input", ATTRS{phys}=="isa0060/serio0/input0", RUN+="${pkgs.kbd}/bin/setkeycodes 7c 0"''
	];

	# FIX: Console keymap maps keycode 107 (KEY_END) to "Select" instead of "End"
	# This causes the End key to not move cursor to end-of-line in terminal.
	# Root cause: US console keymap has keycode 107 = Select (a legacy SysRq mapping).
	# Fix: Override keycode 107 to emit the correct End escape sequence (\EOF).
	#
	# Verified with evtest: scancode 0xcf → KEY_END (code 107) is correctly
	# detected by the kernel. The bug is in the keymap translation layer.
	# loadkeys on NixOS 26.05 can't handle gzipped files in include directives
	# Decompress the full US keymap and append the override
	console.keyMap = pkgs.runCommand "us-fixed-end.kmap" { nativeBuildInputs = [ pkgs.gzip ]; } ''
		${pkgs.gzip}/bin/gunzip -c ${pkgs.kbd}/share/keymaps/i386/qwerty/us.map.gz > "$out"
		echo 'keycode 107 = End' >> "$out"
	'';
}