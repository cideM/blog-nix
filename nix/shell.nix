let
  nixpkgs = import (builtins.fetchGit {
    name = "nixpkgs-20.03-darwin";
    url = "https://github.com/nixos/nixpkgs-channels/";
    ref = "refs/heads/nixpkgs-20.03-darwin";
    rev = "c23427de0d501009b9c6d77ff8dda3763c6eb1b4";
  }) {}; 

  vgo2nix = import (builtins.fetchGit {
    name = "vgo2nix";
    url = "https://github.com/nix-community/vgo2nix";
    ref = "refs/heads/master";
    rev = "1288e3dbf23ed79cef237661225df0afa30f8510";
  }) { pkgs = nixpkgs; }; 
  
in
  with nixpkgs;

  stdenv.mkDerivation {
    name = "blog";

    buildInputs = [
      vgo2nix
    ];
  }
