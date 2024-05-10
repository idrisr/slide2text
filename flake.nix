{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/23.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    let
      system = flake-utils.lib.system.x86_64-linux;
      compiler = "ghc948";
      pkgs = import nixpkgs { inherit system; };
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

      slide2text = with pkgs;
        haskell.packages.${compiler}.callCabal2nix "" ./slide2text { };

      wrapped = pkgs.writeShellApplication {
        name = "slide2text";
        runtimeInputs = [ slide2text pkgs.tesseract ];
        text = ''
          exec slide2text "$@"
        '';
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [ cabal2nix zlib tesseract5 ] ++ myDevTools;
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath myDevTools;
      };

      overlays = {
        slide2text = final: prev: {
          slide2text = with prev;
            haskell.packages.${compiler}.callCabal2nix "" ./slide2text { };
        };
      };

      apps.${system}.default = {
        type = "app";
        program = "${slide2text}/bin/slide2text";
      };
      packages.${system}.default = wrapped;
    };
}
