#!/bin/bash
# Maintainer Hossein yousefi yousefi.hosein.o@gmail.com
# Jenkins custome image with several plugins

SYSTEM_IP=($(hostname -I))
JENKINS_USER_ID=${CICD_JENKINS_USER:-admin}
JENKINS_USER_PASSWORD=${CICD_JENKINS_PASS:-qazwsx}
JENKINS_DOCKER_IP_ADDR=${CICD_JENKINS_DOCKER_ADDR:-${SYSTEM_IP[0]}:2376}
GITEA_USERNAME=gitadmin
GITEA_PASSWORD=qazwsx
sed -i "1,8 s/- id:.*/- id: ${JENKINS_USER_ID}/" casc.yaml
sed -i "1,8 s/password:.*/password: ${JENKINS_USER_PASSWORD}/" casc.yaml
sed -i "30,40 s/username:.*/username: ${GITEA_USERNAME}/" casc.yaml
sed -i "30,40 s/password:.*/password: ${GITEA_PASSWORD}/" casc.yaml
sed -i "/- \"DOCKER/ c \ \ \ \ \ \ - \"DOCKER_HOST=tcp://${JENKINS_DOCKER_IP_ADDR}\"" docker-compose.yaml

echo "[Jenkins-service :: INFO]: Building Jenkins...(might take minutes)"

docker build . -t jenkins-custom &> build.log

CHECK_REPORT=$(echo $?)
if [[ $CHECK_REPORT != 0 ]]
then
        echo "[Jenkins-service :: ERROR]: Cannot build Jenkins, check log file: build.log"
        exit 1
fi

rm -fr build.log

docker volume rm jenkins-data &>installer.log
docker-compose up -d &> installer.log

CHECK_REPORT=$(echo $?)
if [[ $CHECK_REPORT != 0 ]]
then
        echo "[Jenkins-service :: ERROR]: Cannot install Jenkins, check log file: installer.log"
        exit 1
fi

rm -rf installer.log

echo "###############################"
echo "[Jenkins-service :: INFO]: Jenkins is ready to use."
echo "###############################"
echo


