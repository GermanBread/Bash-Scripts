#!/bin/sh
log () {
    tput bold
    tput setaf 4
    printf "[ INFO ]"
    tput sgr0
    printf " $*\n"
    tput sgr0
}
warning () {
    tput bold
    tput setaf 3
    printf "[ WARN ]"
    tput sgr0
    printf " $*\n"
    tput sgr0
}
error () {
    tput bold
    tput setaf 1
    printf "[ ERRO ]"
    tput sgr0
    printf " $*\n"
    tput sgr0
}

# Necessary files
template_base_dl="https://raw.githubusercontent.com/GermanBread/Bash-Scripts/master/appimage-helper"
template_desktop="template.desktop"
template_icon="template.png"
template_script="templatescript"

script_name="appimage-helper.sh"
appkit_check="latest_appimage"

# AppImageKit repository
base_dl="https://github.com/AppImage/AppImageKit/releases/latest/download"
tool_name="appimagetool-x86_64.AppImage"
appkit_response="$(curl -ss "$base_dl/$tool_name")"
script_response="$(curl -ss "$template_base_dl/$script_name")"

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
    log "Install done"
    #sh $script_name
    exit 0
fi

# Script updating
if [[ "appimage-helper" != "$(basename $(pwd))" ]] && [[ "$script_response" != "$(cat $0)" ]]; then
    log "Updating script"
    wget -N  "$template_base_dl/$script_name" &>> log
    chmod +x $script_name
    sh "$script_name" "$*" # Pass parameters
    exit 0
else
    if [[ "appimage-helper" == "$(basename $(pwd))" ]]; then
        log "Running inside debug enviroment, skipping update"
    fi
fi

# AppImage packaging part
if [ -z "$*" ]; then
    error "No appdir provided, refusing to continue"
    exit 1
fi

if [ ! -d "$*" ] || [ -z "$(ls -A "$*")" ]; then
    log "Creating new AppImage template for x86_64"
    # Directory tree
    mkdir -p "$*"
    mkdir -p "$*/usr/bin"
    
    # Downloading
    wget -O "$*/AppRun" "$base_dl/AppRun-x86_64" &>> log
    wget -O "$*/$*.png" "$template_base_dl/$template_icon" &>> log
    wget -O "$*/usr/bin/$*" "$template_base_dl/$template_script" &>> log
    wget -O "$*/$*.desktop" "$template_base_dl/$template_desktop" &>> log
    
    # Marking files as executable
    chmod +x "$*/AppRun"
    chmod +x "$*/$*.desktop"
    chmod +x "$*/usr/bin/$*"
    
    sed -i "s/template/$*/g" "$*/$*.desktop" &>> log
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
./$tool_name "$*" &>> log
if [[ $? != 0 ]]; then
    error "Error occured, check log for more info"
    exit 1
fi
# Append a newline to the log
echo "\n" >> log
log "Done, check logs"