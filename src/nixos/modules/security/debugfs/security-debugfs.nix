{ lib, ... }:

# Restrict debugfs and tracefs to root-only
# debugfs exposes kernel internals (tracing data, process names, kernel addresses)
# which is a security information leak if world-readable.
# trace_options=noautouser handles non-root restriction at the kernel level;
# this service enforces permissions at the filesystem level.

let
	inherit (lib) concatStringsSep;
in {
	systemd.services.restrict-debugfs = {
		description = "Restrict debugfs/tracefs permissions to root-only";
		wantedBy = [ "multi-user.target" ];
		serviceConfig.Type = "oneshot";
		script = concatStringsSep "\n" [
			''chmod 0700 /sys/kernel/debug /sys/kernel/tracing''
		];
	};
}