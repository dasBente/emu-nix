{
  flake.overlays.pegasus-frontend = final: prev: {
    pegasus-frontend = prev.pegasus-frontend.overrideAttrs (old: {
      cmakeFlags =
        (old.cmakeFlags or [])
        ++ [
          "-DCMAKE_CXX_STANDARD=17"
          "-DCMAKE_CXX_EXTENSIONS=ON"
        ];
    });
  };
}
