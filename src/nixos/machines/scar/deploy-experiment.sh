#!/usr/bin/env bash

# Scar Deployment Script — Boot live ISO, then run this from dev machine.
# FIXME: User passwords (kreyren/kira/wifi) won't decrypt — scar-system missing from all-systems in secrets.nix

set -ex

targetIP="192.168.0.188"
ageIdentity="/nix/persist/users/kreyren/.ssh/id_ed25519"
nixiumDir="/nix/persist/NiXium"
localToplevel="/nix/store/zna7i2b1gqqkn2f4jb1shi8lw2wp9ylr-nixos-system-scar-26.05.20260710.8f0500b"

ssh_target() { ssh -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new root@$targetIP "$@"; }

# LUKS + swap
ssh_target "echo -n 000000 | cryptsetup luksOpen /dev/sda3 scar-store --key-file=-"
ssh_target "echo -n 000000 | cryptsetup luksOpen /dev/sda2 scar-swap --key-file=-"
ssh_target "mkswap /dev/mapper/scar-swap && swapon /dev/mapper/scar-swap"

# Mount
ssh_target "mount -o subvolid=5 /dev/mapper/scar-store /mnt"
ssh_target "mkdir -p /mnt/boot /mnt/nix /mnt/nix/persist/system /mnt/nix/persist/users"
ssh_target "mount -o subvolid=256 /dev/mapper/scar-store /mnt/nix"
ssh_target "mount -o subvolid=257 /dev/mapper/scar-store /mnt/nix/persist/system"
ssh_target "mount -o subvolid=258 /dev/mapper/scar-store /mnt/nix/persist/users"
ssh_target "mount /dev/sda1 /mnt/boot"

# Free RAM + tmpfs space
ssh_target "mount -o remount,size=20G /nix/.rw-store || true"
ssh_target "systemctl stop gdm 2>/dev/null; pkill -f gnome 2>/dev/null; true"

# sbctl keys (--disable-landlock required in live ISO)
ssh_target "nix --extra-experimental-features 'flakes nix-command' run nixpkgs#sbctl -- --disable-landlock create-keys"
ssh_target "mkdir -p /mnt/nix/persist/system/var/lib"
ssh_target "cp -r /var/lib/sbctl /mnt/nix/persist/system/var/lib/sbctl"
ssh_target "chmod -R 400 /mnt/nix/persist/system/var/lib/sbctl/keys/*"
ssh_target "mkdir -p /mnt/var/lib/sbctl"
ssh_target "cp -r /var/lib/sbctl/* /mnt/var/lib/sbctl/"
ssh_target "chmod -R 400 /mnt/var/lib/sbctl/keys/*"

# SSH host key
ssh_target "mkdir -p /mnt/nix/persist/system/etc/ssh"
age -i "$ageIdentity" -d "$nixiumDir/src/nixos/machines/scar/secrets/scar-ssh-ed25519-private.age" | ssh_target "cat > /mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key"
ssh_target "chmod 600 /mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key"

# Copy pre-built closure
nix copy --to "ssh://root@$targetIP" "$localToplevel"

# Install
ssh_target "nixos-install --system $localToplevel --no-root-passwd"

# User access
ssh_target "mkdir -p /mnt/root/.ssh"
ssh_target "cat $ageIdentity.pub > /mnt/root/.ssh/authorized_keys"
ssh_target "chmod 700 /mnt/root/.ssh && chmod 600 /mnt/root/.ssh/authorized_keys"
ssh_target "mkdir -p /mnt/nix/persist/users/kreyren/.ssh"
cat /nix/persist/users/kreyren/.ssh/id_ed25519 | ssh_target "cat > /mnt/nix/persist/users/kreyren/.ssh/id_ed25519"
cat /nix/persist/users/kreyren/.ssh/id_ed25519.pub | ssh_target "cat > /mnt/nix/persist/users/kreyren/.ssh/id_ed25519.pub"
ssh_target "chmod 600 /mnt/nix/persist/users/kreyren/.ssh/id_ed25519 && chmod 644 /mnt/nix/persist/users/kreyren/.ssh/id_ed25519.pub"
ssh_target "chown -R 1000:users /mnt/nix/persist/users/kreyren"

# Reboot + enroll Secure Boot keys
ssh_target "reboot"
sleep 60
ssh_target "nix run nixpkgs#sbctl -- --disable-landlock enroll-keys --microsoft || true"
ssh_target "reboot"

echo "Done"
