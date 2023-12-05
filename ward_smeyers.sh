#! /bin/bash

DIR="/opt/Wube-Software/factorio"
if [ -d "$DIR" ];
then
    echo "Factorio directory found"
else
    echo "Factorio directory missing"
    while true; do
        read -p "Would you like to create a factorio folder $DIR? [Y or n]" yn
        case $yn in
            [Yy]* ) mkdir -pv /opt/Wube-Software/factorio/saves/ /opt/Wube-Software/factorio/mods/; echo "Factorio directory created"; break;; # Making the working directory and break out prompt loop
            [Nn]* ) exit;; # Exit the script
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

# Backup all files in directory /opt/Wube-Software/factorio/ to a targzip file /opt/Wube-Software/backup-factorio.tar.gz
tar -czf /opt/Wube-Software/backup-factorio.tar.gz $DIR

# Check if latest version of factorio is downloaded
if [ ! -f "/opt/Wube-Software/factorio_headless.tar.gz" ] | [ $1= '-*[D]*' ];
then
    # Downloading the latest factorio version and saving as factorio_headless.tar.gz
    wget -O /opt/Wube-Software/factorio_headless.tar.gz https://factorio.com/get-download/stable/headless/linux64
fi
# unzip and untar the downloaded file 
echo "Unziping /opt/Wube-Software/factorio_headless.tar.gz"
tar -xf /opt/Wube-Software/factorio_headless.tar.gz --directory /opt/Wube-Software

