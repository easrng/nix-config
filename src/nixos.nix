let
  sources = import ../npins;
  pkgs = import sources.nixpkgs {
  };
  lib = import (sources.nixpkgs + "/nixos/lib");
  evalConfig = import (sources.nixpkgs + "/nixos/lib/eval-config.nix");
in
evalConfig {
  modules = [
    ./configuration.nix
  ];
}
