{ ... }:

# Firmware management of MRACEK

{
	# FIXME-QA(Krey): I am not sure if there is any firmware that needs updating.. I stripped the system of off basically everything including breaking traces that go to unwanted mainboard components.. The assumption is that everything should be kept up-to-date as fwupd will prefer open-source firmware over proprietary and if we are updating any proprietary then it's because we don't have anything else and depend on it e.g. microcode.
	services.fwupd.enable = true; # Use FWUP daemon to keep firmware files up-to-date
}