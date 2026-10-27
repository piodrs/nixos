{ inputs, pkgs, username, ... }:

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
    hostName = "nixos";
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

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "br";
        variant = "";
      };
      displayManager.lightdm.enable = true;
      desktopManager.xfce.enable = true;
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
    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };

  security.rtkit.enable = true;

  environment.systemPackages = [ adachi ];

  virtualisation.docker.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    description = "Asmita";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
  };

  programs = {
    firefox.enable = true;
    steam.enable = true;
  };

  system.stateVersion = "26.05";
}
