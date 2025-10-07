{ config, lib, pkgs, ... }:

# Global configuration of monero

let
	inherit (lib) mkIf;

	builder-account = "builder";
	builder-group = "builder";
in mkIf config.nix.distributedBuilds {
	# Setup the builder user
		users.groups."${builder-group}" = {}; # Create 'builder' user group

		# Add the builder user
			users.users."${builder-account}" = {
				description = "User used for distributed builds on nixium";
				uid = 5000;
				isNormalUser = true;
				createHome = true; # Do Not Create the home for the user
				group = builder-group;
			};

		# Authorize the builder user in the nix daemon
			# NOTE-SECURITY(Krey): Avoid the use of `trusted-users` as those can set up additional binary cache and import **UNSIGNED** nars, in case the system gets compromised this would be a liability where `allowed-users` address this issue
			# NOTE-SECURITY(The Future Krey): Complaines about trusted keys unless it's in `trusted-users`, investigate whether this is a good idea or if there is a more reasonable way around it
			# nix.settings.allowed-users = [ builder-account ]; # Add builder in the allowed users
			nix.settings.trusted-users = [ builder-account ]; # Add builder in the trusted users
}
