{
  config,
  pkgs,
  username,
  ...
}:

let
  editor = "nvim";
  dotfiles = "${config.home.homeDirectory}/nixos";
  inherit (config.lib.file) mkOutOfStoreSymlink;

  configDirectories = {
    dunst = "dunst";
    emacs = "emacs";
    i3 = "i3";
    nvim = "nvim";
    wallpapers = "wallpapers";
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
      feh
      flameshot
      gcc
      gnumake
      gnutar
      i3status
      imagemagick
      iosevka
      komikku
      neovim
      nil
      nixfmt
      nodejs
      prismlauncher
      python3
      ranger
      ripgrep
      rxvt-unicode
      ruff
      simplescreenrecorder
      tree-sitter
      typescript
      typescript-language-server
      unzip
      uv
      vlc
      vscodium
      xrdb
    ];

    sessionVariables = {
      EDITOR = editor;
      VISUAL = editor;
    };
  };

  xdg.configFile = builtins.mapAttrs (_: subpath: {
    source = mkOutOfStoreSymlink "${dotfiles}/${subpath}";
    recursive = true;
    force = true;
  }) configDirectories;

  home.file.".Xresources" = {
    source = mkOutOfStoreSymlink "${dotfiles}/Xresources";
    force = true;
  };

  fonts.fontconfig.enable = true;

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

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

    emacs = {
      enable = true;
      extraPackages =
        epkgs: with epkgs; [
          corfu
          envrc
          flymake-ruff
          gruber-darker-theme
          nix-mode
          orderless
          reformatter
          typescript-mode
          yasnippet
        ];
    };

    home-manager.enable = true;
  };
}
