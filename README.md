# emu-nix

I'm basically just sharing my own emulator setup here (at least unless I
randomly over-engineer this massively, which one might argue is already well in
the process).

This flake ships [Pegasus Frontend](https://pegasus-frontend.org/) and a couple
of emulator cores from the [libretro](https://www.libretro.com/) project. This
allows us to use [RetroArch](https://www.retroarch.com/) inthe background to
help with controller handling and other convenience features. As such, RetroArch
is also installed and can be used to make finer adjustments to the game
experience and individual cores.

## Setup

To use this flake, simply include it in your `inputs` and then pass the
`emu-nix` module to your host system configuration. Here is a minimal example:

```nix
{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        emu-nix.url = "github:dasbente/emu-nix";
        emu-nix.inputs.nixpkgs.follows = "nixpkgs";
    };
    
    outputs = {emu-nix, nixpkgs, ...}: {
        nixosConfigurations.default = nixpkgs.lib.nixosSystem {
            modules = [ 
                emu-nix.nixosModules.emu-nix
            
                ({ pkgs, ... }: {
                    emu-nix.pegasus.enable = true;

                    emu-nix.systems = {
                        n64.enable = true; # enable system using defaults

                        snes = { # use different core
                            enable = true;
                            pkg = pkgs.libretro.bsnes-hd;
                            core = "bsnes-hd";
                        };

                        psp = {
                            enable = true;
                            pkg = pkgs.libretro.ppsspp;
                            core = "ppsspp";
                        };
                    };
                })
            ];

        };
    };
}
```

There is a number of pre-defined systems at the moment: `nes`, `gbc`, `snes`,
`n64`, `gba` and `gc`.

Systems must be explicitly enabled using `emu-nix.[system].enable`. Beyond that,
systems have a `core` and `pkg` option:

- `core`: name of the core file `[core]_libretro.so`
- `pkg`: package to install and use for this system, must be from the `libretro`
  package set

All of this is subject to change.

The `emu-nix.pegasus.enable` option installs the Pegasus Frontend and
[Skyscraper](https://gemba.github.io/skyscraper/), which can be used for ROM
discovery. A custom config will be baked into any invocation of `Skyscraper`,
which defines default run-times for each installed emulator.
