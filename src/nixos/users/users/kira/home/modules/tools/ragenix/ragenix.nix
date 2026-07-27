{ nixosConfig, ... }: {
	age.identityPaths = (if nixosConfig.boot.impermanence.enable
		then [ "/nix/persist/users/kira/.ssh/id_ed25519" ]
		else [ "/home/kira/.ssh/id_ed25519" ]);
}
