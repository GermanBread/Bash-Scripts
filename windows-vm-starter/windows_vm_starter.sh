#!/bin/bash

# define out config path
config_path=~/.GermanBread/vm-starter
shortcut_path=~/.local/share/applications
icon_path=~/.local/share/icons/hicolor/512x512/apps
password_path=/tmp/.$USER.vminitpassword
mkdir -p $config_path
mkdir -p $shortcut_path
mkdir -p $icon_path

base_dl="https://raw.githubusercontent.com/GermanBread/Bash-Scripts/master/windows-vm-starter"
script_name="windows_vm_starter.sh"
icon_name="windows10.png"
shortcut_name="Windows.desktop"

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
    printf " -fs\tto capture input on start and for looking-glass to start in fs\n"
    printf " -up\tto update this script\n"
    printf " -un\tto uninstall this script\n"
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

    log "Uninstall done"
    exit 0
fi

# Get the password
if [ -e $password_path ]; then
    pass=$(cat $password_path);
else
    pass=$(zenity --password --name "Windows 10 VM starter");
fi
    
# Check if the password is valid
log "Checking password"
if [[ $(echo $pass | sudo -Skp "Checking for root" whoami) != "root" ]]; then
    errorandnotif "Failed to check password!"
	# Delete the password file, it might be faulty
	rm $password_path
    exit 1
fi

# We want to store the password somewhere; Reason is that noone wants to reenter their password (maybe create a config file that disables this behaviour?)
if [ ! -e $password_path ]; then
	# Create a dummy file
	touch $password_path
	# Then immediately chmod it to 600
	chmod 600 $password_path
	# Write the password to the file
	echo $pass > $password_path
fi

# Update checking
if [[ "$(cat $0)" != "$(curl "$base_dl/$script_name")" ]]; then
    logandnotif "Update available! Use the context menu to update"
fi

# Important code starts here
log "Looking for a script instance to replace"
log "Killing any leftover processes"
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
    log "Started Windows 10 VM"
else
    log "VM is already running."
    sleep 2 # Add artificial delay to prevent the restart detection from failing
fi

log "Starting scream"
scream -i virbr0 -p 4010 -o pulse -v & disown

# Make the shm file world-readable
echo $pass | sudo -S chmod 771 /dev/shm/looking-glass

log "Starting looking-glass"
if [ $1 == "-fs" ]; then
	looking-glass-client -F opengl:vsync yes spice:captureOnStart yes
else
	looking-glass-client
fi

sleep 1 # Prevent race-condition

log "Killing scream"
pkill scream
# If scream is already dead, this indicates that the script has been restarted
if [[ $? == "1" ]]; then
    log "This script has been replaced by another instance"
    exit
fi

log "Stopping VM"
echo $pass | sudo -S virsh shutdown win10
if [[ $? == "0" ]]; then
    log "Stopped Windows 10 VM"
else
    log "VM is not running"
fi
logandnotif "Script exit"