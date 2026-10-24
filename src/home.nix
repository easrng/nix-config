let
  sources = import ../npins;
in
{
  config,
  pkgs,
  lib,
  ...
}:

let
  overrideIfUnchanged = import ./override-if-unchanged.nix { inherit pkgs; };

  keepSrc = [
    (pkgs.callPackage ./oneshot.nix {
    })
    (pkgs.callPackage "${
      pkgs.fetchgit {
        url = "https://tangled.org/easrng.net/adobe-dng-converter";
        rev = "d24559afc47e97eaa1cc5aab97be2b7bd3786fb3";
        hash = "sha256-8hDxZrXtM6B/OmTtdJyW9JhPLxsTpVzVz811fYtRU48=";
      }
    }/adobe-dng-converter.nix" { })
    (pkgs.callPackage (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/Misaka13514/flake/e409750c5926543c9b8c80c1f91d0bb8c561c312/packages/ida-pro.nix";
      name = "ida-pro.nix";
      sha256 = "sha256-pUhFUKkmr13DQHz9S82ZnmSL8kiPat8ceHuvTNmIVNo=";
    }) { })
  ];
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "me";
  home.homeDirectory = "/home/me";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    (map (
      pkg:
      (builtins.foldl' (acc: elem: builtins.getAttr elem acc) pkgs (
        builtins.filter (e: builtins.typeOf e == "string") (builtins.split "\\." pkg)
      ))
    ) (lib.importJSON ../packages.json))
    ++ keepSrc
    ++ (with pkgs; [
      (overrideIfUnchanged {
        path = "pkgs/by-name/ha/handbrake/package.nix";
        pathHash = "fba7b57f3af9b6f58f031d4b233285b2c6b99b1234356f6fc7ac90a5d91eb6a7";
        url = "https://github.com/SolidEva/nixpkgs/raw/f6064193720a72fc1e37527ca0119b265486397d/pkgs/by-name/ha/handbrake/package.nix";
        urlHash = "sha256-9ShrevUa49RPvhHmxRnuBXPkf4VDyWzi/tPL+2mOxsk=";
      })
      (callPackage ./breeze-noshadow.nix {
      })
      (callPackage ./opencode-sandboxed.nix {
      })
      (runCommand "kept-sources"
        { srcs = "${builtins.concatStringsSep "\n" (builtins.map (f: f.src.outPath) keepSrc)}"; }
        ''
          mkdir -p $out/nix-support
          printf "%s" "$srcs" >$out/nix-support/sources
        ''
      )
    ]);

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = rec {
    GOPATH = "$HOME/Code/go";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_BIN_HOME = "$HOME/.local/bin";
    PNPM_HOME = "${XDG_DATA_HOME}/pnpm";
    DOTNET_ROOT = "${pkgs.dotnet-runtime_8}";
    # NIXOS_OZONE_WL = "1";
  };
  home.sessionPath = [
    "$HOME/.yarn/bin"
    "${config.home.sessionVariables.PNPM_HOME}"
    "${config.home.sessionVariables.GOPATH}/bin"
    "${config.home.sessionVariables.XDG_BIN_HOME}"
    "$HOME/.dotnet/tools"
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      # emoji = [ "Telegram Color Emoji" ];
    };
  };
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "ida-pro"
      "adobe-dng-converter"
    ];

}
