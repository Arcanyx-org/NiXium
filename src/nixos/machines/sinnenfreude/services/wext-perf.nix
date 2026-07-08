{ pkgs, lib, ... }:

# perf probe to capture the process that calls deprecated wireless extensions (wext)
# The kernel message "pool-9 uses wireless extensions which will stop working for Wi-Fi 7 hardware"
# fires once at boot via WARN_ONCE. This service records the caller on next boot.
# Check with: perf script -i /var/log/wext.perf.data

let
	inherit (lib) concatStringsSep;
in {
	systemd.services.capture-wext-caller = {
		description = "Capture wireless extensions caller via perf probe";
		wantedBy = [ "multi-user.target" ];
		before = [ "network.target" ];
		serviceConfig.Type = "oneshot";
		script = concatStringsSep "\n" [
			# Set up the perf probe if not already set
			''${pkgs.perf}/bin/perf probe --del wext_handle_ioctl 2>/dev/null || true''
			''${pkgs.perf}/bin/perf probe wext_handle_ioctl 2>/dev/null || true''
			# Record for 5 minutes to catch early boot callers
			''${pkgs.perf}/bin/perf record -e probe:wext_handle_ioctl -a -o /var/log/wext.perf.data -- sleep 300''
		];
	};
}