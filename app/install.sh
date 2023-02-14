#!/bin/bash

#install packages
apt-get update && apt-get upgrade -y &>/dev/null
apt-get install curl git nano -y &>/dev/null

#install Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash &>/dev/null
source ~/.bashrc
echo "nvm -v : "; nvm -v
nvm install v16.18 &>/dev/null
[ $? == 0 ] && echo "install Node.js ok"
[ $? == 0 ] && echo "node -v : " && node -v
