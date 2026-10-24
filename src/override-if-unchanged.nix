{ pkgs }:
{
  path,
  pathHash,
  url,
  urlHash,
  args ? { },
}:
let
  nixpkgsFile = pkgs.path + "/${path}";
  currentHash = builtins.hashFile "sha256" nixpkgsFile;
  updated = builtins.fetchurl {
    name = builtins.baseNameOf path;
    inherit url;
    sha256 = urlHash;
  };
in
if currentHash == pkgs.lib.toLower pathHash then
  pkgs.callPackage updated args
else
  throw ''
    ${path} in nixpkgs has changed.
    Expected hash: ${pathHash}
    Actual hash:   ${currentHash}

    Remove the override or update its hashes.
  ''
