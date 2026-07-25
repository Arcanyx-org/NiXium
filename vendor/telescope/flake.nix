{
  description = "A simple default stardust setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    server = {
      url = "github:StardustXR/server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flatland = {
      url = "github:StardustXR/flatland";
    };
    protostar = {
      url = "git+file:///nix/persist/NiXium/vendor/protostar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gravity = {
      url = "git+file:///nix/persist/NiXium/vendor/gravity";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    black_hole = {
      url = "git+file:///nix/persist/NiXium/vendor/black-hole";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    atmosphere = {
      url = "git+file:///nix/persist/NiXium/vendor/atmosphere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [];
      systems = [ "aarch64-linux" "x86_64-linux" "riscv64-linux" ];
      perSystem = { config, self', inputs', pkgs, lib, system, ... }:
      let
        atmosphere-src = inputs.atmosphere;

        # Package XR environments into XDG-compliant data directory
        # This allows `atmosphere show <name>` to find environments
        # without runtime installation or /tmp directories
        mkAtmosphereData = { environments ? { the_grid = "${atmosphere-src}/data/xr_environments/the_grid"; } }:
          pkgs.runCommand "xr-environments" {} ''
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: path: ''
              mkdir -p $out/xr_environments/${name}
              cp -r ${path}/* $out/xr_environments/${name}/
            '') environments)}
          '';

        xr-environments = mkAtmosphereData {};
      in {
        # Create XDG data directory for atmosphere
        packages.xr-environments = xr-environments;

        # edit these to add/remove clients
        packages.startup_script = pkgs.writeShellApplication {
          name = "startup_script";
          runtimeInputs = [
            inputs'.flatland.packages.default
            inputs'.protostar.packages.default
            inputs'.gravity.packages.default
            inputs'.black_hole.packages.default
            inputs'.atmosphere.packages.default
            pkgs.xwayland-satellite
          ];
          ## and this is the startup script
          text = ''
            unset LD_LIBRARY_PATH
            if [[ -v LD_LIBRARY_PATH_ORIGINAL ]]; then
              echo "Restored pre-exisiting LD_LIBRARY_PATH"
              export LD_LIBRARY_PATH="$LD_LIBRARY_PATH_ORIGINAL"
            fi

            # Use declarative Nix store path for XR environments
            export XDG_DATA_HOME="${xr-environments}"

            xwayland-satellite :10 &
            export DISPLAY=:10 &
            sleep 0.1;

            flatland &
            gravity -- 0 0.0 -0.5 hexagon_launcher &
            black-hole &
            atmosphere show the_grid &
          '';
        };
        packages.flatscreen = pkgs.writeShellApplication {
          name = "flatscreen";
          runtimeInputs = [ self'.packages.telescope ];
          text = ''telescope -f'';
        };
        packages.telescope = pkgs.writeShellApplication {
          name = "telescope";
          runtimeInputs = [
            inputs'.server.packages.default
          ];
          text = ''
          	stardust-xr-server -d -o 1 -e "${self'.packages.startup_script}/bin/startup_script" "$@"
          '';
        };
        packages.default = self'.packages.telescope;

        apps.flatscreen = {
          type = "app";
          program = "${self'.packages.flatscreen}/bin/flatscreen";
        };
        apps.telescope = {
          type = "app";
          program = "${self'.packages.telescope}/bin/telescope";
        };
        apps.default = self'.apps.telescope;
      };
      flake = {};
    };
}
