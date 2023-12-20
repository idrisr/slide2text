{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/23.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    let
      system = flake-utils.lib.system.x86_64-linux;
      compiler = "ghc948";
      pkgs = import nixpkgs { system = system; };
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
      ];

      slide2text = with pkgs; haskell.packages.${compiler}.callPackage ./. { };

      wrapped = pkgs.writeShellApplication {
        name = "slide2text";
        runtimeInputs = [ slide2text pkgs.tesseract ];
        text = ''
          exec imgocr "$@"
        '';
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [ cabal2nix zlib tesseract5 ] ++ myDevTools;
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath myDevTools;
      };

      apps.${system}.default = {
        type = "app";
        program = "${slide2text}/bin/imgocr";
      };
      packages.${system}.default = wrapped;
    };
}
