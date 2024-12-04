{
  description = "dmenu flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;

      overlayList = [ self.overlays.default ];

      pkgsBySystem = forEachSystem (
        system:
        import nixpkgs {
          inherit system;
          overlays = overlayList;
        }
      );

    in
    {

      overlays.default = (
        final: prev: {
          dmenuPatched = prev.dmenu.overrideAttrs (oldAttrs: {
            version = "master";
            src = ./.;
          });
        }
      );
      packages = forEachSystem (system: {
        dmenuPatched = pkgsBySystem.${system}.dmenuPatched;
        default = pkgsBySystem.${system}.dmenuPatched;
      });

      nixosModules.overlays = overlayList;

    };
}
