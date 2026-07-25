{ pkgs, ... }:

# Kexec - Kernel live-patching support
# Provides kexec-tools for the system-level `kexec` administration task.
# Allows switching kernels without firmware re-initialization (preserves LUKS).

{
	environment.systemPackages = [ pkgs.kexec-tools ];
}
