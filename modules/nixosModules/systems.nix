{
  flake.nixosModules.emu-nix = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.emu-nix.systems = lib.mkOption {
      description = "Defines the emulator suit to be installed.";

      default = {};

      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "this emulator";

          pkg = lib.mkOption {
            type = lib.types.package;
            description = "The libretro core package.";
          };

          core = lib.mkOption {
            type = lib.types.str;
            description = "Core name, used to locate '<core>_libretro.so'";
          };
        };
      });
    };

    config = {
      # defaults
      emu-nix.systems = {
        n64 = {
          pkg = lib.mkDefault pkgs.libretro.mupen64plus;
          core = lib.mkDefault "mupen64plus_next";
        };
        snes = {
          pkg = lib.mkDefault pkgs.libretro.bsnes;
          core = lib.mkDefault "snes9x";
        };
        nes = {
          pkg = lib.mkDefault pkgs.libretro.nestopia;
          core = lib.mkDefault "nestopia";
        };
        gc = {
          pkg = lib.mkDefault pkgs.libretro.dolphin;
          core = lib.mkDefault "dolphin";
        };
        gba = {
          pkg = lib.mkDefault pkgs.libretro.mgba;
          core = lib.mkDefault "mgba";
        };
        gbc = {
          pkg = lib.mkDefault pkgs.libretro.mgba;
          core = lib.mkDefault "mgba";
        };
      };

      environment.systemPackages = let
        filtered = lib.filterAttrs (_: {enable, ...}: enable) config.emu-nix.systems;

        retroarch =
          pkgs.retroarch.withCores
          (_: lib.unique (lib.mapAttrsToList (_: v: v.pkg) filtered));
      in
        lib.mkIf (filtered != {}) [retroarch];
    };
  };
}
