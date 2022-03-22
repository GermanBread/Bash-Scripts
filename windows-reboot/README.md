# Windows 10 reboot script

## Info

* Files get installed to ~/.GermanBread/windows-reboot
* The shortcut has a submenu (accessed by right-clicking it)
* This script depends on notify-send and zenity
* You need to adjust the bootnum saved in ~/.GermanBread/windows-reboot/bootnum to the actual bootnum of the Windows bootloader (acquire with `efibootmgr`). Default is 0000

## Okay, I read the warning, how do I use this?

Paste `curl -s https://raw.githubusercontent.com/GermanBread/Bash-Scripts/master/windows-reboot/windows_reboot.sh | bash` in terminal and have fun!