{
  perSystem = {pkgs, ...}: let
    pkg-fn = {
      writeText,
      writeShellScriptBin,
      skyscraper,
      lib,
      main-opts ? {},
      platform-opts ? {},
      ...
    }: let
      sanitize = attrs: lib.filterAttrs (_: v: v != null) attrs;

      attrsToIni = attrs: let
        toOption = opt: value: "${opt}=\"${value}\"";
        toLevel = lvl: options:
          lib.concatStringsSep
          "\n"
          (["[${lvl}]"] ++ lib.mapAttrsToList toOption (sanitize options));
      in
        lib.concatStringsSep
        "\n\n"
        (lib.mapAttrsToList toLevel attrs);

      # extracts launch command for skyscraper config depending on emulator type
      toLaunchCmd = emulator @ {kind, ...}:
        {
          libretro = ''/run/current-system/sw/bin/retroarch -L ${emulator.core} \"{file.path}\"'';
          basic = emulator.cmd;
        }."${kind}";

      parseOpts = _: info:
        sanitize {
          launch = toLaunchCmd info.emulator;
          inputFolder = info.inputFolder or null;
        };

      opts = {main = sanitize main-opts;} // (lib.mapAttrs parseOpts platform-opts);
      skyscraper-config = writeText "skyscraper-config.ini" (attrsToIni opts);
    in
      writeShellScriptBin "Skyscraper" ''
        exec ${skyscraper}/bin/Skyscraper -c ${skyscraper-config} "$@"
      '';
  in {
    packages.Skyscraper = pkgs.callPackage pkg-fn {};
  };
}
