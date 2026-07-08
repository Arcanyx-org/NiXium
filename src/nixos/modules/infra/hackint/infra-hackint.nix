{ lib, ... }:

# The Base48 Hackerspace Nix module exposing priviledged access to the infrastructure

let
	inherit (lib) mkMerge;
in mkMerge ([
	# IRCD
		{
			services.tor.settings.MapAddress = [ "guybrush.hackint.org dtlbunzs5b7s5sl775quwezleyeplxzicdoh3cnhm7feolxmkfd42nqd.onion" ];
		}
])
