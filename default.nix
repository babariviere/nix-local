{pkgs ? import <nixpkgs> {}}:

with pkgs;
{
  cquery = callPackage ./tools/cquery {};
  languageclient-neovim = callPackage ./vim-plugins/languageclient {};
}
