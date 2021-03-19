#!/bin/bash

# define out config path
config_path=~/.GermanBread/vm-starter
shortcut_path=~/.local/share/applications
icon_path=~/.local/share/icons/hicolor/512x512/apps
mkdir -p $config_path
mkdir -p $shortcut_path
mkdir -p $icon_path

base_dl="https://raw.githubusercontent.com/GermanBread/Bash-Scripts/master/windows-vm-starter"

script_name="windows_vm_starter.sh"
icon_name="windows10.png"
shortcut_name="Windows.desktop"

# Logging
log () {
    printf ":: $1\n"
}
error () {
    tput setaf 9
    printf "E:: "
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
    notif "$1"
}

# Check for Curl
if [ $0 == bash ]; then
    # Install
    logandnotif "Installing"
    log "Installing script to $config_path"
    wget -qO $config_path/$script_name $base_dl/$script_name
    chmod +x $config_path/$script_name
    log "Installing icon to $icon_path"
    wget -qO $icon_path/$icon_name $base_dl/$icon_name
    log "Installing .desktop to $shortcut_path"
    wget -qO $shortcut_path/$shortcut_name $base_dl/$shortcut_name

    logandnotif "Installation done. A .desktop file has been added"

    exit 0
fi

if [ $1 == "-h" ]; then
    printf " -fs\tto capture input on start and for looking-glass to start in fs\n"
    exit
fi
if [ $1 == "--help" ]; then
    printf " -fs\tto capture input on start and for looking-glass to start in fs\n"
    exit
fi

# Check if the script runs as root
if [ $(whoami) == root ]; then
    error "Do not run as root\n"
    exit 1
fi

# Update
# Note: If the script or the .desktop file gets updated seperately, stuff might break
if [ $1 == "-up" ]; then
    logandnotif "Updating script"
    wget -qO $config_path/$script_name $base_dl/$script_name

    logandnotif "Updating desktop file"
    # Assume that the .desktop changed too
    wget -qO $shortcut_path/$shortcut_name $base_dl/$shortcut_name
    
    # Assume that the icon changed too
    logandnotif "Updating icon"
    wget -qO $icon_path/$icon_name $base_dl/$icon_name

    logandnotif "Update done"
    exit 0
fi

# Uninstall
if [ $1 == "-un" ]; then
    logandnotif "Deleting $config_path"
    rm -r $config_path

    logandnotif "Deleting desktop file"
    rm $shortcut_path/$shortcut_name
    
    logandnotif "Deleting icon"
    rm $icon_path/$icon_name

    logandnotif "Uninstall done"
    exit 0
fi

# Get the password
if [ -e /tmp/vminitpassword ]; then
    pass=$(cat /tmp/vminitpassword);
else
    pass=$(zenity --password --name "Windows 10 VM starter");
fi
    
# Check if the password is valid
log "Checking password\n"
if [[ $(echo $pass | sudo -Skp "Checking for root" whoami) != "root" ]]; then
    errorandnotif "Failed to check password!"
	# Delete the password file, it might be faulty
	rm /tmp/vminitpassword
    exit 1
fi

if [ ! -e /tmp/vminitpassword ]; then
	# Create a dummy file
	touch /tmp/vminitpassword
	# Then immediately chmod it to 600
	chmod 600 /tmp/vminitpassword
	# Write the password to the file
	echo $pass > /tmp/vminitpassword
fi

# Code
log "Looking for a script instance to replace\n"
log "Killing any leftover processes\n"
startresult=1 # Assign a generic value above 0
pkill scream
if [[ $? < $startresult ]]; then
    startresult=$?
fi
pkill looking-glass-c
if [[ $? < $startresult ]]; then
    startresult=$?
fi
if [[ $startresult == "0" ]]; then
    logandnotif "Replaced older instance"
else
    logandnotif "Starting VM"
fi
echo $pass | sudo -S virsh start win10
if [[ $? == "0" ]]; then
    log "Started Windows 10 VM\n"
else
    log "VM is already running.\n"
    sleep 1 # Add artificial delay to prevent the restart detection from failing
fi

log "Starting scream\n"
scream -i virbr0 -p 4010 -o pulse -v & disown

# Make the shm file world-readable
echo $pass | sudo chmod 771 /dev/shm/looking-glass

log "Starting looking-glass\n"
if [ $1 == "-fs" ]; then
	looking-glass-client -F opengl:vsync yes spice:captureOnStart yes
else
	looking-glass-client
fi

sleep .1 # Add artificial delay to prevent the restart detection from failing

log "Killing scream\n"
pkill scream
# If scream is already dead, this indicates that the script has been restarted
if [[ $? == "1" ]]; then
    log "This script has been replaced by another instance\n"
    exit
fi

log "Stopping VM\n"
echo $pass | sudo virsh shutdown win10
if [[ $? == "0" ]]; then
    log "Stopped Windows 10 VM\n"
else
    log "VM is not running\n"
fi
logandnotif "Script exit"
