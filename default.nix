{ pkgs ? import <nixpkgs> {}, ... }:

{
  windows-reboot = pkgs.callPackage ./windows-reboot { inherit pkgs; };
}