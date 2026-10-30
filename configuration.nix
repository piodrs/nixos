{
  hostname,
  inputs,
  pkgs,
  username,
  ...
}:

let
  adachi = inputs.adachi.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    configFile = ./adachi/config.h;
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    nftables.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "America/Recife";

  i18n = {
    defaultLocale = "pt_BR.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  console.keyMap = "br-abnt2";

  users.users.${username} = {
    isNormalUser = true;
    description = "Asmita";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
  };

  virtualisation.docker.enable = true;

  services = {
    displayManager.ly.enable = true;

    xserver = {
      enable = true;
      xkb = {
        layout = "br";
        variant = "";
      };
      windowManager.i3.enable = true;
      windowManager.session = [
        {
          name = "adachi";
          start = ''
            ${adachi}/bin/adachi &
            waitPID=$!
          '';
        }
      ];
    };

    printing.enable = true;
    flatpak.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
  };

  environment.systemPackages = [ adachi ];

  programs = {
    dconf.enable = true;
    firefox.enable = true;
    steam.enable = true;
    thunar.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  security.rtkit.enable = true;

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  system.stateVersion = "26.05";
}
