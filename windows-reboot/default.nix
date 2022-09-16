{ pkgs, stdenv, ... }:

stdenv.mkDerivation rec {
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
    # cmd: notify-send
    libnotify
  ];
  pathEnv = builtins.concatStringsSep ":" (builtins.map (elm: "${elm}/bin") buildInputs);
  installPhase = ''
    mkdir -p $out/bin $out/share/{icons,applications}

    cat << EOF >pkg/windows-reboot
    #!${pkgs.bash}/bin/bash
    export PATH=/run/wrappers/bin:${pathEnv}
    ### end patch ###
    
    $(cat pkg/windows-reboot)
    EOF
    install -m 555 pkg/windows-reboot $out/bin/windows-reboot

    install -m 555 pkg/windows-reboot.desktop $out/share/applications
    install -m 444 windows10_reboot.png $out/share/icons
  '';
}