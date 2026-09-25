{self, ...}: {
  perSystem = {pkgs, ...}: {
    checks.pegasus-test = pkgs.testers.nixosTest {
      name = "emu-nix.pegasus-test";

      nodes.enabled = {
        imports = [self.nixosModules.emu-nix];
        emu-nix.pegasus.enable = true;

        # install a system to check if config generates correctly
        emu-nix.systems.snes.enable = true;
      };

      testScript = ''
        start_all()
        enabled.wait_for_unit("multi-user.target")
        enabled.succeed("command -v pegasus-fe")
      '';
    };
  };
}
