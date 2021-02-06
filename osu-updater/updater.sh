#!/bin/bash

if [ $1 ]; then
    param_1=$1  
else
    param_1="null"
fi
if [ $2 ]; then
    param_2=$2
else
    param_2="null"
fi

# Define our functions first
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
    notify-send "$1" -a "Osu update script"
}
logandnotif () {
    log "$1"
    notif "$1"
}
launch () {
    if [ $param_1 != "nostart" ]; then
        logandnotif "Starting Osu!"
        ./osu.AppImage
        if [[ $? > 0 && $param_2 != "dl-only" ]]; then
            logandnotif "Something went wrong, reinstalling Osu!"
            rm lastrelease.txt
            $0 "$param_1" "dl-only"
            exit
        fi
        exit
    fi
}

# Use this as a pre-launch script inside Lutris
log "Fetching response"
if [ "$(curl https://github.com/ppy/osu/releases/latest/download/osu.AppImage)" == "$(cat lastrelease.txt)" ]; then
    log "Up to date, no updating needed"
    launch
    exit
fi
notif "Updating Osu!"
log "Saving last response to disk"
curl https://github.com/ppy/osu/releases/latest/download/osu.AppImage > lastrelease.txt
log "Downloading Osu!"
wget -O osu.AppImage_new https://github.com/ppy/osu/releases/latest/download/osu.AppImage
if [ $? == 0 ]; then
    notif "Update sucessful!"
else
    error "Update failed!"
    notif "Update failedl!"
    rm lastrelease.txt
    exit
fi
log "Overwriting file"
mv osu.AppImage_new osu.AppImage
log "Marking file as executable"
chmod +x osu.AppImage
launch
exit
