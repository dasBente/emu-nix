{self, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks.systems-test = pkgs.testers.nixosTest {
      name = "emu-nix.systems-test";

      nodes = {
        enabled = {
          imports = [self.nixosModules.emu-nix];
          emu-nix.systems.snes.enable = true;
        };

        disabled = {
          imports = [self.nixosModules.emu-nix];
        };
      };

      testScript = ''
        start_all()

        enabled.wait_for_unit("multi-user.target")
        disabled.wait_for_unit("multi-user.target")

        # check for successful retroarch install
        enabled.succeed("command -v retroarch")
        retroarch_path = enabled.succeed("readlink -f $(command -v retroarch)").strip()
        closure = enabled.succeed(f"nix-store -qR {retroarch_path}")

        assert "bsnes" in closure, "bsnes core missing from retroarch closure"

        for core in ["mupen64plus", "nestopia", "dolphin", "mgba"]:
          assert core not in closure, f"{core} unexpectedly pulled into retroarch closure"

        # make sure retroarch doesn't install if no systems are specified
        disabled.fail("command -v retroarch")
      '';
    };
  };
}
