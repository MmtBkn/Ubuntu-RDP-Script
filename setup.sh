#!/bin/bash
# Please leave me a star *
# Script to install ubuntu(Digital Ocean, 17.10) desktop & enable remote desktop connection

unset password
unset username
read -p "Enter Username (only all lower): " username
prompt="Enter Password:"
while IFS= read -p "$prompt" -r -s -n 1 char
do
    if [[ $char == $'\0' ]]
    then
        break
    fi
    prompt='*'
    password+="$char"
done
echo

sudo adduser $username --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$username:$password" | sudo chpasswd

usermod -aG sudo $username

sudo apt-get update
sudo apt-get -y install ubuntu-desktop
sudo apt-get -y install xrdp
sudo apt-get -y install gnome-tweak-tool

sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config

echo 'polkit.addRule(function(action, subject) {
 if ((action.id == "org.freedesktop.color-manager.create-device" ||
 action.id == "org.freedesktop.color-manager.create-profile" ||
 action.id == "org.freedesktop.color-manager.delete-device" ||
 action.id == "org.freedesktop.color-manager.delete-profile" ||
 action.id == "org.freedesktop.color-manager.modify-device" ||
 action.id == "org.freedesktop.color-manager.modify-profile") &&
 subject.isInGroup("{group}")) {
 return polkit.Result.YES;
 }
 });' >> /etc/polkit-1/localauthority.conf.d/02-allow-colord.conf
 
# Fix mouse cursor problem (should be done per user)
echo 'Xcursor.core: 1' >> /home/$username/.Xresources

# Download dropbox since file sharing is hard
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
~/.dropbox-dist/dropboxd
