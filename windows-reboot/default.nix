{ pkgs, stdenv, ... }:

stdenv.mkDerivation {
  name = "Windows reboot script";
  src = ./.;
  buildInputs = with pkgs; [
    # cmd: tput
    ncurses
    # cmd: pkexec
    polkit
    # cmd: efibootmgr
    efibootmgr
    # cmd: id
    coreutils
  ];
  installPhase = ''
    mkdir -p $out/bin $out/share/{icons,applications}

    install -m 555 pkg/windows-reboot $out/bin
    install -m 555 pkg/windows-reboot.desktop $out/share/applications
    install -m 444 windows10_reboot.png $out/share/icons
  '';
}