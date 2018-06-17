{pkgs ? import <nixpkgs> {}, ...}:

with pkgs;
rec {
  cquery = callPackage ./tools/cquery {};
  languageclient-neovim = callPackage ./vim-plugins/languageclient {};
  mdv = callPackage ./mdv { pythonPackages = python27Packages; };
  nyancat = callPackage ./nyancat {};
  spotify = callPackage ./spotify { inherit (gnome2) GConf; libgcrypt = libgcrypt_1_5; libpng = libpng12;};
  xi = callPackage ./editors/xi {};
  xi-term = callPackage ./editors/xi-term { inherit xi; };
  fonts = {
    head-up-daisy = callPackage ./fonts/headupdaisy {};
  };
}
