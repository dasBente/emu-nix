{
  withSystem,
  self,
  ...
}: {
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

    system = pkgs.stdenv.hostPlatform.system;

    skyscraper-sh =
      withSystem system
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

    config = lib.mkIf config.emu-nix.pegasus.enable {
      nixpkgs.overlays = [
        self.overlays.pegasus-frontend
      ];

      environment.systemPackages = [
        pkgs.pegasus-frontend
        skyscraper-sh
      ];
    };
  };
}
