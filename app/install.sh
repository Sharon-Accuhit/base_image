#!/bin/bash

#set variables
source install.env

#install packages
apt-get update && apt-get upgrade -y &>/dev/null
apt-get install curl git nano -y &>/dev/null

#install Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash &>/dev/null
source ~/.bashrc
echo "nvm -v : "; nvm -v; echo "---"
nvm install $Node_Version &>/dev/null
[ $? == 0 ] && echo "install Node.js ok" && echo "---"
[ $? == 0 ] && echo "node -v : " && node -v && echo "---"
