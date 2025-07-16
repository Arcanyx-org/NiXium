#!/usr/bin/env sh

# Experiment

targetIP="10.48.1.191"

set -e # Exit on false return

ssh root@10.48.1.191 mkdir --verbose --parents  /run/agenix.d/1

ssh root@10.48.1.191 ln --verbose --symbolic /run/agenix.d/1 /run/agenix # Perform the symlink

ssh root@10.48.1.191 chown --verbose "root:root" "/run/agenix.d/1" # Ensure expected ownership

ssh root@10.48.1.191 chmod --verbose 700 "/run/agenix.d/1" # Ensure expected permission

ssh root@10.48.1.191 'echo 000000 > /run/agenix/lengo-disks-password'

ssh root@10.48.1.191 'cat > /etc/ssh/ssh_host_ed25519_key' < <(age -i ~/.ssh/id_ed25519 -d ./src/nixos/machines/lengo/secrets/lengo-ssh-ed25519-private.age || true)

ssh root@10.48.1.191 nix run github:nix-community/disko#disko -- --mode disko --root-mountpoint /mnt --debug --flake github:kreyren/nixos-config/tinker#nixos-lengo-stable

ssh root@10.48.1.191 mount -v -o remount,size=30G,noatime /nix/.rw-store
ssh root@10.48.1.191 mount -v -o remount,size=5G,noatime /mnt

ssh root@10.48.1.191 nix run nixpkgs#sbctl -- create-keys

ssh root@10.48.1.191 mkdir -v -p /mnt/nix/persist/system/var/lib/

ssh root@10.48.1.191 cp -v -r /var/lib/sbctl /mnt/nix/persist/system/var/lib/sbctl

ssh root@10.48.1.191 mkdir -v -p /mnt/var/lib/sbctl

ssh root@10.48.1.191 cp -v -r /var/lib/sbctl/* /mnt/var/lib/sbctl

ssh root@10.48.1.191 nix run nixpkgs#sbctl -- enroll-keys --microsoft

ssh root@10.48.1.191 mkdir -v -p /mnt/nix/persist/system/etc/ssh

ssh root@10.48.1.191 cp -v /etc/ssh/ssh_host_ed25519_key /mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key

ssh root@10.48.1.191 chmod --verbose 400 /mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key # Ensure correct permission

ssh root@10.48.1.191 nix shell nixpkgs#nixos-install-tools --command nixos-install --verbose --root /mnt --flake github:kreyren/nixos-config/tinker#nixos-lengo-stable

ssh root@10.48.1.191 mkdir -v -p /mnt/nix/persist/users/kreyren/.ssh

ssh root@10.48.1.191 'cat > /mnt/nix/persist/users/kreyren/.ssh/id_ed25519' < <(cat /home/kreyren/.ssh/id_ed25519 || true)

ssh root@10.48.1.191 chmod -v 400 /mnt/nix/persist/users/kreyren/.ssh/id_ed25519

ssh root@10.48.1.191 chown -v -R 1000:users /mnt/nix/persist/users/kreyren
