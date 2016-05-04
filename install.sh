#!/bin/bash
# Cloud Child Node Server Setup
# Installation script for Ubuntu
# @author Muhammad Dadu

export DEBIAN_FRONTEND=noninteractive

export PORJECT_NAME="Clout - Cloud Technology"
export INSTALL_DIR="/usr/local/lib/"
export PACKAGE_NAME="clout-services-child"
export PACKAGE_REPO="https://github.com/clout-stack/clout-services-child"

echo "------------------------------------------------"
echo "------------------------------------------------"
echo "	" $PORJECT_NAME "Server Setup"
echo "------------------------------------------------"
echo "------------------------------------------------"
echo ""
echo "Checking server state..."

# load functions
source ./functions.sh

echo "NodeJS:  	$(echo_if $(is_installed node))"
echo "Docker:  	$(echo_if $(is_installed docker))"
echo "SQLite3:  	$(echo_if $(is_installed sqlite3))"
# echo "Redis:   	$(echo_if $(is_installed redis-server))"
# echo "MySQL:   	$(echo_if $(is_installed mysql))"
# echo "Nginx:  	$(echo_if $(is_installed nginx))"
echo "initd-forever:	$(echo_if $(is_installed initd-forever))"
echo ""

if [ -e $INSTALL_DIR""$PACKAGE_NAME ];
then
    echo $PORJECT_NAME "provisioning already completed. Skipping..."
    exit 0
else
    echo "Installation Starting..."
fi

##
# Core Componenets
##
echo "Updating/Installing Core Componenets..."
apt-get update > /dev/null
# Install build tools
apt-get install -y make g++ git curl vim libcairo2-dev libav-tools nfs-common portmap software-properties-common > /dev/null
echo "Updated/Installed!"

##
# NodeJS installation
##
if [ $(is_installed node) == 1 ];
then
	echo "Skipping NodeJS installation"
else
	echo "Installing NodeJS..."
	# Modified from https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
	apt-get install -y python-software-properties python g++ make > /dev/null
	add-apt-repository -y ppa:chris-lea/node.js > /dev/null
	apt-get update > /dev/null
	apt-get install -y nodejs > /dev/null
	# apt-get install npm > /dev/null # PI
	npm install n -g > /dev/null # node package manager
	# n 0.12 > /dev/null # install node 0.12
	n 5.0 > /dev/null # PI
	echo "Installed!"
fi

##
# Docker installation
##
if [ $(is_installed docker) == 1 ];
then
	echo "Skipping Docker installation"
else
	echo "Installing Docker..."
	# Update Kernal
	# http://blog.hypriot.com/post/run-docker-rpi3-with-wifi/ # PI
	apt-get install -y linux-image-generic-lts-raring linux-headers-generic-lts-raring > /dev/null
	curl https://get.docker.com/ | sh > /dev/null
	echo "Installed!"
fi

##
# sqlite3 Installation
##
if [ $(is_installed sqlite3) == 1 ];
then
	echo "Skipping SQLite3 installation"
else
	sudo apt-get install sqlite3 libsqlite3-dev -y
	echo "Installed!"
fi

# ##
# # Redis Server
# ##
# if [ $(is_installed redis-server) == 1 ];
# then
# 	echo "Skipping Redis installation"
# else
# 	echo "Installing Redis..."
# 	add-apt-repository -y ppa:chris-lea/redis-server > /dev/null
# 	apt-get update > /dev/null
# 	apt-get install -y redis-server > /dev/null
# 	echo "Installed!"
# fi

# ##
# # MySQL Server
# ##
# if [ $(is_installed mysql) == 1 ];
# then
# 	echo "Skipping MySQL installation"
# else
# 	echo "Installing MySQL..."
# 	# Install unattended
# 	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password '$DEFAULT_PASSWORD''
# 	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password '$DEFAULT_PASSWORD''
# 	apt-get install -y mysql-server > /dev/null
# 	echo "Installed!"
# fi

# ##
# # Nginx
# ##
# if [ $(is_installed nginx) == 1 ];
# then
# 	echo "Skipping Nginx installation"
# else
# 	echo "Installing Nginx..."
# 	# Install unattended
# 	apt-get install -y nginx > /dev/null
# 	echo "Installed!"
# fi
# service nginx restart > /dev/null # restart nginx

##
# initd-forever
##
if [ $(is_installed initd-forever) == 1 ];
then
	echo "Skipping initd-forever installation"
else
	echo "Installing initd-forever..."
	npm install -g initd-forever forever > /dev/null
	echo "Installed!"
fi

##
# clout-services-child
##
cd $INSTALL_DIR
git clone $PACKAGE_REPO
cd $PACKAGE_NAME
npm install > /dev/null

# Link Service
echo "$PACKAGE_NAME: Link Service"
initd-forever --app $INSTALL_DIR""$PACKAGE_NAME --name $PACKAGE_NAME --env development
chmod +x $PACKAGE_NAME
mv $PACKAGE_NAME /etc/init.d/$PACKAGE_NAME
cd /etc/init.d/ && update-rc.d $PACKAGE_NAME defaults
service $PACKAGE_NAME start

echo ""
echo "------------------------------------------------"
echo "Server is connected @" $(hostname -I)
echo "------------------------------------------------"

