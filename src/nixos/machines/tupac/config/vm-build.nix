{ ... }:

# VM configuration of TUPAC, used for testing prior to deployment

{
	# FIXME(Krey): Neither of those are working right now, see https://github.com/nix-community/disko/issues/668
	virtualisation = {
		# build-vm
		vmVariant = {
			virtualisation = {
				memorySize = 1024 * 2;
				cores = 2;
			};
		};

		# build-vm-with-bootloader
		vmVariantWithBootLoader = {
			virtualisation = {
				memorySize = 1024 * 2;
				cores = 2;
			};
		};
	};
}
