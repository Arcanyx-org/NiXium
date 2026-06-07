{ lib, pkgs, ... }:

# Override make_ext4fs with an mke2fs wrapper to fix inode exhaustion.
#
# make_ext4fs (2017 Android tool) has a hardcoded ~16,384 bytes/inode ratio,
# yielding ~613,200 inodes for a ~10 GB image. The enchilada closure already
# exceeds this with 634,185 files in its minimal phosh configuration, and the
# system is expected to grow significantly.
#
# Replacing the binary via nixpkgs overlay avoids touching mobile-nixos's
# internal buildPhases submodule options (which trigger evaluation-order
# issues when set from an outer NixOS module). The wrapper is transparent to
# mobile-nixos's ext4.nix copyPhase — it accepts the same flags and delegates
# to mke2fs with -i 4096, giving ~2.4M inodes for the same image size.

let
	inherit (lib) concatStringsSep;

	# Drop-in replacement: translates make_ext4fs args to mke2fs -i 4096.
	# make_ext4fs interface: [-b blocksize] [-l size] [-U uuid] [-L label] output source_dir
	# mke2fs interface:      -t ext4 [-b blocksize] -i 4096 [-U uuid] [-L label] -d source_dir output
	make_ext4fs_compat = pkgs.writeShellApplication {
		name = "make_ext4fs";
		runtimeInputs = [ pkgs.e2fsprogs ];
		text = concatStringsSep "\n" [
			''blocksize=4096''
			''uuid=""''
			''label=""''
			''''
			''while getopts "b:l:U:L:" opt; do''
			''  case "$opt" in''
			''    b) blocksize="$OPTARG" ;;''
			''    l) : ;; # size already applied by allocationPhase truncate''
			''    U) uuid="$OPTARG" ;;''
			''    L) label="$OPTARG" ;;''
			''    *) : ;;''
			''  esac''
			''done''
			''shift $(( OPTIND - 1 ))''
			''''
		''output_file="$1"''
		''source_dir="$2"''
		''''
		''# allocationPhase uses 'truncate -s $size' where $size is computed via''
		''# integer bash arithmetic and may not be 4096-aligned. A non-aligned file''
		''# produces a trailing skip chunk whose size is not a multiple of 4096,''
		''# which fastboot's sparse conversion rejects. Align up before mke2fs so''
		''# the resulting image is block-aligned end-to-end.''
		''actual_size=$(stat -c %s "$output_file")''
		''aligned_size=$(( (actual_size + 4095) / 4096 * 4096 ))''
		''[ "$actual_size" -eq "$aligned_size" ] || truncate -s "$aligned_size" "$output_file"''
		''''
		''mke2fs_args=(-t ext4 -b "$blocksize" -i 4096 -O "^64bit,^metadata_csum")''
		''[ -n "$uuid" ] && mke2fs_args+=(-U "$uuid")''
		''[ -n "$label" ] && mke2fs_args+=(-L "$label")''
		''mke2fs_args+=(-d "$source_dir" "$output_file")''
		''''
		''mke2fs "''${mke2fs_args[@]}"''
		];
	};
in {
	nixpkgs.overlays = [
		(_: _: { make_ext4fs = make_ext4fs_compat; })
	];
}
