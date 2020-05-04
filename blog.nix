{ pkgs ? (import ./nixpkgs.nix {}) }:

let
  blog-go = pkgs.buildGoModule rec {
    pname = "fbrs-blog-go";
    version = "latest";

    # I needed to set this to a fake hash first and take whatever nix-build gave me
    modSha256 = "14l74yjhwhzg1a3kkqjv95qgliqwmi3wqwcslrs435wlqnmlkgal";

    src = builtins.path { 
      name = "go-src-blog";
      path = ./.;
    };
  };

  blog = pkgs.stdenv.mkDerivation {
    pname = "fbrs-blog";
    version = "latest";
    src = builtins.path { path = ./.; name = "src-blog"; };
    buildInputs = [ blog-go ];

    buildPhase = ''
      mkdir out
      blog -contentdir=./content/ -outdir=./out -templatedir=./go_templates
    '';

    installPhase = ''
      mkdir -p $out/public
      cp out/* $out/public/
      cp styles.css $out/public/
    '';
  };

in blog
