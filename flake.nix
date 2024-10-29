{
  description = "Resume";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in
  {
    devShells = forAllSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = [
          self.packages.${system}.xelatex
          pkgs.pandoc
        ];
      };
    });
    packages = forAllSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      texlive = with pkgs;
        texlive.combine {
          inherit
            (texlive)
            scheme-small
            xltxtra
            xunicode
            geometry
            marginnote
            multirow
            sectsty
            ulem
            hyperref
            polyglossia
            fontspec
            greek-fontenc
            ;
        };
      xelatex = with pkgs;
        runCommand "xelatex" {
          nativeBuildInputs = [makeWrapper];
        }
        ''
          mkdir -p $out/bin
          makeWrapper ${self.packages.${system}.texlive}/bin/xelatex $out/bin/xelatex
        '';
    });
  };
}
