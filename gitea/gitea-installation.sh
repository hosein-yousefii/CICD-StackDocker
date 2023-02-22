#!/bin/bash
# Maintainer Hossein yousefi yousefi.hosein.o@gmail.com
# Gitea as a repository manager

GITEA_IP_ADDR=${SERVER_IP_ADDR:-127.0.0.1}

if [[ ! grep -ari SERVER_IP_ADDR . ]]
then
	echo "[Git-service :: ERROR]: Gitea is already changed, restore gitea-data/gitea/conf/app.ini"	
	exit 1
fi

sed -i "s/SERVER_IP_ADDR/${GITEA_IP_ADDR}/g" gitea-data/gitea/conf/app.ini

echo
echo "[Git-service :: INFO]: Installing Gitea..."

docker-compose up -d &>installer.log

CHECK_REPORT=$(echo $?)
if [[ $CHECK_REPORT != 0 ]]
then
        echo "[Git-service :: ERROR]: Cannot install Gitea, check log file: installer.log"
        exit 1
fi

rm -rf installer.log

echo "###############################"
echo "[Git-service :: INFO]: Gitea is ready to use."
echo "###############################"
echo
