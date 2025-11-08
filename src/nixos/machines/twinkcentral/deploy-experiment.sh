#!/usr/bin/env sh

# Experiment

targetIP="192.168.0.174"
# targetFlake="github:Arcanyx-org/NiXium/experimental#nixos-twinkcentral-stable"
targetFlake="github:Arcanyx-org/NiXium/a94fb7522cb14bdcf1d1fe873ab9b99f2ea97e01#nixos-twinkcentral-stable"

set -e # Exit on false return

set -x # Debug

ssh "root@$targetIP" mkdir --verbose --parents  /run/agenix.d/1

ssh "root@$targetIP" ln --verbose --symbolic /run/agenix.d/1 /run/agenix # Perform the symlink

ssh "root@$targetIP" chown --verbose "root:root" "/run/agenix.d/1" # Ensure expected ownership

ssh "root@$targetIP" chmod --verbose 700 "/run/agenix.d/1" # Ensure expected permission

ssh "root@$targetIP" 'echo 000000 > /run/agenix/twinkcentral-disks-password'

ssh "root@$targetIP" 'cat > /etc/ssh/ssh_host_ed25519_key' < <(age -i ~/.ssh/id_ed25519 -d ./src/nixos/machines/twinkcentral/secrets/twinkcentral-ssh-ed25519-private.age || true)

ssh "root@$targetIP" 'chmod 400 /etc/ssh/ssh_host_ed25519_key'
ssh "root@$targetIP" 'chown root:root /etc/ssh/ssh_host_ed25519_key'

# ssh "root@$targetIP" 'cat > /key' < <(age -i ~/.ssh/id_ed25519 -d ./src/nixos/machines/twinkcentral/secrets/twinkcentral-unlock-key.age || true)

# ssh "root@$targetIP" 'dd if=/key of=/dev/disk/by-id/mmc-NCard_0x23904944 conv=sync status=progress'

# shellcheck disable=SC2029 # Expecting expansion on host
ssh "root@$targetIP" "nix --extra-experimental-features 'flakes nix-command' run github:nix-community/disko#disko -- --mode disko --root-mountpoint /mnt --debug --flake $targetFlake"

ssh "root@$targetIP" 'mount -v -o remount,size=30G,noatime /nix/.rw-store'
ssh "root@$targetIP" 'mount -v -o remount,size=10G,noatime /mnt'

ssh "root@$targetIP" "nix --extra-experimental-features 'flakes nix-command' run nixpkgs#sbctl -- create-keys"

ssh "root@$targetIP" 'mkdir -v -p /mnt/nix/persist/system/var/lib/'

ssh "root@$targetIP" 'cp -v -r /var/lib/sbctl /mnt/nix/persist/system/var/lib/sbctl'

ssh "root@$targetIP" 'mkdir -v -p /mnt/var/lib/sbctl'

ssh "root@$targetIP" 'cp -v -r /var/lib/sbctl/* /mnt/var/lib/sbctl'

ssh "root@$targetIP" 'mkdir -v -p /mnt/nix/persist/system/etc/ssh'

ssh "root@$targetIP" 'cp -v /etc/ssh/ssh_host_ed25519_key /mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key'

ssh "root@$targetIP" 'chmod --verbose 400 /mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key' # Ensure correct permission

nix copy --to ssh://root@$targetIP "$(nix build "${targetFlake//#*/}#nixosConfigurations.\"nixos-twinkcentral-stable\".config.system.build.toplevel" --print-out-paths || true)"

# shellcheck disable=SC2029 # Expecting expansion on host
ssh "root@$targetIP" "nix --extra-experimental-features 'flakes nix-command' shell nixpkgs#nixos-install-tools --command nixos-install --verbose --root /mnt --flake $targetFlake"

ssh "root@$targetIP" reboot

while [ "$(ssh "root@$targetIP" echo "booted" || true)" != "booted" ]; do
	sleep 5
done

# FIXME(Krey): Change known hosts

# Has to be done after the system boots for the first time on a boot derivation that is signed
ssh "root@$targetIP" 'nix run nixpkgs#sbctl -- enroll-keys --microsoft'

ssh "root@$targetIP" reboot

echo "NiXium Experimental Installer Finished!"
