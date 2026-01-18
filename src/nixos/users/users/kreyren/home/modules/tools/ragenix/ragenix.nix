{ nixosConfig, ... }:

{
	# Set the identity path for the decryption key
	age.identityPaths = (if nixosConfig.boot.impermanence.enable
		then [ "/nix/persist/users/kreyren/.ssh/id_ed25519" ]
		else [ "/home/kreyren/.ssh/id_ed25519" ]);
}
