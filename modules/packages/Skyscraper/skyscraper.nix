{config, ...}: {
  perSystem = {pkgs, ...}: {
    packages.Skyscraper = pkgs.callPackage ./default.nix {};
  };
}
