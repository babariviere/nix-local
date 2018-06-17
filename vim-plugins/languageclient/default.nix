{fetchFromGitHub, vimUtils, rustPlatform}:

let
    src = fetchFromGitHub {
      owner = "autozimu";
      repo = "LanguageClient-neovim";
      rev = "next";
      sha256 = "0lrvk55z05d6gs29hgs186yqmxynrxql06bmdd7xcbqyy46y02br";
    };
    client = import ./client.nix { inherit src rustPlatform; };
in
  vimUtils.buildVimPluginFrom2Nix { # created by nix#NixDerivation
    name = "LanguageClient-neovim-2018-01-18";
    src = src;
    dependencies = [];
    buildPhase = ''
      mkdir -p $out/share/vim-plugins/LanguageClient-neovim/bin
      cp ${client}/bin/languageclient $out/share/vim-plugins/LanguageClient-neovim/bin/languageclient
      '';
  }
