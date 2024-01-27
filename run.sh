#!/bin/bash

#Check veriables or set defaults
if [ -z ${WEBDRIVE_USER} ]; then
  echo "Webdrive user is not set"
fi

if [ -z ${WEBDRIVE_PASSWORD} ]; then
  echo "Webdrive password is not set"
fi

if [ -z ${WEBDRIVE_URL} ]; then
  echo "Webdrive url is not set"
fi

USER=${WEBDRIVE_USER}
PASSWORD=${WEBDRIVE_PASSWORD}
URL=${WEBDRIVE_URL}
FOLDER_USER=${SYNC_USERID:-0}

echo "$URL $USER $PASSWORD" >> /etc/davfs2/secrets

# Create user
if [ $FOLDER_USER -gt 0 ]; then
  useradd webdrive -u $FOLDER_USER -N -G users
fi

# Mount the webdav drive 
mount -t davfs $URL /mnt/webdrive -o uid=$FOLDER_USER,gid=users,dir_mode=755,file_mode=755

#update borgmatic config file
sed -i "s|REPO_NAME|$REPO_NAME|g" /etc/borgmatic/config.yaml

## TODO: create initfile, and check if initfile exist, if so, skip next step. 
#initialize borg repository
~/.local/bin/borgmatic init --encryption repokey

#Make backup
~/.local/bin/borgmatic --verbosity 1

#Unmount the webdav drive
umount /mnt/webdrive
