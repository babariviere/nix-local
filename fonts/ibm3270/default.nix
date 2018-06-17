{stdenv, fetchurl, unzip}:

let
  version = "1.2.23";
  commit = "d250fd9";
in
stdenv.mkDerivation {
  name = "ibm3270";
  version = version;

  src = fetchurl {
    url = "https://github.com/rbanffy/3270font/releases/download/${version}/3270_fonts_${commit}.zip";
    sha256 = "1dipp06szhkcjnvbbq16bjqwmdb9llscbzi4gf1fgbxki1827xww";
  };

  setSourceRoot = "sourceRoot=`pwd`";

  buildInputs = [unzip];

  phases = ["unpackPhase" "installPhase"];

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    find . -name "*.otf" -exec cp -v {} $out/share/fonts/opentype \;
    '';

}
