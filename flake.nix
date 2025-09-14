{
  description = "bflixb: erlang";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        packages = {
          language-toolchain = pkgs.stdenv.mkDerivation {
            pname = "flix-beam-toolchain";
            version = "0.1.0";

            src = ./.;

            buildInputs = [ pkgs.flix pkgs.erlang pkgs.rebar3 pkgs.gcc pkgs.make pkgs.nodejs ];

            installPhase = ''
              mkdir -p $out/bin
              cat > $out/bin/placeholder <<'EOF'
              #!/usr/bin/env bash
              EOF
              chmod +x $out/bin/placeholder
            '';

          };
        };

        devShells = {
          default = pkgs.mkShell {
            name = "dev-shell-flix-beam";
            buildInputs = with pkgs; [ flix erlang rebar3 ];
          };
        };
      }
    );
}

