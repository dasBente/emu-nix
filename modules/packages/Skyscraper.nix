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

      handleLibretro = _: info: let
        exec = "/run/current-system/sw/bin/retroarch";
        core = "/run/current-system/sw/lib/retroarch/cores/${info.core}_libretro.so";
      in
        sanitize {
          launch = ''${exec} -L ${core} \"{file.path}\"'';
          inputFolder = info.inputFolder;
        };

      opts = {main = sanitize main-opts;} // (lib.mapAttrs handleLibretro platform-opts);
      skyscraper-config = writeText "skyscraper-config.ini" (attrsToIni opts);
    in
      writeShellScriptBin "Skyscraper" ''
        exec ${skyscraper}/bin/Skyscraper -c ${skyscraper-config} "$@"
      '';
  in {
    packages.Skyscraper = pkgs.callPackage pkg-fn {};
  };
}
