{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  pname = "breeze-noshadow";
  version = "0";
  src = "${pkgs.kdePackages.libplasma}/share/plasma/desktoptheme/default";
  installPhase = ''
    mkdir -p $out/share/plasma/desktoptheme
    cp -r $src $out/share/plasma/desktoptheme/breeze-noshadow
    chmod -R u+w $out/share/plasma/desktoptheme
    printf '%s' '{"KPlugin":{"Authors":[],"Category":"","Description":"Breeze by the KDE VDG (no taskbar shadow)","EnabledByDefault":true,"Id":"default-noshadow","Name":"Breeze noshadow","Version":"0"},"X-Plasma-API":"5.0"}' >$out/share/plasma/desktoptheme/breeze-noshadow/metadata.json
    for item in $out/share/plasma/desktoptheme/breeze-noshadow/{opaque/,solid/,translucent/,}widgets/panel-background.svgz; do
      cat $item | gunzip | sed 's/id="shadow-/opacity="0" id="shadow-/g' | gzip >$item.tmp
      mv $item.tmp $item
    done
  '';
}
