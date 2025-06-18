{
  stdenv,
  lib,
  requireFile,
  makeWrapper,
  libsForQt5,
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

  src = /home/me/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/OneShot;

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
      --prefix PATH : ${lib.makeBinPath [ libsForQt5.qt5.qttools ]} \
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
