#! /bin/bash

DIR="/opt/Wube-Software/factorio"
if [ -d "$DIR" ];
then
    echo "factorio directory found"
else
    echo "factorio directory missing"
fi

# # Making the working directory
# mkdir -r /opt/Wube-Software/factorio/saves/ /opt/Wube-Software/factorio/mods/

# # Backup all factorio files
# tar -czf /opt/Wube-Software/factorio --directory /opt/Wube-Software/backup-factorio

# # Downloading the latest factorio version and saving as factorio_headless.tar.gz
# wget -O /opt/Wube-Software/factorio_headless.tar.gz https://factorio.com/get-download/stable/headless/linux64

# # unzip and untar the downloaded file 
# tar -xf /opt/Wube-Software/factorio_headless.tar.gz --directory /opt/Wube-Software

