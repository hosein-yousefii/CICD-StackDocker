#!/bin/bash
# Maintainer Hossein yousefi yousefi.hosein.o@gmail.com
# Copy config files to config-volume to be able to use it on kaniko from jenkins


docker run --rm -v $PWD:/source -v config-volume:/dest -w /source alpine cp config.json /dest &>err.log

CHECK_REPORT=$(echo $?)
if [[ $CHECK_REPORT != 0 ]]
then
        echo "[Kaniko-service :: ERROR]: Couldn't make Volume, see kaniko/err.log"
	exit 1
fi

rm -rf err.log

echo "###############################"
echo "[Kaniko-service :: INFO]: Config files are created."
echo "###############################"
echo

