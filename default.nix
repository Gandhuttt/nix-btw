{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; } }:
{
  thorium = import ./thorium/thorium.nix { inherit pkgs; };
}