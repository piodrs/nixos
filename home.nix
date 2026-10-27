{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:

let
  editor = "nvim";
  dotfiles = "${config.home.homeDirectory}/nixos/dotfiles";

  dotfile = path: {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
    force = true;
  };

  mirror = paths: lib.genAttrs paths dotfile;

  dired-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "dired.nvim";
    version = inputs.dired-nvim.shortRev;
    src = inputs.dired-nvim;
    dependencies = [ pkgs.vimPlugins.nui-nvim ];
  };
in
{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";

    packages = with pkgs; [
      alsa-utils
      basedpyright
      clang-tools
      curl
      dmenu
      dunst
      eclipses.eclipse-java
      flameshot
      gcc
      gnumake
      gnutar
      i3status
      imagemagick
      iosevka
      komikku
      nil
      nixfmt
      nodejs
      prismlauncher
      python3
      ripgrep
      ruff
      rxvt-unicode
      simplescreenrecorder
      spotify
      tree-sitter
      typescript
      typescript-language-server
      unzip
      uv
      vlc
      vscodium
      xrdb
    ];

    file.".Xresources" = dotfile "Xresources";
  };

  fonts.fontconfig.enable = true;

  xdg.configFile = mirror [
    "dunst/dunstrc"
    "emacs"
    "i3"
    "nvim/coc-settings.json"
    "nvim/snippets"
    "wallpapers"
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    emacs = {
      enable = true;

      extraPackages =
        epkgs: with epkgs; [
          corfu
          envrc
          flymake-ruff
          gruber-darker-theme
          multiple-cursors
          nix-mode
          orderless
          reformatter
          typescript-mode
          yasnippet
        ];
    };

    feh.enable = true;

    git = {
      enable = true;

      settings = {
        user = {
          name = "piodrs";
          email = "piodfallen@gmail.com";
        };

        init.defaultBranch = "main";
        core.editor = editor;
      };
    };

    home-manager.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      withNodeJs = true;
      initLua = builtins.readFile ./dotfiles/nvim/init.lua;

      plugins = with pkgs.vimPlugins; [
        coc-nvim
        dired-nvim
        gitsigns-nvim
        gruber-darker-nvim
        luasnip
        vim-fugitive
        (nvim-treesitter.withPlugins (
          parsers: with parsers; [
            c
            cpp
            javascript
            nix
            python
            typescript
          ]
        ))
      ];
    };

    ranger.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings."github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };
}
