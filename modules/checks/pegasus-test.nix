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

        scraper = enabled.succeed("cat $(command -v Skyscraper)")

        import re
        config_file = re.search(r"-c (\S+)", scraper)
        assert config_file is not None, f"can't find config path in {scraper}"

        content = enabled.succeed(f"cat {config_file.group(1)}")

        assert "[main]" in content, "Should contain main block"
        assert "[snes]" in content, "Should contain SNES platform"
      '';
    };
  };
}
