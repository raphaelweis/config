{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Fix suspend (lenovo yoga slim 7 issue)
    # https://gitlab.freedesktop.org/drm/amd/-/issues/2812
    initrd.prepend = lib.mkOrder 0 [
      "${pkgs.fetchurl {
        url = "https://gitlab.freedesktop.org/drm/amd/uploads/9fe228c7aa403b78c61fb1e29b3b35e3/slim7-ssdt";
        sha256 = "sha256-Ef4QTxdjt33OJEPLAPEChvvSIXx3Wd/10RGvLfG5JUs=";
        name = "slim7-ssdt";
      }}"
    ];
    kernelParams = [
      "rtc_cmos.use_acpi_alarm=1"
      "amd_pstate=active"
      "amd_pstate.shared_mem=1"
      "nohibernate"
      "acpi_sleep=nonvs"
    ];
  };

  hardware = {
    cpu.amd.updateMicrocode = true;

    # Fix for the speakers not working.
    # https://github.com/darinpp/yoga-slim-7
    firmware =
      let
        tas = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/darinpp/yoga-slim-7/main/lib/firmware/TAS2XXX38BB.bin";
          sha256 = "sha256-qyZxBlnWEnrgbh0crgFf//pKZMTtCqh+CkA+pUNU/+E=";
          name = "TAS2XXX38BB.bin";
        };
        tia = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/darinpp/yoga-slim-7/main/lib/firmware/TIAS2781RCA4.bin";
          sha256 = "sha256-Zj7mwS8DsBinZ8BYvcySc753Aq/xid7vAeQOH/oir6Q=";
          name = "TIAS2781RCA4.bin";
        };
      in
      [
        (pkgs.runCommand "subwoofers" { } ''
          	 mkdir -p $out/lib/firmware/
          	 cp ${tas} $out/lib/firmware/TAS2XXX38BB.bin
          	 cp ${tia} $out/lib/firmware/TIAS2781RCA4.bin
          	 '')
        pkgs.wireless-regdb
      ];
  };

  networking.hostName = "raph-laptop";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xserver.xkb = {
      layout = "us";
      variant = "intl";
    };

    # tlp config on laptop to increase battery life.
    tlp = {
      enable = false;
      settings = {
        DEVICES_TO_ENABLE_ON_STARTUP = "wifi bluetooth";
      };
    };
    power-profiles-daemon.enable = false; # required for tlp to work.
  };

  console.keyMap = "us-acentos";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableLsColors = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      promptInit = ''
        setopt PROMPT_SUBST
        PROMPT='%F{yellow}%~%f $ '

        export EDITOR=nvim
      '';
    };
  };

  users.users."raph" = {
    isNormalUser = true;
    description = "Raphaël Weis";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "video"
    ];
    packages = with pkgs; [
      neovim
      inputs.zen-browser.packages."x86_64-linux".twilight
      ghostty
      gnomeExtensions.color-picker
      herdr
      tree-sitter
      stylua
      nixfmt
      lua-language-server
    ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    gh
    gcc
  ];

  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
