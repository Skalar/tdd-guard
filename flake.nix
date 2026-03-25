{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    nixpkgs-ruby.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    nixpkgs-ruby,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      rubyVersion = nixpkgs.lib.fileContents ./.ruby-version;
      ruby = nixpkgs-ruby.lib.mkRuby {inherit pkgs rubyVersion;};
    in {
      packages.default = pkgs.buildNpmPackage {
        pname = "tdd-guard";
        version = "1.1.0";
        src = ./.;
        npmDepsHash = "sha256-NJzHv2GwmTrrgfsJmjMsno3PUo1yAgLIH12cVC6yTk4=";
        nodejs = pkgs.nodejs_22;
        npmBuildScript = "build";
        # Workspace symlinks point to reporter source dirs not present in the output
        postFixup = ''
          find $out -type l ! -exec test -e {} \; -delete
        '';
      };

      devShell = with pkgs;
        mkShell {
          buildInputs = [
            ruby
            php83
            nodejs_22
            python310
            go_1_24
            cargo
            rustc
            clippy
            rustfmt
          ];
        };
    });
}
