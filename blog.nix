{ pkgs ? (import ./nixpkgs.nix {}) }:

let
  blog-go = pkgs.buildGoModule rec {
    pname = "fbrs-blog-go";
    version = "latest";

    # I needed to set this to a fake hash first and take whatever nix-build gave me
    modSha256 = "17fpi8dbm8kn39gyc5q0yndh7qsajfcp3g5xkk0rirydmwhafkhd";

    src = builtins.path { 
      name = "go-src-blog";
      path = ./go;
    };
  };

  blog = pkgs.stdenv.mkDerivation {
    pname = "fbrs-blog";
    version = "latest";
    src = builtins.path { path = ./.; name = "src-blog"; };
    buildInputs = [ blog-go ];

    buildPhase = ''
      mkdir out
      cd go
      blog -contentdir=../content/ -outdir=../out
      cd ../
    '';

    installPhase = ''
      mkdir -p $out/public
      cp out/* $out/public/
      cp styles.css $out/public/
    '';
  };

in blog
