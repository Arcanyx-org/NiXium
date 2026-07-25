{ config, lib, ... }:

# SCAR-specific configuration of Sunshine

let
	inherit (lib) mkIf;
in mkIf config.services.sunshine.enable {
	services.sunshine.capSysAdmin = true; # Assign CAP_SYS_ADMIN for DRM/KMS screen capture
	services.sunshine.openFirewall = true; # Open Firewall for local network

	# Low latency encoding for game streaming — protected from OOM (critical for active sessions)
	services.ananicy.extraRules = [
		{ name = "sunshine"; type = "Streaming-Server"; oom_score_adj = -900; }
	];
}
