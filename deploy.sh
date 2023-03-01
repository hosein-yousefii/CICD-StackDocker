#!/bin/bash
# Maintainer Hossein yousefi yousefi.hosein.o@gmail.com
# CICD stack

ROOTDIR=$(pwd)
SYSTEM_IP=($(hostname -I))
HOST_IP=${SERVER_IP_ADDR:-${SYSTEM_IP[0]}}

check_dependencies () {

	if [[ ! $(which docker) ]]
	then
		echo "[CICD-stack :: ERROR]: You need to install docker."
		echo "[CICD-stack :: ERROR]: Use this repository https://github.com/hosein-yousefii/docker-ansible."
		exit 1
	fi

	if [[ ! $(which docker-compose) ]]
	then
		echo "[CICD-stack :: ERROR]: You need to install docker-compose."
		echo "[CICD-stack :: ERROR]: pip3 install docker-compose."
		exit 1
	fi

}	
network_create () {
        
	echo "[CICD-stack :: INFO]: Creating network..."

        docker network create -d bridge cicd-stack
}	

network_conf () {

	docker network connect cicd-stack harbor-core
	docker network connect cicd-stack harbor-db
	docker network connect cicd-stack harbor-jobservice
	docker network connect cicd-stack harbor-log
	docker network connect cicd-stack harbor-portal
	docker network connect cicd-stack redis
	docker network connect cicd-stack registry
	docker network connect cicd-stack registryctl
}

check_docker_tcp () {

	echo "[CICD-stack :: INFO]: Checking docker tcp..."
	echo

	grep -i tcp /etc/docker/daemon.json &>/dev/null
	
	DAEMON_CHECK_REPORT=$(echo $?)

	grep -i tcp /lib/systemd/system/docker.service

	SERVICE_CHECK_REPORT=$(echo $?)

	if [ $DAEMON_CHECK_REPORT != 0 ] && [ $SERVICE_CHECK_REPORT != 0 ]
	then
        	echo "[CICD-stack :: ERROR]: Cannot install CICD-stack because your docker is not exposed on tcp"
		echo "[CICD-stack :: ERROR]: Add this line to '/etc/docker/daemon.json '"
		echo "[CICD-stack :: ERROR]: '{\"hosts\": [\"fd://\",\"unix:///var/run/docker.sock\",\"tcp://0.0.0.0:2376\"]}'"
		echo "[CICD-stack :: ERROR]: Also remove anything else than \"ExecStart=/usr/bin/dockerd\" in /lib/systemd/system/docker.service"
		echo "[CICD-stack :: ERROR]: Now follow these commands, systemctl daemon-reload && systemctl restart docker"
	        exit 1
	fi
}	


create_repo () {

	echo "[CICD-stack :: INFO]: Creating git repo..."

	curl -X POST "http://localhost:3000/api/v1/user/repos" -H "accept: application/json" \
		-H "Authorization: token 7068c0a9a0631447f9270ae9fc3d880f02f993e7"\
	       	-H "Content-Type: application/json" -d "{\"name\": \"simple-sample\"}" -i &>/dev/null

        CHECK_REPORT=$(echo $?)

        if [ $CHECK_REPORT != 0 ]
        then
                echo "[CICD-stack :: ERROR]: Gitea repository should be created manually."
		exit 1
        fi

	sed -i "s/HOST_IP_ADDR/${HOST_IP}/" configuration-data/simple-sample/Jenkinsfile
	cd configuration-data/simple-sample && git init &>/dev/null && git checkout -b main &>/dev/null &&\
	       	git add . &>/dev/null && git commit -a -m "init" &>/dev/null && \
		git remote add origin http://gitadmin:qazwsx@localhost:3000/gitadmin/simple-sample.git &>/dev/null &&\
		git push --set-upstream origin main &>/dev/null 
	cd $ROOTDIR
}	

sleep 1s

case $1 in
	install)
		echo
		echo "[CICD-stack :: INFO]: Welcome to CICD stack, doing prechecks..."
		
		if [[ -e harbor/harbor-files ]]
		then
			echo "[CICD-stack :: ERROR]: CICD stack is already installed, try to delete then install again."
			exit 1
		fi

		check_dependencies
		check_docker_tcp
		network_create &>/dev/null

		cd jenkins
		. ./jenkins-installation.sh
		cd $ROOTDIR
		
		cd kaniko
		. ./kaniko-installation.sh
		cd $ROOTDIR
		
		cd gitea
		. ./gitea-installation.sh
		cd $ROOTDIR

                cd harbor
                . ./harbor-installation.sh
		cd $ROOTDIR

		network_conf
		create_repo
		                
		if [[ ! $(grep -ari harbor.internal /etc/hosts) ]];then echo "127.0.0.1 harbor.internal" >> /etc/hosts;fi

		echo
		echo "[CICD-stack :: INFO]: Jenkins url: ${HOST_IP[0]}:8080"
		echo "[CICD-stack :: INFO]: Jenkins user/pass: admin/qazwsx"
		echo
                echo "[CICD-stack :: INFO]: harbor url: ${HOST_IP[0]}:80"
		echo "[CICD-stack :: INFO]: harbor user/pass: admin/qazwsx"
		echo
                echo "[CICD-stack :: INFO]: Gitea url: ${HOST_IP[0]}:3000"
                echo "[CICD-stack :: INFO]: Gitea user/pass: gitadmin/qazwsx"
		echo		
		echo "**************************************"
		echo "[CICD-stack :: INFO]: Installation is finished, check if all services are ready to use."
		echo "**************************************"
		echo '#'
		echo '#'
		echo '# [::INFO::] To be able to pull images from docker, LOGIN to harbor using:'
		echo '#'
		echo '#' docker login -u admin -p qazwsx harbor.internal
		echo '#'
		echo '#' 
		echo '# [::INFO::] If you want to push your images using docker host, You should'
		echo '#            Add harbor.internal to your docker insecure config.'
		echo '#'
		echo '# vi /etc/docker/daemon.json'
		echo '#'
		echo '# ADD this line.'
		echo '#'
		echo '# { "insecure-registries" : [ "harbor.internal" ] }'
		echo '#'
		echo '#'
		echo '#'
		


	;;

	stop)
		echo
		echo "[CICD-stack :: INFO]: Stopping Jenkins..."
		docker-compose -f jenkins/docker-compose.yaml down &>/dev/null

                echo "[CICD-stack :: INFO]: Stopping Gitea..."
                docker-compose -f gitea/docker-compose.yaml down &>/dev/null

                echo "[CICD-stack :: INFO]: Stopping Harbor..."
                docker-compose -f harbor/harbor-files/docker-compose.yml down &>/dev/null

                echo
                echo "**************************************"
                echo "[CICD-stack :: INFO]: All services stopped."
                echo "**************************************"

	;;

        start)
		if [[ ! -e harbor/harbor-files ]]
		then
			echo "[CICD-stack :: INFO]: You first need to delete deployment with (deploy delete),"
			echo "then install them with (deploy install)."
			exit 1
		fi

                echo
                echo "[CICD-stack :: INFO]: Starting Jenkins..."
                docker-compose -f jenkins/docker-compose.yaml up -d &>/dev/null

                echo "[CICD-stack :: INFO]: Starting Gitea..."
                docker-compose -f gitea/docker-compose.yaml up -d &>/dev/null

                echo "[CICD-stack :: INFO]: Starting Harbor..."
                docker-compose -f harbor/harbor-files/docker-compose.yml up -d &>/dev/null

                echo
                echo "**************************************"
                echo "[CICD-stack :: INFO]: All services started."
                echo "**************************************"

        ;;
	

	delete)
		echo
                echo "[CICD-stack :: INFO]: Stopping Jenkins..."
                docker-compose -f jenkins/docker-compose.yaml down -v &>/dev/null

                echo "[CICD-stack :: INFO]: Stopping Gitea..."
                docker-compose -f gitea/docker-compose.yaml down -v &>/dev/null
		rm -rf gitea/gitea-data

                echo "[CICD-stack :: INFO]: Stopping Harbor..."
                docker-compose -f harbor/harbor-files/docker-compose.yml down -v &>/dev/null
		rm -rf harbor/harbor-files harbor/harbor-openssl

		docker network rm cicd-stack &>/dev/null
		docker volume rm jenkins-data config-volume &>/dev/null
		rm -rf configuration-data/simple-sample/.git &>/dev/null
		
	;;
esac	



