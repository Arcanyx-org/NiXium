{ ... }:

# Configuration of the installer image

{
	# SSH
		users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org" ]; # Allow root access for all systems to KREYREN
}
