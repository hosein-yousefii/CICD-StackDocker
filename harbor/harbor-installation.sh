#!/bin/bash
# Maintainer Hossein yousefi yousefi.hosein.o@gmail.com
# This is the script to install harbor on docker.

HARBOR_INSTALLER_VERSION=${HARBOR_INSTALLERVERSION:-v2.7.1}
HARBOR_DOMAIN_NAME=${HARBOR_DOMAINNAME:-harbor.internal}
HARBOR_ADMIN_PASSWORD=${HARBOR_ADMINPASSWORD:-qazwsx}
HARBOR_CERT_FILE=${HARBOR_CERTFILE:-$(pwd)/harbor-openssl/server.crt}
HARBOR_KEY_FILE=${HARBOR_KEYFILE:-$(pwd)/harbor-openssl/server.key}
HARBOR_DATA_FILES=${HARBOR_DATAFILE:-$(pwd)/harbor-files/data/}

echo 
echo "[harbor-registry :: INFO]: Get Harbor online installer.."

wget https://github.com/goharbor/harbor/releases/download/${HARBOR_INSTALLER_VERSION}/harbor-online-installer-${HARBOR_INSTALLER_VERSION}.tgz &>/dev/null 

CHECK_REPORT=$(echo $?)
if [[ $CHECK_REPORT != 0 ]]
then
        echo "[harbor-registry :: ERROR]: Cannot fetch file, check your connections."
        exit 1
fi

echo "[harbor-registry :: INFO]: Extract files..."

tar -xf harbor-online-installer-${HARBOR_INSTALLER_VERSION}.tgz &>/dev/null 

CHECK_REPORT=$(echo $?)
if [[ $CHECK_REPORT != 0 ]]
then
	echo "[harbor-registry :: ERROR]: cannot extract harbor-online-installer-${HARBOR_INSTALLER_VERSION}.tgz."
	exit 1
fi

sleep 1s

echo "[harbor-registry :: INFO]: Prepare files and directories..."

mv harbor harbor-files && rm -rf harbor-online-installer-${HARBOR_INSTALLER_VERSION}.tgz

mv harbor-files/harbor.yml.tmpl harbor-files/harbor.yml

CHECK_REPORT=$(echo $?)
if [[ $CHECK_REPORT != 0 ]]
then
        echo "[harbor-registry :: ERROR]: Cannot create directories."
        exit 1
fi

sleep 1s

echo

. ./generate-ssl.sh

CHECK_REPORT=$(echo $?)
if [[ $CHECK_REPORT != 0 ]]
then
        echo "[harbor-registry :: ERROR]: Cannot generate Certificates."
        exit 1
fi

echo
echo "[harbor-registry :: INFO]: Change variables for docker-compose..."

sed -i "s/^hostname:.*/hostname: ${HARBOR_DOMAIN_NAME}/" harbor-files/harbor.yml

sed -i "s|  certificate:.*|  certificate: ${HARBOR_CERT_FILE}|" harbor-files/harbor.yml

sed -i "s|  private_key:.*|  private_key: ${HARBOR_KEY_FILE}|" harbor-files/harbor.yml

sed -i "s/^harbor_admin_password:.*/harbor_admin_password: ${HARBOR_ADMIN_PASSWORD}/" harbor-files/harbor.yml

sed -i "s|^data_volume:.*|data_volume: ${HARBOR_DATA_FILES}|" harbor-files/harbor.yml

cd harbor-files

sleep 1s

echo "[harbor-registry :: INFO]: Prepare configurations..."

./prepare &>prepare.log

CHECK_REPORT=$(echo $?)
if [[ $CHECK_REPORT != 0 ]]
then
        echo "[harbor-registry :: ERROR]: Cannot prepare files, check log file: prepare.log"
        exit 1
fi

echo "[harbor-registry :: INFO]: installing harbor..."

./install.sh &>installer.log

CHECK_REPORT=$(echo $?)
if [[ $CHECK_REPORT != 0 ]]
then
        echo "[harbor-registry :: ERROR]: Cannot install harbor, check log file: installer.log"
        exit 1
fi

rm -rf prepare.log installer.log

echo "###############################"
echo "[harbor-registry :: INFO]: Harbor is ready to use."
echo "###############################"
echo

