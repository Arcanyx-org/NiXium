{ self, config, lib, ... }:

# Mracek-specific configuration of MurMur (Mumble)

let
	inherit (lib) mkIf;
in mkIf config.services.murmur.enable {
	# Import the private key for an onion service
	age.secrets.mracek-onion-murmur-private = {
		file = ../../secrets/mracek-onion-murmur-private.age;

		owner = "tor";
		group = "tor";

		path = "/var/lib/tor/onion/murmur/hs_ed25519_secret_key";

		symlink = false; # Appears to not work as symlink
	};

	# Configuration
		# MurMur lets us set environmental file which values are then available via $VARIABLE in configuration to be used for secrets
		# services.murmur.environmentFile =

		# services.murmur.hostName = "murmur.nx";

		services.murmur.sendVersion = false; # Send Murmur version in UDP Packets

		services.murmur.users = 100; # Maximum number of concurrent clients allowed

		services.murmur.textMsgLength = 54; # Max length of text messages. Set 0 for no limit

		services.murmur.logDays = -1; # How long to store RPC logs for in the database. Set 0 to keep logs forever, or -1 to disable DB logging

		services.murmur.bandwidth = 72000; # Maximum bandwidth (in bits per second) that clients may send speech at.

		# Extra Configuration
		# https://www.mumble.info/documentation/administration/config-file/
		# https://github.com/mumble-voip/mumble/blob/master/auxiliary_files/mumble-server.ini
		services.murmur.extraConfig = builtins.concatStringsSep "\n" [
			"serverpassword=theMurMuring"

			# Setting to true exposes the current user count, the maximum user count, and the server's maximum bandwidth per client to unauthenticated users. In the Mumble client, this information is shown in the Connect dialog.
				"allowping=false"

			# Regular Expressions
				"channelname=[ \\-=\\w\\#\\[\\]\\{\\}\\(\\)\\@\\|]+" # Allowed Channel Names
				"username=[-=\\w\\[\\]\\{\\}\\(\\)\\@\\|\\.]+" # Allowed UserNames

			# Require registrations
				"certrequired=false" # Whether to only allow clients with a certificate

			# Welcome Text
				"welcometextfile=${./welcome-text.html}"

			# User Recording
				# NOTE-PRIVACY(Krey): Anyone can record the conversations using a 3rd party software such as OBS which we have no option to manage so disabling this doesn't make much sense considering that it will announce to all users that it's recording to be more transparant option
				"allowRecording=true" # Whether to allow the clients to start recording on the server

			# No Logging
				"rememberchannel=false" # Do not save channels per clients

				"listenersperchannel=0" # Disable Channel Listeners

				"listenersperuser=0" # Disable User Listeners

				# FIXME(Krey): This causes the server to fail to load
					# "logfile=/dev/null"

				# By default, in log files and in the user status window for privileged users, Mumble will show IP addresses - in some situations you may find this unwanted behavior. If obfuscate is set to true, the server will randomize the IP addresses of connecting users.
				#
				# The obfuscate function only affects the log file and DOES NOT effect the user information section in the client window.
				"obfuscate=true"

			# SSL
				# NOTE(Krey): Currently we are letting murmur generate it's own certificate
				# "sslCert="
				# "sslKey="

				# If the keyfile specified above is encrypted with a passphrase, you can enter it in this setting. It must be plaintext, so you may wish to adjust the permissions on your mumble-server.ini file accordingly.
				# "sslPassPhrase="

				# If your certificate is signed by an authority that uses a sub-signed or "intermediate" certificate, you probably need to bundle it with your certificate in order to get the server to accept it. You can either concatenate the two certificates into one file, or you can put it in a file by itself and put the path to that PEM-file in sslCA.
				# "sslCA="

				# The sslDHParams option allows you to specify a PEM-encoded file with Diffie-Hellman parameters, which will be used as the default Diffie-Hellman parameters for all virtual servers.
				#
				# Instead of pointing sslDHParams to a file, you can also use the option to specify a named set of Diffie-Hellman parameters for the server to use.
				# The server comes bundled with the Diffie-Hellman parameters from RFC 7919.
				# These parameters are available by using the following names:
				#
				# @ffdhe2048, @ffdhe3072, @ffdhe4096, @ffdhe6144, @ffdhe8192
				#
				# By default, the server uses @ffdhe2048.
				# "sslDHParams=@ffdhe2048"

				# The sslCiphers option chooses the cipher suites to make available for use in SSL/TLS. This option is server-wide, and cannot be set on a per-virtual-server basis.
				#
				# This option is specified using OpenSSL cipher list notation (see https://www.openssl.org/docs/apps/ciphers.html#CIPHER-LIST-FORMAT).
				#
				# It is recommended that you try your cipher string using 'openssl ciphers <string>' before setting it here, to get a feel for which cipher suites you will get.
				#
				# After setting this option, it is recommend that you inspect your server log to ensure that the server is using the cipher suites that you expected it to.
				#
				# Note: Changing this option may impact the backwards compatibility of your server, and can remove the ability for older Mumble clients to be able to connect to it.
				# "sslCiphers=EECDH+AESGCM:EDH+aRSA+AESGCM:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:AES256-SHA:AES128-SHA"
		];

	# The Onion Service
	services.tor.relay.onionServices."murmur" = {
		map = mkIf config.services.tor.enable [ config.services.murmur.port ]; # Set up Onionized Murmur
	};
}
