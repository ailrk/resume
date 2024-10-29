{
  description = "Resume";

  inputs = {
      nixpkgs.url     = "github:NixOS/nixpkgs/nixos-24.05";
      flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs      = import nixpkgs { inherit system; };
  in rec {
    packages = {
      resume = pkgs.stdenv.mkDerivation {
        version           = "0.0.0";
        name              = "resume";
        src               = ./.;
        buildPhase = ''
          xelatex resume.tex
        '';
      };
    };

    devShells.default = packages.kbgui.overrideAttrs (prev: {
      buildInputs = with pkgs; prev.buildInputs ++ [
        texliveSmall
      ];
    });
  });
}
