{ self, ... }:

{
	imports = [
		./nixos
	];

	# Distro-agnostic machine aliases
	# Maps machine name to its NixOS configuration (e.g., tupac -> nixos-tupac)
	# In the future, non-NixOS distros could be supported by pointing these at different configurations
	flake.nixosConfigurations = {
		tupac = self.nixosConfigurations."nixos-tupac";
		lengo = self.nixosConfigurations."nixos-lengo";
		mracek = self.nixosConfigurations."nixos-mracek";
		sinnenfreude = self.nixosConfigurations."nixos-sinnenfreude";
		twinkcentral = self.nixosConfigurations."nixos-twinkcentral";
		ignucius = self.nixosConfigurations."nixos-ignucius";
		enchilada = self.nixosConfigurations."nixos-enchilada";
	};
}
