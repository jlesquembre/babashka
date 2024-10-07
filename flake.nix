{
  description = "babashka flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:

    let
      inherit (nixpkgs.lib)
        genAttrs;

      eachSystem = f: genAttrs
        [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ]
        (system: f
          (import nixpkgs
            {
              inherit system;
              overlays = [
                inputs.devshell.overlays.default
              ];
            }));
    in
    {


      devShells = eachSystem (pkgs: {
        default =
          pkgs.devshell.mkShell {
            packages = [
              pkgs.jq
              pkgs.leiningen
              pkgs.clojure
              pkgs.graalvm-ce
              pkgs.diffutils
            ];
            commands = [
              {
                name = "build";
                help = "Build uberjar and compile native image";
                command =
                  ''
                    bash script/uberjar
                    export GRAALVM_HOME="${pkgs.graalvm-ce}"
                    bash script/compile
                  '';
              }
            ];
          };
      });




    };
}
