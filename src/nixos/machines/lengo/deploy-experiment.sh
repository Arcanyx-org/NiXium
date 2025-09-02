#!/usr/bin/env sh

# Experiment

targetIP="192.168.0.220"
targetFlake="github:kreyren/nixos-config/central-lengo-fix#nixos-lengo-stable"

set -e # Exit on false return

set -x # Debug

ssh "root@$targetIP" mkdir --verbose --parents  /run/agenix.d/1

ssh "root@$targetIP" ln --verbose --symbolic /run/agenix.d/1 /run/agenix # Perform the symlink

ssh "root@$targetIP" chown --verbose "root:root" "/run/agenix.d/1" # Ensure expected ownership

ssh "root@$targetIP" chmod --verbose 700 "/run/agenix.d/1" # Ensure expected permission

ssh "root@$targetIP" 'echo 000000 > /run/agenix/lengo-disks-password'

# # shellcheck disable=SC2312
ssh "root@$targetIP" 'cat > /etc/ssh/ssh_host_ed25519_key' < <(nix run nixpkgs#age -- -i ~/.ssh/id_ed25519 -d ./src/nixos/machines/lengo/secrets/lengo-ssh-ed25519-private.age)

# # shellcheck disable=SC2312
ssh "root@$targetIP" 'cat > /key' < <(nix run nixpkgs#age -- -i ~/.ssh/id_ed25519 -d ./src/nixos/machines/lengo/secrets/lengo-unlock-key.age)

ssh "root@$targetIP" 'dd if=/key of=/dev/disk/by-id/mmc-NCard_0x23904944 conv=sync status=progress'

# shellcheck disable=SC2029 # We want this to expand on client-side
ssh "root@$targetIP" "nix --extra-experimental-features 'flakes nix-command' run github:nix-community/disko#disko -- --mode disko --root-mountpoint /mnt --debug --flake $targetFlake"

ssh "root@$targetIP" 'mount -v -o remount,size=40G,noatime /nix/.rw-store'
ssh "root@$targetIP" 'mount -v -o remount,size=15G,noatime /mnt'

ssh "root@$targetIP" "nix --extra-experimental-features 'flakes nix-command' run nixpkgs#sbctl -- create-keys"

ssh "root@$targetIP" 'mkdir -v -p /mnt/nix/persist/system/var/lib/'

ssh "root@$targetIP" 'cp -v -r /var/lib/sbctl /mnt/nix/persist/system/var/lib/sbctl'

ssh "root@$targetIP" 'mkdir -v -p /mnt/var/lib/sbctl'

ssh "root@$targetIP" 'cp -v -r /var/lib/sbctl/* /mnt/var/lib/sbctl'

ssh "root@$targetIP" 'mkdir -v -p /mnt/nix/persist/system/etc/ssh'

ssh "root@$targetIP" 'cp -v /etc/ssh/ssh_host_ed25519_key /mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key'

ssh "root@$targetIP" 'chmod --verbose 400 /mnt/nix/persist/system/etc/ssh/ssh_host_ed25519_key' # Ensure correct permission

# FIXME(Krey): Results in no space left on device? Like how?
	# [root@nixos:~]# nix-collect-garbage -d
	# removing old generations of profile /nix/var/nix/profiles/system
	# removing old generations of profile /nix/var/nix/profiles/per-user/root/channels
	# removing old generations of profile /nix/var/nix/profiles/per-user/root/channels
	# finding garbage collector roots...
	# removing stale link from '/nix/var/nix/gcroots/auto/2bmx7m1yn7dhfa7h1hkc26154hhm5kd9' to '/tmp/nix-build-4703-0/result'
	# removing stale temporary roots file '/nix/var/nix/temproots/7590'
	# removing stale temporary roots file '/nix/var/nix/temproots/3037'
	# deleting garbage...
	# deleting '/nix/store/793gsnp2jvlwcp83lnqgkn68jl1dja5g-nixos-system-nixos-25.05.806273.650e572363c0'
	# 1 store paths deleted, 0.00 MiB freed
	# error: chmod "/nix/store/793gsnp2jvlwcp83lnqgkn68jl1dja5g-nixos-system-nixos-25.05.806273.650e572363c0": No space left on device

	# [root@nixos:~]# df -h
	# Filesystem         Size  Used Avail Use% Mounted on
	# devtmpfs           583M     0  583M   0% /dev
	# tmpfs              5.7G  8.0K  5.7G   1% /dev/shm
	# tmpfs              2.9G  7.0M  2.9G   1% /run
	# tmpfs              5.7G   34M  5.7G   1% /
	# tmpfs              3.8G  3.8G  1.1M 100% /iso
	# /dev/loop0         3.7G  3.7G     0 100% /nix/.ro-store
	# tmpfs               50G   34G   17G  68% /nix/.rw-store
	# overlay             50G   34G   17G  68% /nix/store
	# efivarfs           148K  125K   19K  88% /sys/firmware/efi/efivars
	# tmpfs              1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
	# tmpfs              5.7G  1.4M  5.7G   1% /run/wrappers
	# tmpfs              1.2G  124K  1.2G   1% /run/user/1000
	# tmpfs              1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
	# none                15G   28K   15G   1% /mnt
	# /dev/nvme0n1p1     511M  4.0K  511M   1% /mnt/boot
	# /dev/mapper/store  417G  5.9M  415G   1% /mnt/nix
	# /dev/mapper/store  417G  5.9M  415G   1% /mnt/nix/persist/system
	# /dev/mapper/store  417G  5.9M  415G   1% /mnt/nix/persist/users
	# tmpfs              1.2G   56K  1.2G   1% /run/user/0
	#
	# [root@nixos:~]# free -h
	#                total        used        free      shared  buff/cache   available
	# Mem:            11Gi       9.9Gi       261Mi       7.4Gi       8.9Gi       1.4Gi
	# Swap:           59Gi        30Gi        29Gi
# nix copy --to ssh://root@$targetIP "$(nix build "${targetFlake//#*/}#nixosConfigurations.\"${targetFlake//*#/}\".config.system.build.toplevel" --print-out-paths || true)"

# shellcheck disable=SC2029 # We expect this to expand on client side
ssh "root@$targetIP" "nix --extra-experimental-features 'flakes nix-command' shell nixpkgs#nixos-install-tools --command nixos-install --verbose --root /mnt --flake \"$targetFlake\""

ssh "root@$targetIP" 'mkdir -v -p /mnt/nix/persist/users/kreyren/.ssh'

ssh "root@$targetIP" 'cat > /mnt/nix/persist/users/kreyren/.ssh/id_ed25519' < <(cat /home/kreyren/.ssh/id_ed25519 || true)

ssh "root@$targetIP" 'chmod -v 400 /mnt/nix/persist/users/kreyren/.ssh/id_ed25519'

ssh "root@$targetIP" 'chown -v -R 1000:users /mnt/nix/persist/users/kreyren'

ssh "root@$targetIP" reboot

# The SSH Key changes here so we have to manage it somehow.. the `-o StrictHostKeychecking=no` feels like bad idea.. we know what it will be and should be adjusting it for that instead

while [ "$(ssh -o StrictHostKeychecking=no "root@$targetIP" echo "booted" || true)" != "booted" ]; do
	sleep 5
done

# FIXME(Krey): Change known hosts

# Has to be done after the system boots for the first time on a boot derivation that is signed
ssh -o StrictHostKeychecking=no "root@$targetIP" "nix --extra-experimental-features 'flakes nix-command' run nixpkgs#sbctl -- enroll-keys --microsoft"

ssh -o StrictHostKeychecking=no "root@$targetIP" reboot

echo "NiXium Experimental Installer Finished!"
