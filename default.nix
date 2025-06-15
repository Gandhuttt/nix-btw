{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; } }:

let
 callPackage = pkgs.callPackage;
in
{
  
  thorium = import ./thorium { inherit callPackage; };
  # thorium = callPackage ./thorium/thorium.nix;
  # thorium = with pkgs; with pkgs.xorg; import ./thorium/thorium.nix { inherit 
  #   lib 
  #   libgbm
  #   stdenv 
  #   fetchurl 
  #   wrapGAppsHook 
  #   dpkg 
  #   alsa-lib 
  #   at-spi2-atk 
  #   at-spi2-core 
  #   atk 
  #   cairo 
  #   cups 
  #   dbus 
  #   expat 
  #   fontconfig 
  #   freetype 
  #   gdk-pixbuf 
  #   glib 
  #   gtk3 
  #   libX11 
  #   libXScrnSaver 
  #   libXcomposite 
  #   libXcursor 
  #   libXdamage 
  #   libXext 
  #   libXfixes 
  #   libXi 
  #   libXrandr 
  #   libXrender 
  #   libXtst 
  #   libdrm 
  #   libnotify 
  #   libpulseaudio 
  #   libuuid 
  #   libxcb 
  #   libxshmfence 
  #   mesa 
  #   nspr 
  #   nss 
  #   pango 
  #   udev 
  #   xdg-utils 
  #   libxkbcommon 
  #   makeWrapper
  # ;};

  
  # xpad = callPackage ./xpad/xpad.nix;
}