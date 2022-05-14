#!/bin/bash

# Made by GermanBread#9077
# You can use this script inside Lutris

## Variables

# Downloads
osu_check_dl="https://github.com/ppy/osu/releases/latest/"
osu_base_dl="$osu_check_dl/download/"
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

tmpdir=$(mktemp -d)

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

# Update checking
check_for_script_update () {
    curl -sL $script_dl >$tmpdir/script
    cmp -s $0 $tmpdir/script
    return $?
}
check_for_osu_update () {
    curl -sL $osu_check_dl >$tmpdir/check
    if cmp -s $tmpdir/check $osu_check_file; then
        mv $tmpdir/check $osu_check_file
        return 1
    fi
    return 0
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
    wget -qO $osu_fn $osu_base_dl/$osu_fn
    if [ $? -ne 0 ]; then
        error "Osu! update failed"
    else
        chmod +x $osu_fn
    fi
}

perform_checks() {
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
}

# Responsible for starting Osu!
launch_osu () {
    # Check if the script is allowed to start Osu!
    if [ $param_1 != "nostart" ]; then
        log "Starting Osu!"
        ./$osu_fn
        if [ $? -ne 0 ]; then
            rm -f $osu_check_file
            if [ "$1" != "norestart" ]; then
                error "Attempting to fix issue by reinstalling"
                update_osu
                launch_osu "norestart"
                exit
            else
                error "Reinstall failed. Download the newest script here: https://github.com/GermanBread/Bash-Scripts"
            fi
        fi
        exit
    fi
}

## Now onto the interesting part

# Install the script
if [[ ${0##*/} = "bash" ]]; then
    log "Installing script"
    scriptname="OsuUpdater.sh"
    wget -qO $scriptname $script_dl
    chmod +x $scriptname
    bash $scriptname
    exit
fi

# Create the check-file
touch $osu_check_file
# remove obsolete files
rm -f $script_check_file

perform_checks

# Clean up
rm -rf $tmpdir

launch_osu