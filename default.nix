{pkgs}:
pkgs.stdenv.mkDerivation {
  pname = "db-main";
  version = "1.0";

  #src = ./db-main;
  src = builtins.fetchurl {
    url = "https://projects.info.unamur.be/dbmain/files/dbm-1102-linux-amd64-setup.tar.gz";
    sha256 = "8f61e6069337dc734ac6f886b224329ec943cd4dafbd888611bd806373cb3296";
  };

  umpackCmd = "tar -xzf $src";

  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.patchelf
  ];

  buildInputs = [
    pkgs.stdenv.cc.cc
    pkgs.zlib
    pkgs.expat
    pkgs.gtk2-x11
    pkgs.pango.out
    pkgs.cairo
    pkgs.gdk-pixbuf
    pkgs.glib.out
    pkgs.xorg.libX11.out
    pkgs.xorg.libSM.out
    pkgs.libpng.out
  ];

  phases = ["installPhase"];

  installPhase = ''
    mkdir $out
    mkdir $out/bin
    mkdir $out/doc
    mkdir $out/java
    mkdir $out/plugins
    cp -r $src/bin/* $out/bin
    cp -r $src/doc/* $out/doc
    cp -r $src/java/* $out/java
    cp -r $src/plugins/* $out/plugins

    chmod +w $out/bin/db_main

    LIB_PATH=${pkgs.stdenv.cc.cc.lib}/lib:$out/bin:${pkgs.zlib}/lib:${pkgs.expat}/lib:${pkgs.gtk2-x11}/lib:${pkgs.pango.out}/lib:${pkgs.cairo}/lib:${pkgs.gdk-pixbuf}/lib:${pkgs.glib.out}/lib:${pkgs.xorg.libX11.out}/lib:${pkgs.xorg.libSM.out}/lib:${pkgs.libpng.out}/lib

    patchelf \
    --force-rpath \
    --set-interpreter ${pkgs.stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 \
    --set-rpath ${pkgs.stdenv.cc.libc}/lib:$LIB_PATH \
    $out/bin/db_main

    wrapProgram $out/bin/db_main \
      --prefix LD_LIBRARY_PATH : "$out/java/jre/lib/amd64/server:$LIB_PATH"
  '';
}
