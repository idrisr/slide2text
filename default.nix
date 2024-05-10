{ writeShellApplication, haskell, compiler ? "ghc948", tesseract }:
let slide2text = haskell.packages.${compiler}.callCabal2nix "" ./slide2text { };
in writeShellApplication {
  name = "slide2text";
  runtimeInputs = [ slide2text tesseract ];
  text = ''
    exec slide2text "$@"
  '';
}
