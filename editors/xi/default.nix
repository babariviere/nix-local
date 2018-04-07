{rustPlatform, fetchFromGitHub,
  withSyntax ? true}:

let
  version = "master";
  src = (fetchFromGitHub {
    owner = "google";
    repo = "xi-editor";
    rev = version;
    sha256 = "135iq0r5mnfl330fl4pmpq6474mw5nn4qc69yag8jf6b3rrjnq44";
  }) + /rust;
  syntect = import ./syntect.nix { xiSrc = src; inherit rustPlatform; };
in
rustPlatform.buildRustPackage {
  name = "xi";
  version = version;

  buildInputs = if withSyntax == true then [syntect] else [];

  cargoSha256 = "1x2hzbdhjhjcrnzbb0nk2fim49gb1hva1d9vjwvd68vi9j187dm9";
}
