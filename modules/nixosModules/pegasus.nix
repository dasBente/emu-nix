{withSystem, ...}: {
  flake.nixosModules.emu-nix = {
    pkgs,
    lib,
    config,
    ...
  }: let
    skyscraperAttrs = {
      main-opts = {
        inherit (config.emu-nix.pegasus) inputFolder;
        frontend = "pegasus";
      };
      platform-opts = config.emu-nix.enabledSystems;
    };
    skyscraper-sh =
      withSystem pkgs.stdenv.hostPlatform.system
      ({config, ...}: config.packages.Skyscraper.override skyscraperAttrs);
  in {
    options.emu-nix.pegasus = {
      enable = lib.mkEnableOption "Install pegasus frontend";

      inputFolder = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
        description = "String path to ROM directory.";
      };
    };

    config.environment.systemPackages = lib.mkIf config.emu-nix.pegasus.enable [
      pkgs.pegasus-frontend
      skyscraper-sh
    ];
  };
}
