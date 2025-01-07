# Standalone ragenix secret declaration

let
	# Users
	kreyren = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve";
	kira = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWLIYYAXRUD0+bg5CXsxh9F4spvqCz4jaxvtGMsezl/";

	# Systems
	ignucius-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWL1P+3Bg7rr3NEW2h0I1bXBZtwCpU3IiruewsUQrcg";
	morph-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJh5Bd1p4GGCAvNkfoWoflrRIFnoj43b2aMs0GxmULs";
	mracek-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8d9Nz64gE+x/+Dar4zknmXMAZXUAxhF1IgrA9DO4Ma";
	sinnenfreude-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAXnS4xUPWwjBdKDvvy5OInLbs3oeHUUs5qUsX+fBji";
	tsvetan-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdqMVQ3TO5ckmk9nepAY/7zLHy555EkzBJxpfTIwuT5";
	tupac-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmYpmNkpSkSSk1FnxHvPb8JlbeYh2lf3d5u8MBqGpHP";
	lengo-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOWBw3MYmx7bTJPBKd51kFxXXSJDJEenLKR2R55VkwDU";

	all-systems = [
		ignucius-system
		lengo-system
		morph-system
		mracek-system
		sinnenfreude-system
		tupac-system
	];
in {
	# Kreyren (user)
	"./users/kreyren/kreyren-user-password.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./users/kreyren/home/modules/vpn/kreyren-wireproxy-protonvpn-config.age".publicKeys = [
		kreyren sinnenfreude-system lengo-system
	];

	# Kira (user)
	"./users/kira/kira-user-password.age".publicKeys = [
		kreyren kira
	] ++ all-systems;

	"./users/kira/home/modules/vpn/kira-wireproxy-protonvpn-config.age".publicKeys = [
		kira kreyren tupac-system
	];

	# IGNUCIUS (system)
	"./machines/ignucius/secrets/ignucius-disks-password.age".publicKeys = [
		kreyren ignucius-system
	];

	"./machines/ignucius/secrets/ignucius-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/ignucius/secrets/ignucius-ssh-ed25519-private.age".publicKeys = [
		kreyren ignucius-system
	];

	"./machines/ignucius/secrets/ignucius-onion-openssh-private.age".publicKeys = [
		kreyren ignucius-system
	];

	"./machines/ignucius/secrets/ignucius-builder-ssh-ed25519-private.age".publicKeys = [
		kreyren ignucius-system
	];

	"./machines/ignucius/secrets/ignucius-usbguard-config.age".publicKeys = [
		kreyren ignucius-system
	];

	# LENGO (system)
	"./machines/lengo/secrets/lengo-builder-ssh-ed25519-private.age".publicKeys = [
		kreyren lengo-system
	];

	"./machines/lengo/secrets/lengo-disks-password.age".publicKeys = [
		kreyren lengo-system
	];

	"./machines/lengo/secrets/lengo-onion-openssh-private.age".publicKeys = [
		kreyren lengo-system
	];

	"./machines/lengo/secrets/lengo-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/lengo/secrets/lengo-ssh-ed25519-private.age".publicKeys = [
		kreyren lengo-system
	];

	# MORPH (system)
	"./machines/morph/secrets/morph-builder-ssh-ed25519-private.age".publicKeys = [
		kreyren morph-system
	];

	"./machines/morph/secrets/morph-disks-password.age".publicKeys = [
		kreyren morph-system
	];

	"./machines/morph/secrets/morph-onion-openssh-private.age".publicKeys = [
		kreyren morph-system
	];

	"./machines/morph/secrets/morph-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/morph/secrets/morph-ssh-ed25519-private.age".publicKeys = [
		kreyren morph-system
	];

	# MRACEK (system)
	"./machines/mracek/secrets/mracek-disks-password.age".publicKeys = [
		kreyren mracek-system
	];

	"./machines/mracek/secrets/mracek-onion-gitea-private.age".publicKeys = [
		kreyren mracek-system
	];

	"./machines/mracek/secrets/mracek-openssh-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/mracek/secrets/mracek-onion-vikunja-private.age".publicKeys = [
		kreyren mracek-system
	];

	"./machines/mracek/secrets/mracek-vikunja-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/mracek/secrets/mracek-onion-monero-private.age".publicKeys = [
		kreyren mracek-system
	];

	"./machines/mracek/secrets/mracek-gitea-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/mracek/secrets/mracek-onion-murmur-private.age".publicKeys = [
		kreyren mracek-system
	];

	"./machines/mracek/secrets/mracek-monero-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/mracek/secrets/mracek-monero-p2p-onion.age".publicKeys = [
		kreyren
	] ++ all-systems; # Onion Address for Monero's P2P Onion Service

	"./machines/mracek/secrets/mracek-onion-monero-p2p-private.age".publicKeys = [
		kreyren mracek-system
	]; # Private Key for Monero's P2P Onion Service

	"./machines/mracek/secrets/mracek-murmur-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/mracek/secrets/mracek-onion-navidrome-private.age".publicKeys = [
		kreyren mracek-system
	];

	"./machines/mracek/secrets/mracek-navidrome-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/mracek/secrets/mracek-ssh-ed25519-private.age".publicKeys = [
		kreyren mracek-system
	];

	"./machines/mracek/secrets/mracek-onion-openssh-private.age".publicKeys = [
		kreyren mracek-system
	];

	"./machines/mracek/secrets/mracek-builder-ssh-ed25519-private.age".publicKeys = [
		kreyren mracek-system
	];

	# SINNENFREUDE (system)
	"./machines/sinnenfreude/secrets/sinnenfreude-disks-password.age".publicKeys = [
		kreyren sinnenfreude-system
	];

	"./machines/sinnenfreude/secrets/sinnenfreude-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/sinnenfreude/secrets/sinnenfreude-ssh-ed25519-private.age".publicKeys = [
		kreyren sinnenfreude-system
	];

	"./machines/sinnenfreude/secrets/sinnenfreude-onion-openssh-private.age".publicKeys = [
		kreyren sinnenfreude-system
	];

	"./machines/sinnenfreude/secrets/sinnenfreude-builder-ssh-ed25519-private.age".publicKeys = [
		kreyren sinnenfreude-system
	];

	# TUPAC (system)
	"./machines/tupac/secrets/tupac-ssh-ed25519-private.age".publicKeys = [
		kreyren kira tupac-system
	];
	"./machines/tupac/secrets/tupac-disks-password.age".publicKeys = [
		kreyren kira tupac-system
	];
	"./machines/tupac/secrets/tupac-onion.age".publicKeys = [
		kreyren kira morph-system sinnenfreude-system mracek-system ignucius-system
	];
	"./machines/tupac/secrets/tupac-onion-secretKey.age".publicKeys = [
		kreyren kira tupac-system
	];
	"./machines/tupac/secrets/tupac-onion-openssh-private.age".publicKeys = [
		kreyren kira tupac-system
	];

	"./machines/tupac/secrets/tupac-builder-ssh-ed25519-private.age".publicKeys = [
		kreyren kira tupac-system
	];

	# WiFi
	"./modules/system/wifi/homeBaseKreyren-WiFi-PSK.age".publicKeys = [
		kreyren kira
	] ++ all-systems;
}
