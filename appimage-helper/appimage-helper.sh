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
template_script="templatescript"

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

# Create / clear the log file
echo "Logfile created on: $(date '+%D %T')\n" >> log

# Script installation, I'd prefer users to use sh
if [[ "$0" == "sh" ]]; then
    log "Installing script"
    wget -N "$template_base_dl/$script_name" &>> log
    chmod +x $script_name
    echo "$script_response" > "$script_check"
    log "Install done"
    #sh $script_name
    exit 0
fi

# Script updating
if [[ "$script_response" != "$script_cache" ]]; then
    log "Updating script"
    wget -N  "$template_base_dl/$script_name" &>> log
    chmod +x $script_name
    echo "$script_response" > "$script_check"
    sh "$script_name" "$1" # Pass parameters
    exit 0
fi

warning "This script assumes that you have some basic knowledge about AppImages and how they work"

# AppImage packaging part
if [ -z $1 ]; then
    error "No appdir provided, refusing to continue"
    exit 1
fi

if [ ! -d $1 ] || [ -z "$(ls -A $1)" ]; then
    log "Creating new AppImage template for x86_64"
    # Directory tree
    mkdir -p $1
    mkdir -p $1/usr/bin
    
    # Downloading
    wget -O "$1/AppRun" "$base_dl/AppRun-x86_64" &>> log
    wget -O "$1/$1.png" "$template_base_dl/$template_icon" &>> log
    wget -O "$1/usr/bin/$1" "$template_base_dl/$template_script" &>> log
    wget -O "$1/$1.desktop" "$template_base_dl/$template_desktop" &>> log
    
    # Marking files as executable
    chmod +x "$1/AppRun"
    chmod +x "$1/$1.desktop"
    chmod +x "$1/usr/bin/$1"
    
    sed -i "s/template/$1/g" "$1/$1.desktop" &>> log
    log "Done, modify the files if needed"
    exit 0
fi

if [[ $appkit_cache != $appkit_response ]] || [ ! -e $tool_name ]; then
    log "Downloading latest appimagekit"
    echo "$appkit_response" > "$appkit_check"
    wget -N  "$base_dl/$tool_name" &>> log
    chmod +x $tool_name
else
    log "Appimagekit up to date"
fi

log "Packaging"
export ARCH="x86_64"
./$tool_name $1 &>> log
if [[ $? != 0 ]]; then
    error "Error occured, check log for more info"
    exit 1
fi
# Append a newline to the log
echo "\n" >> log
log "Done, check logs"