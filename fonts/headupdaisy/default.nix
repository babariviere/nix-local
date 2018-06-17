{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "head-up-daisy";

  src = fetchurl {
    url = "http://www17.plala.or.jp/xxxxxxx/00ff/x14y24pxHeadUpDaisy.ttf";
    sha256 = "0511bln7x4h85hldmz31c2srs3r5j4raa67hn631gwsypbsckfsy";
  };

  phases = [ "installPhase"];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp ${src} $out/share/fonts/truetype/x14y24pxHeadUpDaisy.ttf
  '';
}
