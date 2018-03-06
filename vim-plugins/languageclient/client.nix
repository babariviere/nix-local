{src, rustPlatform}:

rustPlatform.buildRustPackage {
  version = "0.1.36";
  name = "languageclient";

  src = src;
  cargoSha256 = "0c2sklpvab63a1f1mhcq9abq5m2srkj52ypq7dq44g8ngn2a05ka";
  depsSha256 = "";
}
