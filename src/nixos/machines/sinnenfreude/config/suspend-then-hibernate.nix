{ config, pkgs, ... }:

# Module that implements suspend-then-hibernate for SINNENFREUDE
# * https://gist.githubusercontent.com/mattdenner/befcf099f5cfcc06ea04dcdd4969a221/raw/14d15f8c634dc4cf28b41e76c7924979f35463ea/suspend-and-hibernate.nix
#

let
	hibernateEnvironment = {
		HIBERNATE_SECONDS = "120"; # 2 Min
		HIBERNATE_LOCK = "/var/run/autohibernate.lock";
		HIBERNATE_LOG = "/var/log/autohibernate.log";
	};
in {
	services.logind = {
		lidSwitch = "suspend-then-hibernate";
		lidSwitchExternalPower = "suspend";
	};

	systemd.services."awake-after-suspend-for-a-time" = {
		description = "Sets up the suspend so that it'll wake for hibernation";
		wantedBy = [ "suspend.target" ];
		before = [ "systemd-suspend.service" ];
		environment = hibernateEnvironment;
		script = ''
			# If suspended on battery power..
			if [ "$(cat /sys/class/power_supply/BAT0/power_now)" != 0 ]; then
				curtime=$(date +%s)
				echo "$curtime $1" >> "$HIBERNATE_LOG"
				echo "$curtime" > "$HIBERNATE_LOCK"
				${pkgs.utillinux}/bin/rtcwake -m no -s "$HIBERNATE_SECONDS"
			else
				echo "$curtime: System is on AC power, skipping wake-up scheduling for hibernation." >> "$HIBERNATE_LOG"
			fi
		'';
		serviceConfig.Type = "simple";
	};

	systemd.services."hibernate-after-recovery" = {
		description = "Hibernates after a suspend recovery due to timeout";
		wantedBy = [ "suspend.target" ];
		after = [ "systemd-suspend.service" ];
		environment = hibernateEnvironment;
		script = ''
			curtime="$(date +%s)"
			sustime="$(cat "$HIBERNATE_LOCK")"
			rm "$HIBERNATE_LOCK"
			if [ "$(($curtime - $sustime))" -ge "$HIBERNATE_SECONDS" ] ; then
				systemctl hibernate
			else
				${pkgs.utillinux}/bin/rtcwake -m no -s 1
			fi
		'';
		serviceConfig.Type = "simple";
	};
}
