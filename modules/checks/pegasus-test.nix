{self, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks.pegasus-test = pkgs.testers.nixosTest {
      name = "emu-nix.pegasus-test";

      nodes.enabled = {
        imports = [self.nixosModules.emu-nix];
        pegasus.enable = true;
      };

      testScript = ''
        start_all()
        enabled.wait_for_unit("multi-user.target")
        enabled.succeed("command -v pegasus-fe")
      '';
    };
  };
}
