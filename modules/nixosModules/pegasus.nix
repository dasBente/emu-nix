{
  flake.nixosModules.emu-nix = {
    pkgs,
    lib,
    config,
    ...
  }: let
    skyscraper-sh = pkgs.callPackage ../packages/Skyscraper/default.nix {
      mainOpts = {
        inherit (config.emu-nix.pegasus) inputFolder;
        frontend = "pegasus";
      };
      platform-opts = config.emu-nix.enabledSystems;
    };
  in {
    options.emu-nix.pegasus = {
      enable = lib.mkEnableOption "Install pegasus frontend";

      inputFolder = lib.mkOption {
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
