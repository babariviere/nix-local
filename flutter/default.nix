{pkgs ? import <nixpkgs> {}}:
with pkgs;

let
 
  sdk_version = "2.0.0-dev.26.0";
 
in
 
stdenv.mkDerivation rec {
 
  name = "flutter-${version}";
  version = "0.1.7";
 
  src = fetchgit {
    url = "https://github.com/flutter/flutter.git";
    rev = "v${version}";
    sha256 = "1zpwfqicpf3i46bwsgkgv2v51hr0hmlz7bcf1z6hd4p1q55nqyvq";
    leaveDotGit = true;
  };
 
  buildInputs = [
    androidsdk
    expat
    git
    which
  ];

  buildPhase = ''
    cd ${src}/packages/flutter_tools
    pub upgrde --verbosity=error --no-packages-dir
    '';
 
  shellHook = ''
    # Clear out any cruft and unpack the source.
    rm -r flutter
    unpackPhase
    cd flutter
    # Fix /usr/bin issues.
    for FILE in \
      bin/flutter \
      bin/internal/update_dart_sdk.sh
    do
      patchShebangs $FILE
    done
    # Set up Nix-built dart.
    mkdir -p bin/cache
    ln -s ${dart_dev} bin/cache/dart-sdk
    # Make update_dart_sdk happy.
    cat bin/cache/dart-sdk/version > bin/internal/dart-sdk.version
    cat bin/cache/dart-sdk/version > bin/cache/dart-sdk.stamp
    # Add flutter to the path.
    export PATH=$(pwd)/bin:$PATH
    # The first run fails.
    flutter doctor
    # Fix up executables with the right paths.
    for FILE in \
      bin/cache/artifacts/engine/linux-x64/dart-sdk/bin/dart \
      bin/cache/artifacts/engine/linux-x64/flutter_tester
    do
      patchelf \
        --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath $libPath \
        $FILE
    done
    ## This run should be better.
    flutter doctor
  '';
 
  libPath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc expat ];
 
  meta = with stdenv.lib; {
    description = "Flutter is a new mobile app SDK to help developers and designers build modern mobile apps for iOS and Android.";
    homepage = https://flutter.io;
  };
}
