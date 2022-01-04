#!/bin/sh

_root=~/.GermanBread/ani-cli-wrapper

rm -rf ${_root}
mkdir -p ${_root}
cp ani-cli-wrapper ${_root}/exec
chmod +x ${_root}/exec
ln -sf ${_root}/exec ~/.local/bin/ani-cli

git clone https://github.com/pystardust/ani-cli.git ${_root}/git &>/dev/null

echo -n "Default config at ${_root}/anirc : "
echo 'player_fn="mpv"' | tee ${_root}/anirc
echo "Uninstall: ani-cli --uninstall"