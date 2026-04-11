{ pkgs, nixpkgsLib }:

let
    inherit (nixpkgsLib) mkForce;
in
rec {
    mkVMGraphicalWayland = {
        name,
        modules ? [],
        user ? {
            isNormalUser = true;
            createHome = true;
            password = "000000";
            extraGroups = [ "video" "wheel" ];
            description = "Kreyren";
        },
        terminalProgram ? "vim",
    }: let
        baseVMModules = [
            {
                boot.lanzaboote.enable = false;
                boot.impermanence.enable = mkForce false;
                boot.kernelParams = [ "console=ttyS0" ];
                system.stateVersion = nixpkgsLib.versions.majorMinor nixpkgsLib.version;
                age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
                services.openssh.enable = true;
            }
        ];

        nixosSystem = nixpkgsLib.nixosSystem {
            system = pkgs.system;
            pkgs = import pkgs.path {
                inherit (pkgs) system;
                config.allowUnfree = false;
            };
            modules = baseVMModules ++ [
                {
                    environment.systemPackages = with pkgs; [ cage foot ];

                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.kreyren = {
                            imports = modules;
                            home.stateVersion = "25.11";
                        };
                    };

                    users.users.kreyren = mkForce user;

                    services.greetd = {
                        enable = true;
                        settings.default_session = {
                            command = "${pkgs.cage}/bin/cage -- ${pkgs.foot}/bin/foot -e ${terminalProgram}";
                            user = "kreyren";
                        };
                    };

                    systemd.services.greetd.serviceConfig.Restart = mkForce "no";

                    environment.etc."xdg/foot/foot.ini".text = ''
                        [main]
                        font=monospace:size=12

                        [colors]
                        background=1a1a1a
                        foreground=dcdccc
                    '';

                    virtualisation.vmVariant = {
                        virtualisation = {
                            memorySize = 1024 * 2;
                            cores = 2;
                            diskSize = 1024 * 5;
                            graphics = true;
                        };
                    };
                }
            ];
        };
    in {
        inherit nixosSystem;
        package = nixosSystem.config.system.build.vm;
    };

    mkDiskScript = { name, modulePath }: ''
        if [ -n "''${FLAKE_ROOT:-}" ] && [ -d "$FLAKE_ROOT" ]; then
            info "Loading VM '${name}' in Developer Mode"
            export NIX_DISK_IMAGE="${modulePath}/${name}.qcow2"

        elif [ -n "''${NIX_DISK_IMAGE:-}" ]; then
            info "Loading VM '${name}' in Persistent Mode"
            [ "''${NIX_DISK_IMAGE%.qcow2}" != "$NIX_DISK_IMAGE" ] || die 1 "Variable 'NIX_DISK_IMAGE' MUST match regex '*.qcow2$'"
            [ ! -f "''${NIX_DISK_IMAGE}" ] || warn "File 'NIX_DISK_IMAGE' (''${NIX_DISK_IMAGE}) already exists -> Loading impure filesystem from previous virtual machine"

        else
            info "Loading VM '${name}' in Ephemeral Mode (filesystem will be wiped on exit)"
            info "For persistent mode, set NIX_DISK_IMAGE to a path matching '^/*.qcow2$'"
            export QEMU_OPTS="''${QEMU_OPTS:+$QEMU_OPTS }-snapshot"
            export TMPDIR="''${TMPDIR:-/var/tmp}"
            BASE_DISK="/var/tmp/nixium-vm-$$-$RANDOM.qcow2"
            if [ ! -f "$BASE_DISK" ]; then
                temp=$(mktemp)
                qemu-img create -f raw "$temp" 8G >/dev/null 2>&1
                mkfs.ext4 -L nixos "$temp" -q -F
                qemu-img convert -f raw -O qcow2 "$temp" "$BASE_DISK"
                rm "$temp"
            fi
            export NIX_DISK_IMAGE="$BASE_DISK"
        fi
    '';
}
