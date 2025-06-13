{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; } }:
{
  thorium = import ./thorium { inherit pkgs; };
}