{stdenv, fetchFromGitHub}:

stdenv.mkDerivation {
  name = "nyancat";

  src = fetchFromGitHub {
    owner = "klange";
    repo = "nyancat";
    rev = "e5a3a2a051b64c5bb783ecfeca4945ff3ae7f239";
    sha256 = "1kfjlv4g4v7sni3i17lifqn6agp2j2dv3phlx2vz920svcq1vnba";
  };

  hardeningDisable = ["all"];

  installPhase = ''
    mkdir -p $out/bin
    cp src/nyancat $out/bin/nyancat
    '';
}
