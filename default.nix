{pkgs}:
pkgs.stdenv.mkDerivation {
  pname = "db-main";
  version = "1.0";

  src = pkgs.requireFile {
    name = "dbm-1102-linux-amd64-setup.tar.gz";
    url = "https://projects.info.unamur.be/dbmain/files/dbm-1102-linux-amd64-setup.tar.gz";
    hash = "sha256-j2HmBpM33HNKxviGsiQynslDzU2vvYiGEb2AY3PLMpY=";
  };

  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.patchelf
    pkgs.gnutar
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
    tar xf $src -C $out

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
