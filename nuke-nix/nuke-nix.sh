#!/usr/bin/env bash

if [ $(id -u) -ne 0 ]; then
	echo 'need root'
	exit 1
fi

echo 'stopping nix-daemon'
systemctl disable --now nix-daemon
rm /etc/systemd/system/nix-daemon.service
echo 'removing Nix'
rm -rf /nix
rm /etc/profile.d/nix{,-daemon}.sh
rm -r /etc/nix
echo 'removing groups created by Nix'
groupdel -f nix-users
groupdel -f nixbld
echo 'removing users created by Nix'
for i in $(getent passwd | grep -Eo 'nixbld[0-9]+'); do
	userdel $i
done
echo 'most Nix stuff is removed now'
echo 'however, you need to manually remove Nix code from /etc/zshrc /etc/bashrc and /etc/bash.bashrc'