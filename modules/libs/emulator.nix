{
  flake.lib.mkLibretro = {
    pkg,
    core,
  }: {
    inherit pkg;
    kind = "libretro";
    core = "${pkg}/lib/retroarch/cores/${core}_libretro.so";
  };
}
