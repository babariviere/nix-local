{pkgs ? import <nixpkgs> {}}:

with pkgs;
{
  cquery = callPackage ./tools/cquery {};
  LanguageClient-neovim = callPackage ./vim-plugins/languageclient {};
}
