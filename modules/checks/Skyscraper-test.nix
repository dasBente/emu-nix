{
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    checks.Skyscraper-test = pkgs.testers.nixosTest {
      name = "emu-nix.Skyscraper-test";

      nodes.installTest = {
        environment.systemPackages = [
          (
            config.packages.Skyscraper.override {
              main-opts = {inputFolder = "MAIN_TEST";};
              platform-opts = {
                snes = {
                  inputFolder = "SNES_TEST";
                  emulator = {
                    kind = "basic";
                    cmd = "TEST_CMD";
                  };
                };
              };
            }
          )
        ];
      };

      testScript = ''
        start_all()
        installTest.wait_for_unit("multi-user.target")

        scraper = installTest.succeed("cat $(command -v Skyscraper)")

        import re
        config_file = re.search(r"-c (\S+)", scraper)
        assert config_file is not None, f"can't find config path in {scraper}"

        content = installTest.succeed(f"cat {config_file.group(1)}")

        assert "[main]" in content, "Should contain main block"
        assert "[snes]" in content, "Should contain SNES platform"
      '';
    };
  };
}
