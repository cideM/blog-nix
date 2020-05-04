let
  pkgs = import ./nixpkgs.nix {};

  mozillaOverlay = pkgs.fetchFromGitHub {
    owner = "mozilla";
    repo = "nixpkgs-mozilla";
    rev = "e912ed483e980dfb4666ae0ed17845c4220e5e7c";
    sha256 = "08fvzb8w80bkkabc1iyhzd15f4sm7ra10jn32kfch5klgl0gj3j3";
  };
  mozilla = pkgs.callPackage "${mozillaOverlay.out}/package-set.nix" {};
  rustNightly = (mozilla.rustChannelOf { channel = "nightly"; }).rust;
  rustPlatform = pkgs.makeRustPlatform { cargo = rustNightly; rustc = rustNightly; };

  miniserve = rustPlatform.buildRustPackage rec {
    pname = "miniserve";
    version = "0.6.0";

    src = pkgs.fetchFromGitHub {
      owner = "svenstaro";
      repo = pname;
      rev = "ced8583dad006ac1b6bbf3136546877a825542ed";
      sha256 = "106qg5cmcirgbacihx8g34gzd2hi1mb0m72y4d0k4h2d3kj5nr5k";
    };

    buildInputs = [ pkgs.openssl pkgs.pkgconfig ];

    cargoSha256 = "07mmqklqpvwrgsv5bh4b8bwhy522x2dq7d71ljvqvxs7r7ji2lpn";
  };
in 
pkgs.mkShell {
  buildInputs = [
    pkgs.go pkgs.gotools pkgs.nix-prefetch-git miniserve pkgs.entr
  ];
}
