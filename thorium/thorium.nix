{
  libglvnd,
  libgbm,
  lib,
  stdenv,
  fetchurl,
  wrapGAppsHook,
  dpkg,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libX11,
  libXScrnSaver,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXtst,
  libdrm,
  libnotify,
  libpulseaudio,
  libuuid,
  libxcb,
  libxshmfence,
  mesa,
  nspr,
  nss,
  pango,
  udev,
  xdg-utils,
  libxkbcommon,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "thorium";
  version = "130.0.6723.174";

  src = fetchurl (import ./src.nix);

  nativeBuildInputs = [
    dpkg
    makeWrapper
    wrapGAppsHook
  ];

  buildInputs = [
    libglvnd
    libgbm
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libdrm
    libnotify
    libpulseaudio
    libuuid
    libxcb
    libxshmfence
    mesa
    nspr
    nss
    pango
    udev
    libxkbcommon
  ];

  unpackPhase = ''
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner
  '';

  # No need to patch files that don't exist yet
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/opt/chromium.org/thorium
    if [ -d ./opt/chromium.org/thorium ]; then
      cp -a ./opt/chromium.org/thorium/* $out/opt/chromium.org/thorium/
    elif [ -d ./opt/thorium ]; then
      cp -a ./opt/thorium/* $out/opt/chromium.org/thorium/
    fi
    makeWrapper "$out/opt/chromium.org/thorium/thorium" "$out/bin/thorium" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PATH : "${xdg-utils}/bin" \
      --add-flags "--no-sandbox"
    if [ -f $out/opt/chromium.org/thorium/chromedriver ]; then
      makeWrapper "$out/opt/chromium.org/thorium/chromedriver" "$out/bin/chromedriver" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
    fi
    if [ -f $out/opt/chromium.org/thorium/thorium_shell ]; then
      makeWrapper "$out/opt/chromium.org/thorium/thorium_shell" "$out/bin/thorium-shell" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
        --add-flags "--no-sandbox"
    fi
    if [ -d ./usr/share/applications ]; then
      mkdir -p $out/share/applications
      cp ./usr/share/applications/thorium-browser.desktop $out/share/applications/ || true
      
      for file in $out/share/applications/thorium-browser.desktop; do
        if [ -f "$file" ]; then
          substituteInPlace $file \
            --replace "/opt/chromium.org/thorium/thorium" "$out/bin/thorium" \
            --replace "/opt/chromium.org/thorium/" "$out/opt/chromium.org/thorium/" \
            --replace "/opt/thorium/thorium" "$out/bin/thorium" \
            --replace "/opt/thorium/" "$out/opt/chromium.org/thorium/" \
            --replace "Exec=/usr/bin/thorium-browser" "Exec=thorium" \
            --replace "Exec=/usr/bin/thorium-browser" "Exec=thorium" \
            --replace "Icon=thorium-browser" "Icon=thorium" 
        fi
      done
    fi
    
    if [ -d ./usr/share/icons ]; then
      mkdir -p "$out/share/icons"
      cp -r ./usr/share/icons/* "$out/share/icons/" || true
    else
      for i in 16 24 32 48 64 128 256; do
        if [ -f "$out/opt/chromium.org/thorium/product_logo_''${i}.png" ]; then
          mkdir -p "$out/share/icons/hicolor/''${i}x''${i}/apps"
          cp "$out/opt/chromium.org/thorium/product_logo_''${i}.png" "$out/share/icons/hicolor/''${i}x''${i}/apps/thorium.png"
        fi
      done
    fi

    runHook postInstall
  '';

  postFixup = ''
    for file in $(find $out/opt/chromium.org/thorium -type f -executable); do
      if [ -f "$file" ]; then
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      fi
    done
  '';

  meta = with lib; {
    description = "Chromium fork with JPEG XL support, performance and privacy patches";
    homepage = "https://thorium.rocks/";
    license = licenses.bsd3;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ qxrein ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "thorium";
  };
}