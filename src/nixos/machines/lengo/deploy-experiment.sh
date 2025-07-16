#!/usr/bin/env sh

# Experiment

targetIP="10.48.1.191"

set -e # Exit on false return

ssh "root@$targetIP" mkdir --verbose --parents  /run/agenix.d/1

ssh "root@$targetIP" ln --verbose --symbolic /run/agenix.d/1 /run/agenix # Perform the symlink

ssh "root@$targetIP" chown --verbose "root:root" "/run/agenix.d/1" # Ensure expected ownership

ssh "root@$targetIP" chmod --verbose 700 "/run/agenix.d/1" # Ensure expected permission

ssh "root@$targetIP" 'echo 000000 > /run/agenix/lengo-disks-password'

ssh "root@$targetIP" 'cat > /etc/ssh/ssh_host_ed25519_key' < <(age -i ~/.ssh/id_ed25519 -d ./src/nixos/machines/lengo/secrets/lengo-ssh-ed25519-private.age || true)

ssh "root@$targetIP" nix run github:nix-community/disko#disko -- --mode disko --root-mountpoint /mnt --debug --flake github:kreyren/nixos-config/tinker#nixos-lengo-stable

ssh "root@$targetIP" mount -v -o remount,size=30G,noatime /nix/.rw-store
ssh "root@$targetIP" mount -v -o remount,size=5G,noatime /mnt

ssh "root@$targetIP" nix run nixpkgs#sbctl -- create-keys

ssh "root@$targetIP" mkdir -v -p /mnt/nix/persist/system/var/lib/

ssh "root@$targetIP" cp -v -r /var/lib/sbctl /mnt/nix/persist/system/var/lib/sbctl

ssh "root@$targetIP" mkdir -v -p /mnt/var/lib/sbctl

ssh "root@$targetIP" cp -v -r /var/lib/sbctl/* /mnt/var/lib/sbctl

ssh "root@$targetIP" nix run nixpkgs#sbctl -- enroll-keys --microsoft

ssh "root@$targetIP" mkdir -v -p /mnt/nix/persist/system/etc/ssh

ssh "root@$targetIP" cp -v /etc/ssh/ssh_host_ed25519_key /mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key

ssh "root@$targetIP" chmod --verbose 400 /mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key # Ensure correct permission

ssh "root@$targetIP" nix shell nixpkgs#nixos-install-tools --command nixos-install --verbose --root /mnt --flake github:kreyren/nixos-config/tinker#nixos-lengo-stable

ssh "root@$targetIP" mkdir -v -p /mnt/nix/persist/users/kreyren/.ssh

ssh "root@$targetIP" 'cat > /mnt/nix/persist/users/kreyren/.ssh/id_ed25519' < <(cat /home/kreyren/.ssh/id_ed25519 || true)

ssh "root@$targetIP" chmod -v 400 /mnt/nix/persist/users/kreyren/.ssh/id_ed25519

ssh "root@$targetIP" chown -v -R 1000:users /mnt/nix/persist/users/kreyren
