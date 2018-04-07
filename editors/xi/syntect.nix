{rustPlatform, xiSrc}:

rustPlatform.buildRustPackage rec {
  name = "xi-syntect-plugin";
  version = "master";

  src = xiSrc + "/syntect-plugin";

  cargoSha256 = "1x2hzbdhjhjcrnzbb0nk2fim49gb1hva1d9vjwvd68vi9j187dm9";
}
