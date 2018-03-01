{ stdenv, waf, python, fetchFromGitHub, llvmPackages_5 }:

stdenv.mkDerivation rec {
  name = "cquery-${version}";
  version = "v20180215";

  src = fetchFromGitHub {
    owner = "cquery-project";
    repo = "cquery";
    rev = "${version}";
    sha256 = "1r9qnc9v0azcj90j4gzxg3q89b83ysi2w9rg60vlm4c6yljjy0lw";
    fetchSubmodules = true;
  };

  buildInputs = [ python llvmPackages_5.clang llvmPackages_5.llvm ];
  CXXFLAGS="-I${llvmPackages_5.clang-unwrapped}/include";
  configurePhase = ''
    unset CXX
    export LIBCLANG_LIBDIR=${llvmPackages_5.clang.cc}/lib
    python waf configure --prefix=$out --clang-prefix=${llvmPackages_5.clang} --llvm-config=${llvmPackages_5.llvm}/bin/llvm-config
    '';

  buildPhase = ''
    python waf build
    '';

  installPhase = ''
    python waf install
    '';

  meta = {
    platforms = stdenv.lib.platforms.unix;
  };
}
