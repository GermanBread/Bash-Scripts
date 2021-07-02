#!/bin/bash

# Made by GermanBread#9077
# You can use this script inside Lutris

## Variables

# Downloads
osu_dl="https://github.com/ppy/osu/releases/latest/download/osu.AppImage"
script_dl="https://raw.githubusercontent.com/GermanBread/Bash-Scripts/master/osu-updater/updater.sh"

# Check-files
osu_check_file="LastOsuRelease.txt"
script_check_file="LastScriptRelease.txt"

# Osu file
osu_fn="osu.AppImage"

# Paramaters
param_1="none"

if [ $1 ]; then
    param_1=$1  
fi

## Functions are defined here

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

# Responsible for starting Osu!
launch_osu () {
    # Check if the script is allowed to start Osu!
    if [ $param_1 != "nostart" ]; then
        log "Starting Osu!"
        ./osu.AppImage
        if [ $? -ne 0 ]; then
            rm $osu_check_file
            if [ $param_1 != "norestart" ]; then
                error "Something went wrong. Attempting to fix issue by reinstalling"
                bash $0 "norestart"
                exit
            else
                error "Reinstall failed. Download the newest script here: https://github.com/GermanBread/Bash-Scripts"
            fi
        fi
        exit
    fi
}

# Update checking
check_for_script_update () {
    if [ "$(curl -s $script_dl)" != "$(cat $script_check_file)" ]; then
        curl -s $script_dl > $script_check_file
        return 1
    fi
}
check_for_osu_update () {
    if [ "$(curl -s $osu_dl)" != "$(cat $osu_check_file)" ]; then
        curl -s $osu_dl > $osu_check_file
        return 1
    fi
}

# Updating
update_script () {
    log "Updating Script"
    wget -qO $0 $script_dl
    if [ $? -ne 0 ]; then
        error "Script update failed"
    else
        chmod +x $0
    fi
}
update_osu () {
    log "Updating Osu!"
    wget -qO $osu_fn $osu_dl
    if [ $? -ne 0 ]; then
        error "Osu! update failed"
    else
        chmod +x $osu_fn
    fi
}

## Now onto the code

# Install the script
if [ $0 == "bash" ]; then
    log "Installing script"
    scriptname="OsuUpdater.sh"
    wget -qO $scriptname $script_dl
    chmod +x $scriptname	
    bash $scriptname
    exit
fi

# Create the check-files
touch $osu_check_file
touch $script_check_file

log "Checking internet"
ping -c 1 1.1.1.1 -W 1 >/dev/null
if [ $? -eq 0 ]; then
    log "Checking for script update..."
    check_for_script_update
    if [ $? -ne 0 ]; then
        update_script
    fi
    log "Checking for osu! update..."
    check_for_osu_update
    if [ $? -ne 0 ]; then
        update_osu
    fi
else
    error "No internet connectivity!"
fi
launch_osu