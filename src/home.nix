{
  config,
  pkgs,
  lib,
  ...
}:

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
    ++ (with pkgs; [
      hyfetch
      (callPackage ./breeze-noshadow.nix {
      })
      (callPackage ./oneshot.nix {
      })
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
}
