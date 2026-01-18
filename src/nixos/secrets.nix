# Standalone ragenix secret declaration

let
	# Users
	kreyren = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve";
	kira = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWLIYYAXRUD0+bg5CXsxh9F4spvqCz4jaxvtGMsezl/";

	all-users = [
		kreyren
		kira
	];

	# Systems
	flexy-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSY5vNrQFfnDqBOqse2AHSWY1hIIpZWiBYTdQEIYnV9";
	hana-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZ2SsM9PkGXuiulbEFSRJhcs1Vq20L+4pr7DRRFxreb";
	ignucius-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWL1P+3Bg7rr3NEW2h0I1bXBZtwCpU3IiruewsUQrcg";
	lengo-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVORJbikrudevtNrK023PsAIRIBfQb1xJmmnSiizalR";
	morph-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJh5Bd1p4GGCAvNkfoWoflrRIFnoj43b2aMs0GxmULs";
	mracek-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8d9Nz64gE+x/+Dar4zknmXMAZXUAxhF1IgrA9DO4Ma";
	sinnenfreude-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAXnS4xUPWwjBdKDvvy5OInLbs3oeHUUs5qUsX+fBji";
	tsvetan-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdqMVQ3TO5ckmk9nepAY/7zLHy555EkzBJxpfTIwuT5";
	tupac-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpbUbuXYWfIdh4w3FI++1/1Zwhg/ow/FVr8r2kC1bhL";
	twinkcentral-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcHEgNyhsjEHGaRXKuKopjSgthEn831KGnAXc0c/fLV";

	all-systems = [
		flexy-system
		hana-system
		ignucius-system
		lengo-system
		morph-system
		mracek-system
		sinnenfreude-system
		tupac-system
		twinkcentral-system
	];
in {
	# Kreyren (user)
	"./users/users/kreyren/kreyren-user-password.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./users/users/kreyren/home/secrets/kreyren-wireproxy-protonvpn-config.age".publicKeys = [
		kreyren
	];

	"./users/users/kreyren/home/secrets/kreyren-github-access-token.age".publicKeys = [
		kreyren
	];

	# Kira (user)
	"./users/users/kira/kira-user-password.age".publicKeys = [
		kreyren kira
	] ++ all-systems;

	"./users/users/kira/home/modules/vpn/kira-wireproxy-protonvpn-config.age".publicKeys = [
		kira kreyren tupac-system
	];

	# FLEXY (system)
	"./machines/flexy/secrets/flexy-disks-password.age".publicKeys = [
		kreyren flexy-system
	];

	"./machines/flexy/secrets/flexy-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/flexy/secrets/flexy-ssh-ed25519-private.age".publicKeys = [
		kreyren flexy-system
	];

	"./machines/flexy/secrets/flexy-onion-openssh-private.age".publicKeys = [
		kreyren flexy-system
	];

	"./machines/flexy/secrets/flexy-builder-ssh-ed25519-private.age".publicKeys = [
		kreyren flexy-system
	];

	# HANA (system)
	"./machines/hana/secrets/hana-disks-password.age".publicKeys = [
		kreyren hana-system
	];

	"./machines/hana/secrets/hana-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/hana/secrets/hana-ssh-ed25519-private.age".publicKeys = [
		kreyren hana-system
	];

	"./machines/hana/secrets/hana-onion-openssh-private.age".publicKeys = [
		kreyren hana-system
	];

	"./machines/hana/secrets/hana-builder-ssh-ed25519-private.age".publicKeys = [
		kreyren hana-system
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

	"./machines/lengo/secrets/lengo-unlock-key.age".publicKeys = [
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

	"./machines/lengo/secrets/lengo-bios-pw.age".publicKeys = [
		kreyren kira
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

	"./machines/morph/secrets/morph-openssh-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/morph/secrets/morph-ssh-ed25519-private.age".publicKeys = [
		kreyren morph-system
	];

	"./machines/morph/secrets/morph-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	# MRACEK (system)
	"./machines/mracek/secrets/mracek-disks-password.age".publicKeys = [
		kreyren mracek-system
	];

		"./machines/mracek/secrets/mracek-unlock-key.age".publicKeys = [
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

	## Nextcloud
		"./machines/mracek/secrets/mracek-onion-nextcloud-private.age".publicKeys = [
			kreyren mracek-system
		];

		"./machines/mracek/secrets/mracek-nextcloud-admin-pw.age".publicKeys = [
			kreyren mracek-system
		];

		"./machines/mracek/secrets/mracek-nextcloud-ssl-cert.age".publicKeys = [
			kreyren mracek-system
		];

		"./machines/mracek/secrets/mracek-nextcloud-onion.age".publicKeys = [
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

	"./machines/lengo/secrets/tupac-unlock-key.age".publicKeys = [
		kreyren tupac-system
	];

	# TWINKCENTRAL (system)
	"./machines/twinkcentral/secrets/twinkcentral-builder-ssh-ed25519-private.age".publicKeys = [
		kreyren twinkcentral-system
	];

	"./machines/twinkcentral/secrets/twinkcentral-disks-password.age".publicKeys = [
		kreyren twinkcentral-system
	];

	"./machines/twinkcentral/secrets/twinkcentral-onion-openssh-private.age".publicKeys = [
		kreyren twinkcentral-system
	];

	"./machines/twinkcentral/secrets/twinkcentral-openssh-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	"./machines/twinkcentral/secrets/twinkcentral-ssh-ed25519-private.age".publicKeys = [
		kreyren twinkcentral-system
	];

	"./machines/twinkcentral/secrets/twinkcentral-onion.age".publicKeys = [
		kreyren
	] ++ all-systems;

	# WiFi
	"./modules/system/wifi/homeBaseKreyren-WiFi-PSK.age".publicKeys = [
		kreyren kira
	] ++ all-systems;


	# Base48
	## Website
	"./secrets/b48-website-mapAddress.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	## Home Assistant
	"./secrets/b48-home-assistant-mapAddress.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	## FDM Printer Charlotte
	"./secrets/b48-fdm-printer-charlotte-auth.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	"./secrets/b48-fdm-printer-charlotte-mapAddress.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	## FDM Printer Ondrej
	"./secrets/b48-fdm-printer-ondrej-auth.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	"./secrets/b48-fdm-printer-ondrej-mapAddress.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	## FDM Printer Plague
	"./secrets/b48-fdm-printer-plague-auth.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	"./secrets/b48-fdm-printer-plague-mapAddress.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	## FDM Printer Vidi
	"./secrets/b48-fdm-printer-vidi-auth.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	"./secrets/b48-fdm-printer-vidi-mapAddress.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	## FDM Printer Wine
	"./secrets/b48-fdm-printer-wine-auth.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	"./secrets/b48-fdm-printer-wine-mapAddress.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	## Paper Printer
	"./secrets/b48-paper-printer-auth.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
	"./secrets/b48-paper-printer-mapAddress.age".publicKeys = [
		kreyren tupac-system sinnenfreude-system
	];
}
