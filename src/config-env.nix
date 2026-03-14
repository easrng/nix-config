let
  sources = import ../npins;
  pkgs = import sources.nixpkgs { };
  home-manager = (import sources.home-manager) { };
  config-deps = [
    "src/config-env.nix"
    "npins/sources.json"
    "npins/default.nix"
  ];
  config-env-hash = pkgs.runCommand "config-env-hash" { } ''
    mkdir -p ${
      builtins.concatStringsSep " " (pkgs.lib.lists.uniqueStrings (map (f: builtins.dirOf f) config-deps))
    }
    ${builtins.concatStringsSep "\n" (map (f: "cp ${./.. + ("/" + f)} ${f}") config-deps)}
    sha256sum ${builtins.concatStringsSep " " config-deps} >$out
  '';
in
pkgs.writeText "env" ''
  export ENV_HASH="${config-env-hash}"
  export NIX_PATH="home-manager=${sources.home-manager}:nixpkgs=${sources.nixpkgs}"
  export PATH="${
    pkgs.lib.makeBinPath [
      home-manager.home-manager
      pkgs.bash
      pkgs.nixfmt
      pkgs.jq
      pkgs.coreutils
      pkgs.findutils
      pkgs.moreutils
      pkgs.lix
      pkgs.nixos-rebuild
      pkgs.systemd
    ]
  }:/run/wrappers/bin"
''
