{
  config,
  pkgs,
  username,
  ...
}:

let
  editor = "nvim";
  dotfiles = "${config.home.homeDirectory}/nixos/dotfiles";
  inherit (config.lib.file) mkOutOfStoreSymlink;
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
  };

  fonts.fontconfig.enable = true;

  home.file.".Xresources" = {
    source = mkOutOfStoreSymlink "${dotfiles}/Xresources";
    force = true;
  };

  xdg.configFile = {
    "nvim/init.lua".force = true;

    "dunst/dunstrc" = {
      source = mkOutOfStoreSymlink "${dotfiles}/dunst/dunstrc";
      force = true;
    };

    emacs = {
      source = mkOutOfStoreSymlink "${dotfiles}/emacs";
      recursive = true;
      force = true;
    };

    i3 = {
      source = mkOutOfStoreSymlink "${dotfiles}/i3";
      recursive = true;
      force = true;
    };

    "nvim/coc-settings.json" = {
      source = mkOutOfStoreSymlink "${dotfiles}/nvim/coc-settings.json";
      force = true;
    };

    "nvim/snippets" = {
      source = mkOutOfStoreSymlink "${dotfiles}/nvim/snippets";
      recursive = true;
      force = true;
    };

    wallpapers = {
      source = mkOutOfStoreSymlink "${dotfiles}/wallpapers";
      recursive = true;
      force = true;
    };
  };

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
        gitsigns-nvim
        gruber-darker-nvim
        luasnip
        plenary-nvim
        telescope-nvim
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
