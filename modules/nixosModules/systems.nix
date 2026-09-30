{
  lib,
  self,
  ...
}: {
  flake.nixosModules.emu-nix = {
    pkgs,
    config,
    ...
  }: {
    options.emu-nix.systems = lib.mkOption {
      description = "Defines the emulator suit to be installed.";

      default = {};

      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "this emulator";

          emulator = lib.mkOption {
            type = lib.types.attrs;
            description = "Definition of the emulator to use";
          };

          inputFolder = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Optional path override for ROM directory";
          };
        };
      });
    };

    options.emu-nix.enabledSystems = lib.mkOption {
      description = "Subset of enabled emu-nix.systems";
      type = lib.types.attrsOf lib.types.anything;
      readOnly = true;
      internal = true;
    };

    config = {
      # defaults
      emu-nix.systems = {
        n64.emulator = lib.mkDefault (self.lib.mkLibretro {
          pkg = pkgs.libretro.mupen64plus;
          core = "mupen64plus_next";
        });

        snes.emulator = lib.mkDefault (self.lib.mkLibretro {
          pkg = pkgs.libretro.bsnes;
          core = "bsnes";
        });

        nes.emulator = lib.mkDefault (self.lib.mkLibretro {
          pkg = pkgs.libretro.nestopia;
          core = "nestopia";
        });

        gc.emulator = lib.mkDefault (self.lib.mkLibretro {
          pkg = pkgs.libretro.dolphin;
          core = "dolphin";
        });

        gba.emulator = lib.mkDefault (self.lib.mkLibretro {
          pkg = pkgs.libretro.mgba;
          core = "mgba";
        });

        gbc.emulator = lib.mkDefault (self.lib.mkLibretro {
          pkg = pkgs.libretro.mgba;
          core = "mgba";
        });
      };

      emu-nix.enabledSystems =
        lib.filterAttrs (_: {enable, ...}: enable) config.emu-nix.systems;

      environment.systemPackages = let
        retroarchCores = lib.filterAttrs (_: opts: opts.emulator.kind == "libretro") config.emu-nix.enabledSystems;

        retroarch =
          pkgs.retroarch.withCores
          (_: lib.unique (lib.mapAttrsToList (_: v: v.emulator.pkg) retroarchCores));
      in
        lib.mkIf (config.emu-nix.enabledSystems != {}) [retroarch];
    };
  };
}
