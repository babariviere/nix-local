{pkgs ? import <nixpkgs> {}}:

with pkgs;
let
  buildInputs = [
    cmake
    bison
    flex
    fuse
    pkgconfig
    cairo
    freetype
    fontconfig
    mesa
    libtiff
    ];
  userenv = buildFHSUserEnv {
    name = "env";
    runScript = ''
      make
      '';
    targetPkgs = pkgs:
      (buildInputs ++ 
      [
        gnumake
        glibc_multi
        ]);
  };
  in

clangMultiStdenv.mkDerivation {
  name = "darling";
  version = "master";

  src = fetchFromGitHub {
    owner = "darlinghq";
    repo = "darling";
    rev = "d2cc5fa748003aaa70ad4180fff0a9a85dc65e9b";
    sha256 = "08z9qx7f58aisfn6iblwjyjlp51zk3l959vmg3s72wjgblwl9lrz";
    fetchSubmodules = true;
  };

  buildPhase = ''
    ${userenv}/bin/${userenv.name}
    '';

  nativeBuildInputs = buildInputs;

  doCheck = false;
  hardeningDisable = [ "all" ];
}
