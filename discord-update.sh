#!/bin/bash

discord_link=$(curl -s https://discord.com/api/download\?platform\=linux\&format\=deb | grep -oP '<a href="\K[^"]+' | awk 'NR==1')
version=$(echo "$discord_link" | grep -oP 'linux/([^/]+)/discord' | awk -F'/' '{print $2}')

function os_check() {
    if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
        echo "Your OS supports .deb packages, continuing..."
    else
        echo "Your OS does not support .deb packages"
        exit 1
    fi
}

function discord_check() {
    if [ "$(dpkg -l | grep discord)" ]; then
        echo "Discord is already installed, checking version..."
        current_version=$(dpkg -l | grep discord | awk '{print $3}')
        if [ "$current_version" == "$version" ]; then
            echo "Discord is up to date, exiting..."
            echo "Current version: $current_version"
            echo "Latest version: $version"
            exit 0
        else
            echo "Discord is not up to date, updating..."
            echo "Current version: $current_version"
            echo "Latest version: $version"
        fi
    else
        echo "Discord is not installed, installing..."
    fi
}

function discord_install() {
    wget -O discord.deb "$discord_link"

    echo "Installing Discord $version..."
    echo "Requires sudo access to install, please enter your password when prompted"
    sudo dpkg -i discord.deb
}

os_check
discord_check
discord_install

echo "Done"

echo "Do you want to delete the .deb file? [y/n]"
read -r delete
if [ "$delete" == "y" ]; then
    echo "Deleting .deb file..."
    rm discord.deb
else
    echo "Not deleting .deb file..."
fi
