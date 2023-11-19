#! /bin/bash

DIR="/opt/Wube-Software/factorio"
if [ -d "$DIR" ];
then
    echo "Factorio directory found"
else
    echo "Factorio directory missing"
    while true; do
        read -p "Would you like to create a factorio folder $DIR ? [Y or n]" yn
        case $yn in
            [Yy]* ) mkdir -pv /opt/Wube-Software/factorio/saves/ /opt/Wube-Software/factorio/mods/; echo "Factorio directory created"; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

# # Making the working directory
# mkdir -r /opt/Wube-Software/factorio/saves/ /opt/Wube-Software/factorio/mods/

# # Backup all factorio files
# tar -czf /opt/Wube-Software/factorio --directory /opt/Wube-Software/backup-factorio

# # Downloading the latest factorio version and saving as factorio_headless.tar.gz
# wget -O /opt/Wube-Software/factorio_headless.tar.gz https://factorio.com/get-download/stable/headless/linux64

# # unzip and untar the downloaded file 
# tar -xf /opt/Wube-Software/factorio_headless.tar.gz --directory /opt/Wube-Software

