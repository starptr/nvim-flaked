{
  inputs = {
    nixpkgs.url = "nixpkgs";
    nuenv.url = "github:DeterminateSystems/nuenv";
  };

  outputs = { self, nixpkgs, nuenv }: let
    overlays = [ nuenv.overlays.default ];
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
      inherit system;
      pkgs = import nixpkgs { inherit overlays system; };
    });
  in {
    packages = forAllSystems ({ pkgs, system }: {
      default = pkgs.nuenv.mkDerivation {
        name = "hello";
        packages = [ pkgs.hello ];
        src = ./.;
        # This script is Nushell, not Bash!
        build = ''
          hello --greeting $"($env.MESSAGE)" | save hello.txt
          let out = $"($env.out)/share"
          mkdir $out
          cp hello.txt $out
        '';
        MESSAGE = "My custom Nuenv derivation!";
      };
    });
  };
}
