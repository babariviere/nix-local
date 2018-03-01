{src, rustPlatform}:

rustPlatform.buildRustPackage {
  version = "0.1.36";
  name = "languageclient";

  src = src;
  cargoSha256 = "";
  depsSha256 = "";
}
