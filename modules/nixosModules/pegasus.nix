{
  flake.nixosModules.emu-nix = {
    pkgs,
    lib,
    config,
    ...
  }: let
    launcher = name: info: let
      exec = "/run/current-system/sw/bin/retroarch";
      core = "/run/current-system/sw/lib/retroarch/cores/${info.core}_libretro.so";
    in ''
      [${name}]
      launch="${exec} -L ${core} \"{file.path}\""
    '';

    core-txt =
      lib.concatStringsSep "\n"
      (lib.mapAttrsToList launcher config.emu-nix.enabledSystems);

    skyscraper-config = pkgs.writeText "skyscraper-config.ini" ''
      [main]
      frontend="pegasus"

      ${core-txt}
    '';

    skyscraper-sh = pkgs.writeShellScriptBin "Skyscraper" ''
      exec ${pkgs.skyscraper}/bin/Skyscraper -c ${skyscraper-config} "$@"
    '';
  in {
    options.emu-nix.pegasus.enable = lib.mkEnableOption "Install pegasus frontend";

    config.environment.systemPackages = lib.mkIf config.emu-nix.pegasus.enable [
      pkgs.pegasus-frontend
      skyscraper-sh
    ];
  };
}
