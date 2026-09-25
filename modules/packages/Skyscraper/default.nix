{
  writeText,
  writeShellScriptBin,
  skyscraper,
  main-opts ? {},
  platform-opts ? {},
  lib,
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

  handleLibretro = _: info: let
    exec = "/run/current-system/sw/bin/retroarch";
    core = "/run/current-system/sw/lib/retroarch/cores/${info.core}_libretro.so";
  in {
    launch = "${exec} -L ${core} \"{file.path}\"";
  };

  opts = {main = main-opts;} // (lib.mapAttrs handleLibretro platform-opts);
  skyscraper-config = writeText "skyscraper-config.ini" (attrsToIni opts);
in
  writeShellScriptBin "Skyscraper" ''
    exec ${skyscraper}/bin/Skyscraper -c ${skyscraper-config} "$@"
  ''
