{
  flake.nixosModules.emu-nix = {
    pkgs,
    lib,
    config,
    ...
  }: let
    attrsToIni = attrs: let
      toOption = opt: value: "${opt}=\"${value}\"";
      toLevel = lvl: options:
        lib.concatStringsSep
        "\n"
        (["[${lvl}]"] ++ lib.mapAttrsToList toOption options);
    in
      lib.concatStringsSep
      "\n\n"
      (lib.mapAttrsToList toLevel attrs);

    toPlatform = _: info: let
      exec = "/run/current-system/sw/bin/retroarch";
      core = "/run/current-system/sw/lib/retroarch/cores/${info.core}_libretro.so";
    in {launch = "${exec} -L ${core} \"{file.path}\"";};

    skyscraperAttrs =
      {
        main = {
          frontend = "pegasus";
        };
      }
      // (lib.mapAttrs toPlatform config.emu-nix.enabledSystems);

    skyscraper-config =
      pkgs.writeText "skyscraper-config.ini" (attrsToIni skyscraperAttrs);

    skyscraper-sh = pkgs.writeShellScriptBin "Skyscraper" ''
      exec ${pkgs.skyscraper}/bin/Skyscraper -c ${skyscraper-config} "$@"
    '';
  in {
    options.emu-nix.pegasus = {
      enable = lib.mkEnableOption "Install pegasus frontend";

      romPath = lib.mkOption {
        default = "/home/<USER>/RetroPie/roms";
        type = lib.types.string;
        description = "String path to ROM directory.";
      };
    };

    config.environment.systemPackages = lib.mkIf config.emu-nix.pegasus.enable [
      pkgs.pegasus-frontend
      skyscraper-sh
    ];
  };
}
