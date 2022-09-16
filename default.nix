{ pkgs ? import <nixpkgs> {}, ... }:

{
  windows-reboot = import ./windows-reboot { inherit pkgs; stdenv = pkgs.stdenv; };
}