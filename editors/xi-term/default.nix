{rustPlatform, fetchFromGitHub, xi, writeText}:

rustPlatform.buildRustPackage rec {
  name = "xi-term";
  version = "master";

  src = fetchFromGitHub {
    owner = "xi-frontend";
    repo = "xi-term";
    rev = version;
    sha256 = "10qn9zw1gb0lm25d73c4wykhdipxjy9jmy7i5spbwcb47hz2prpy";
    fetchSubmodules = false;
  };

  buildInputs = [xi];
  #cargoSha256 = "0a23jl25x97365g17znwk4mxjq6gcfnnfpx8px9b6arvr57zfnzz";
  cargoVendorDir = ./vendor;

  cargoVendor = writeText "vendor" ''
    [source.crates-io]
    registry = 'https://github.com/rust-lang/crates.io-index'
    replace-with = 'vendored-sources'

    [source."https://github.com/xi-frontend/xrl"]
    git = "https://github.com/xi-frontend/xrl"
    branch = "master"
    replace-with = "vendored-sources"


    [source.vendored-sources]
    directory = '/${cargoVendorDir}'
    '';

  postUnpack = ''
      eval "$cargoDepsHook"
      cargoDepsCopy="${cargoVendorDir}"
      mkdir -p .cargo
      cat ${cargoVendor} > .cargo/config
      unset cargoDepsCopy
    '';

  XI_CORE="${xi}/bin/xi-core";
}
