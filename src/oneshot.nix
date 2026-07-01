{
  stdenv,
  lib,
  requireFile,
  makeWrapper,
  qt6,
  goldberg-emu,
  libGL,
  openal,
  libxcrypt-legacy,
  libxkbcommon,
  glibc,
  zlib,
}:

stdenv.mkDerivation {
  name = "oneshot-bin";

  src = requireFile {
    name = "oneshot-src";
    hashMode = "recursive";
    sha256 = "08fjnc6ppnhxjz8j7rhn93ckaj8320q40s5v3cdywsvgspl5cbb4";
    message = ''
      OneShot not found.
      1. download oneshot from steam
      2. in a shell, execute:
         nix store add-path /path/to/steamapps/common/OneShot --name 'oneshot-src'
    '';
    meta.license = [ ];
  };

  buildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p $out/oneshot
    cp -r $src"/"* $out/oneshot
    rm -rf $out/oneshot/{libcrypt.so.1,libopenal.so.1,librt.so.1,libstdc++.so.6,libsteam_api.so,libxkbcommon.so.0,libxkbcommon-x11.so.0,libz.so.1}
    mkdir -p $out/share/icons
    ln -s $out/oneshot/Graphics/Icons/item_start_lightbulb.png $out/share/icons/oneshot.png
    mkdir -p $out/share/applications
    printf '[Desktop Entry]\nName=OneShot\nExec=%s\nIcon=oneshot\nTerminal=false\nType=Application\nCategories=Game;\n' $out/bin/oneshot >$out/share/applications/oneshot.desktop
    chmod a+x $out/share/applications/oneshot.desktop
    makeWrapper $out/oneshot/steamshim $out/bin/oneshot \
      --run "cd $out/oneshot" \
      --prefix PATH : ${lib.makeBinPath [ qt6.qttools ]} \
      --prefix LD_LIBRARY_PATH ":" ${
        lib.makeLibraryPath [
          goldberg-emu
          libGL
          openal
          libxcrypt-legacy
          libxkbcommon
          stdenv.cc.cc.lib
          glibc
          zlib
        ]
      }
    makeWrapper $out/oneshot/_______ $out/bin/_______ \
      --run "cd $out/oneshot" \
      --prefix PATH : ${lib.makeBinPath [ qt6.qttools ]} \
      --prefix LD_LIBRARY_PATH ":" ${
        lib.makeLibraryPath [
          goldberg-emu
          libGL
          openal
          libxcrypt-legacy
          libxkbcommon
          stdenv.cc.cc.lib
          glibc
          zlib
        ]
      }
  '';
}
