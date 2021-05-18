#!/bin/bash

# define out config path
config_path=~/.GermanBread/windows-reboot
shortcut_path=~/.local/share/applications
icon_path=~/.local/share/icons/hicolor/512x512/apps
mkdir -p $config_path
mkdir -p $shortcut_path
mkdir -p $icon_path

base_dl="https://raw.githubusercontent.com/GermanBread/Bash-Scripts/master/windows-reboot"
script_name="windows_reboot.sh"
icon_name="windows10_reboot.png"
shortcut_name="Windows_reboot.desktop"

# Logging
log () {
    tput setaf 4
    tput bold
    printf "[ INFO ] "
    tput sgr0
    printf "$1\n";
}
error () {
    tput setaf 9
    tput bold
    printf "[ ERROR] "
    tput sgr0
    printf "$1\n"
}
notif () {
    notify-send "$1" -a "Windows VM starter"
}
logandnotif () {
    log "$1"
    notif "$1"
}
errorandnotif () {
    error "$1"
    notif "Error: $1"
}
helptext() {
    printf " -up\tto update this script\n"
    printf " -un\tto uninstall this script\n"
    printf " -r\tto immediately reboot after setting the next boot variable\n"
}

# Check for Curl
if [ $0 == bash ]; then
    # Install
    logandnotif "Installing"
    
    log "Installing script to $config_path"
    wget -qO "$config_path/$script_name" "$base_dl/$script_name"
    chmod +x "$config_path/$script_name"
    
    log "Installing icon to $icon_path"
    wget -qO "$icon_path/$icon_name" "$base_dl/$icon_name"
    
    log "Installing .desktop to $shortcut_path"
    wget -qO "$shortcut_path/$shortcut_name" "$base_dl/$shortcut_name"

    logandnotif "Installation done. A .desktop file has been created. You can start it via your app launcher"

    exit 0
fi

if [ $1 == "-h" ] || [ $1 == "--help" ]; then
    helptext
    exit 0
fi

# Check if the script runs as root
if [ $(whoami) == root ]; then
    error "Do not run as root"
    exit 1
fi

# Update
# Note: If the script or the .desktop file gets updated seperately, stuff might break
if [ $1 == "-up" ]; then
    log "Updating script"
    wget -qO $config_path/$script_name $base_dl/$script_name

    log "Updating desktop file"
    # Assume that the .desktop changed too
    wget -qO $shortcut_path/$shortcut_name $base_dl/$shortcut_name
    
    # Assume that the icon changed too
    log "Updating icon"
    wget -qO $icon_path/$icon_name $base_dl/$icon_name

    logandnotif "Update done"
    exit 0
fi

# Uninstall
if [ $1 == "-un" ]; then
    log "Deleting $config_path"
    rm -r "$config_path"

    log "Deleting desktop file"
    rm "$shortcut_path/$shortcut_name"
    
    log "Deleting icon"
    rm "$icon_path/$icon_name"

    logandnotif "Uninstall done"
    exit 0
fi

pass=$(zenity --password --name "Windows reboot script")
    
# Check if the password is valid
log "Checking password"
if [[ $(echo $pass | sudo -Skp "Checking for root" id -u) -ne 0 ]]; then
    errorandnotif "Failed to check password!"
    exit 1
fi

# Update checking
if [[ "$(cat $0)" != "$(curl "$base_dl/$script_name")" ]]; then
    logandnotif "Update available! Use the context menu to update"
fi

# Important code starts here
echo $pass | sudo -S efibootmgr -n 0000
if [ $1 = "-r" ]; then
    log "Config set. Rebooting..."
    systemctl reboot
else
    log "Config set. Next reboot will launch you into Windows"
fi