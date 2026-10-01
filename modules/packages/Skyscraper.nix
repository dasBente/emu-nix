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
      # extracts launch command for skyscraper config depending on emulator type
      toLaunchCmd = emulator @ {kind, ...}:
        {
          libretro = ''/run/current-system/sw/bin/retroarch -L ${emulator.core} \"{file.path}\"'';
          basic = emulator.cmd;
        }."${kind}";

      # clear null-value keys from attribute set
      sanitize = attrs: lib.filterAttrs (_: v: v != null) attrs;

      # prepare option set for processing into .ini file by applying transformations and stripping nulls
      parseOpts = _: info:
        sanitize {
          launch = toLaunchCmd info.emulator;
          inputFolder = info.inputFolder or null;
        };

      # combine option sets into one chunk for processing
      opts = {main = sanitize main-opts;} // (lib.mapAttrs parseOpts platform-opts);

      # converts attrset into .ini file
      # { category = { opt = "some_value"; ... }; ... }
      # => [category]
      #    opt = "some_value
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

      # reference to final config file
      skyscraper-config = writeText "skyscraper-config.ini" (attrsToIni opts);
    in
      writeShellScriptBin "Skyscraper" ''
        exec ${skyscraper}/bin/Skyscraper -c ${skyscraper-config} "$@"
      '';
  in {
    packages.Skyscraper = pkgs.callPackage pkg-fn {};
  };
}
