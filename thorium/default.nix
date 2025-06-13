{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; }, appimageTools ? pkgs.appimageTools, fetchurl ? pkgs.fetchurl }:

let
  pname = "thorium";
  version = "130.0.6723.174";

  src = fetchurl {
    url = "https://github.com/Alex313031/thorium/releases/download/M${version}/Thorium_Browser_${version}_AVX2.AppImage";
    hash = "sha256-Ej7OIdAjYRmaDlv56ANU5pscuwcBEBee6VPZA3FdxsQ=";
  };

  app = appimageTools.wrapType2 {
    inherit pname version src;
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "thorium";
    exec = "${app}/bin/thorium-core --ozone-platform=wayland %U";
    icon = "thorium";
    desktopName = "Thorium Browser";
    comment = "Privacy-focused Chromium fork";
    categories = [ "Network" "WebBrowser" ];
    mimeType = "text/html;x-scheme-handler/http;x-scheme-handler/https;";
    startupWMClass = "Thorium"; # <--- THIS is important
  };
  
in

pkgs.symlinkJoin {
  name = "thorium";
  paths = [ app desktopItem ];
}
