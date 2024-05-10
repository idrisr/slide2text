{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/23.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    let
      system = flake-utils.lib.system.x86_64-linux;
      compiler = "ghc948";
      pkgs = nixpkgs.legacyPackages.${system};
      hPkgs = pkgs.haskell.packages."${compiler}";
      myDevTools = with hPkgs; [
        cabal-install
        fourmolu
        ghc
        ghcid
        haskell-language-server
        hlint
        hoogle
        implicit-hie
        retrie
        cabal-fmt
      ];
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [ cabal2nix zlib tesseract5 ] ++ myDevTools;
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath myDevTools;
      };
      packages.${system}.default = pkgs.callPackage ./. { };
      overlays = {
        slide2text = _: prev: { slide2text = prev.callPackage ./. { }; };
      };
    };
}
