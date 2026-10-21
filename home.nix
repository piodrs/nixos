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

  st = pkgs.st.override {
    conf = builtins.readFile ./st/config.h;
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
      feh
      gcc
      gnutar
      i3status
      imagemagick
      iosevka
      neovim
      nil
      nixfmt
      nodejs
      eclipses.eclipse-java
      python3
      ripgrep
      ruff
      st
      tree-sitter
      typescript
      typescript-language-server
      prismlauncher
      komikku
      vlc
      ranger
      simplescreenrecorder
      gnumake
      unzip
      uv
      vscodium
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

  fonts.fontconfig.enable = true;

  programs = {
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
          gruber-darker-theme
          nix-mode
          orderless
          yasnippet
        ];
    };

    home-manager.enable = true;
  };
}
