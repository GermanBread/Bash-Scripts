#!/usr/bin/env bash

# Made by GermanBread#9077
# You can use this script inside Lutris, just add "nostart" to the script's args

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
log() {
    echo -e "\033[36mI:\033[0m  $*"
}
error() {
    echo -e "\033[1;4;31mE::\033[0m $*"
}

# Update checking
check_for_script_update() {
    log "Checking for script update..."
    wget -qO $tmpdir/script $script_dl
    if ! cmp -s $0 $tmpdir/script; then
        return 0
    fi
    log "Already up-to-date"
    return 1
}
check_for_osu_update() {
    log "Checking for osu! update..."
    curl -sL $osu_check_dl | grep $osu_fn >$tmpdir/check
    if ! cmp -s $tmpdir/check $osu_check_file; then
        mv -f $tmpdir/check $osu_check_file
        return 0
    fi
    log "Already up-to-date"
    return 1
}

# Updating
update_script() {
    log "Performing automatic self-update"
    wget -qO $0 $script_dl
    if [ $? -ne 0 ]; then
        error "Automatic update failed"
    else
        chmod +x $0
    fi
    rm -rf $tmpdir
    log "Restarting script"
    exec $0 $param_1
    log "The script should never get here – and yet, it got here..."
    exit 1
}
update_osu() {
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
        check_for_script_update
        if [ $? -eq 0 ]; then
            update_script
        fi
        check_for_osu_update
        if [ $? -eq 0 ]; then
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
                check_for_osu_update
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

launch_osu

# Clean up
rm -rf $tmpdir