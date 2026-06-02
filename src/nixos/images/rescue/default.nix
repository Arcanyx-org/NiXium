{ inputs, self, ... }:

###! NiXium Rescue Image
###!
###! Minimal NixOS ISO for system recovery. Boots entirely into RAM (copytoram),
###! enables wireless networking, and exposes an SSH daemon for remote access.
###!
###! Default platform: x86_64-linux (overridable via nixpkgs.hostPlatform).
###!
###! SSH Access:
###!   Host: <ip>
###!   User: root
###!   Password: 000000
###!   Key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve
###!
###! # Formats
###!
###! Physical media:
###!   iso             — Bootable ISO image (CD/USB)
###!   iso-installer   — NixOS installer ISO
###!   sd-card         — SD card image (ARM only)
###!   kexec           — Minimal netboot/kexec image
###!
###! Virtual machines:
###!   qemu            — QEMU disk image (BIOS)
###!   qemu-efi        — QEMU disk image (UEFI)
###!   raw             — Raw disk image (BIOS)
###!   raw-efi         — Raw disk image (UEFI)
###!   virtualbox      — VirtualBox VDI image
###!   vagrant-virtualbox — Vagrant box for VirtualBox
###!   vmware          — VMware VMDK image
###!   hyperv          — Hyper-V VHDX image
###!
###! Cloud:
###!   amazon          — AWS EC2 AMI
###!   azure           — Microsoft Azure VHD
###!   cloudstack      — Apache CloudStack
###!   digital-ocean   — DigitalOcean image
###!   google-compute  — Google Compute Engine image
###!   linode          — Linode image
###!   oci             — Oracle Cloud Infrastructure
###!   openstack       — OpenStack QCOW2
###!   openstack-zfs   — OpenStack QCOW2 with ZFS
###!
###! Containers:
###!   lxc             — LXC container tarball
###!   lxc-metadata    — LXC metadata only
###!   proxmox         — Proxmox VE image
###!   proxmox-lxc     — Proxmox LXC container
###!   kubevirt        — KubeVirt (Kubernetes VMs)
###!
###! # Usage
###!
###! nix build '.#nixosConfigurations.nixos-rescue.config.system.build.images.<format>'
###!
###! # Override architecture
###!
###!   flake.nixosConfigurations."nixos-rescue-aarch64" = inputs.nixpkgs.lib.nixosSystem {
###!     modules = [
###!       self.nixosModules."nixos-rescue"
###!       { nixpkgs.hostPlatform = "aarch64-linux"; }
###!     ];
###!   };

{
	flake.nixosModules."nixos-rescue" = { lib, pkgs, ... }: {
		imports = [
			"${inputs.nixpkgs}/nixos/modules/image/images.nix"
		];

		nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

		boot.loader.timeout = lib.mkForce 0;

		boot.kernelParams = [
			"copytoram"
		];

		environment.systemPackages = [
			pkgs.git
			pkgs.cryptsetup
		];

		nix.settings.experimental-features = "nix-command flakes";

		services.getty.greetingLine = ''<<< Welcome To The NiXium Rescue >>>'';

		hardware.enableRedistributableFirmware = true;
		nixpkgs.config.allowUnfree = true;

		networking.wireless.enable = true;

		system.stateVersion = lib.versions.majorMinor lib.version;

		networking.hostName = "nixium-rescue";

		services.sshd.enable = true;
		users.users.root.openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzh6FRxWUemwVeIDsr681fgJ2Q2qCnwJbvFe4xD15ve kreyren@fsfe.org"
		];
		users.users.root.password = "000000";
	};

	flake.nixosConfigurations."nixos-rescue" = inputs.nixpkgs.lib.nixosSystem {
		modules = [ self.nixosModules."nixos-rescue" ];
	};

	# Special case that requires i686 bootloader
		flake.nixosModules."nixos-rescueI686Boot" = {
			imports = [ self.nixosModules."nixos-rescue" ];
			boot.loader.grub.forcei686 = true;
		};

		flake.nixosConfigurations."nixos-rescueI686Boot" = inputs.nixpkgs.lib.nixosSystem {
			modules = [ self.nixosModules."nixos-rescue32Boot" ];
		};
}
