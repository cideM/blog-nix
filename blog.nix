{ pkgs ? (import ./nixpkgs.nix ) }:

let
  blog-go = pkgs.buildGoModule rec {
    pname = "fbrs-blog-go";
    version = "latest";

    # I needed to set this to a fake hash first and take whatever nix-build gave me
    modSha256 = "0wd10n6hki138c4rh9w87c2sg91hzhlvxwxb9kxk1h951vi76adl";

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
      blog 2> foo
    '';

    installPhase = ''
      mkdir -p $out/files
      cp foo $out/files
    '';
  };

in blog
