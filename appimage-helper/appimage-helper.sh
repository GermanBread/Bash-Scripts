#!/bin/sh
log () {
    printf ":: $1\n"
}
warning () {
    tput setaf 3
    printf ":: $1\n"
    tput sgr0
}
error () {
    tput setaf 1
    printf ":: $1\n"
    tput sgr0
}

# Necessary files
template_base_dl="https://raw.githubusercontent.com/GermanBread/Bash-Scripts/master/appimage-helper"
template_desktop="template.desktop"
template_icon="template.png"
template_script="template.sh"

script_name="appimage-helper.sh"
appkit_check="latest_appimage"
script_check="latest_script"

# AppImageKit repository
base_dl="https://github.com/AppImage/AppImageKit/releases/latest/download"
tool_name="appimagetool-x86_64.AppImage"
appkit_response="$(curl -ss "$base_dl/$tool_name")"
script_response="$(curl -ss "$template_base_dl/$script_name")"

if [ -e $script_check ]; then
    script_cache="$(cat $script_check)"
fi
if [ -e $appkit_check ]; then
    appkit_cache="$(cat $appkit_check)"
fi

# Script installation, I'd prefer users to use sh
if [[ "$0" == "sh" ]]; then
    log "Installing script"
    wget -qN "$template_base_dl/$script_name"
    chmod +x $script_name
    echo "$script_response" > "$script_check"
    sh $script_name
    exit 0
fi

# Script updating
if [[ "$script_response" != "$script_cache" ]]; then
    log "Updating script"
    wget -Nq  "$template_base_dl/$script_name"
    chmod +x $script_name
    echo "$script_response" > "$script_check"
    sh $script_name
    exit 0
fi

warning "This script assumes that you have some basic knowledge about AppImages and how they work"

# AppImage packaging part
if [ -z $1 ]; then
    error "No appdir provided, refusing to continue"
    exit 1
fi

if [ ! -d $1 ]; then
    log "Creating new AppImage template for x86_64"
    mkdir -p $1
    mkdir -p $1/usr/bin
    wget -qO "$1/$1.png" "$template_base_dl/$template_icon"
    wget -qO "$1/$1.desktop" "$template_base_dl/$template_desktop"
    wget -qO "$1/usr/bin/$1.sh" "$template_base_dl/$template_script"
    chmod +x "$1/usr/bin/$1.sh"
    wget -qO "$1/AppRun" "$base_dl/AppRun-x86_64"
    sed -ni "s/template/$1/g" "$1/$1.desktop"
    log "Done, modify the files if needed"
    exit 0
fi

if [[ $appkit_cache != $appkit_response ]] || [ ! -e $tool_name ]; then
    log "Downloading latest appimagekit"
    echo "$appkit_response" > "$appkit_check"
    wget -Nq  "$base_dl/$tool_name"
    chmod +x $tool_name
else
    log "Appimagekit up to date"
fi

log "Packaging"
./$tool_name $1 &> log
if [[ $? != 0 ]]; then
    error "Error occured, check log for more info"
    exit 1
fi
log "Done"