# Windows 10 KVM starter

## Info

* Files get installed to ~/.GermanBread/vm-starter
* Everything can be uninstalled by double-clicking `uninstall.sh` in the directory mentioned above
* `-fs` parameter for fullscreen
* The shortcut has a submenu (accessed by right-clicking it)

## Warning

* This script assumes a vm named "win10"
* Your password gets cached in /tmp/
* looking-glass and scream are required to be set up
* scream will be running via virbr0 and port 4010
* This script uses GUI tools

## Okay, I read the warning, how do I use this?

Paste `curl -s https://raw.githubusercontent.com/GermanBread/Bash-Scripts/master/windows-vm-starter/windows_vm_starter.sh | bash` in terminal and have fun!
