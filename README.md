# CICD-StackDocker

Do you need your private CICD-stack on docker by a click?

Jenkins, harbor(docker registry, helm chart registry), local git and kaniko (Docker image builder) All integrated to each other by just running the script.


[![GitHub license](https://img.shields.io/github/license/hosein-yousefii/CICD-StackDocker)](https://github.com/hosein-yousefii/CICD-StackDocker/blob/master/LICENSE)
![LinkedIn](https://shields.io/badge/style-hoseinyousefi-black?logo=linkedin&label=LinkedIn&link=https://www.linkedin.com/in/hoseinyousefi)


## GET STARTED

Here is a CICD stack fully integrated and ready to use. Jenkins, Harbor, Gitea and Kaniko is used to implement this stack.

!!!Bare in mind This is not for production at all!!!

Let's see what is HAPPENING here.

#### Step 1: Gitea
The main part is Jenkins, but we start from Gitea (I don't know why!), There is a simple-sample repository in Gitea which is pre-configured and ready to use, You are able to change Dockerfile, Jenkinsfile and add your codes in it.

#### Step 2: Harbor
We need somewhere to store our builded docker images and charts so, Harbor will do it for us.

#### Step 2: Jenkins
Jenkins is already prepared with jcasc and integrated to Gitea, docker and harbor to get your codes, build and push to registry. Several plugins are available by default.

#### Step 3: Kaniko
We use kaniko to build your images and we do it using Jenkinsfile which is exist in pre-defined gitea repository.


## USAGE:

You are able to deploy this stack by just running it's script:

-------For the first time it takes some minutes to pull all images and it depends on your Internet bandwith-------

You also able to set an ENVIRONMENT VARIABLE on your system to store your Host IP ADDR.If you don't we do it automatically, but we don't garantee it works fine.

```
# Example
export SERVER_IP_ADDR=192.168.1.102
```

#### Dependencies You need for sure

1- docker which is available on tcp:2376 (by running the ./deploy install it will tell you how to do that)

2- docker-compose, which you can install it using pip3 install docker-compose

3- git command


#### Passwords

Do not change passwords because it would brake the integraion(In next releases I would make it dynamic).

Jenkins: admin/qazwsx

Gite: gitadmin/qazwsx

Harbor: admin/qazwsx

#### Time to deploy:

```
# To install the stack on your system.
./deploy install

# To UNInstall the stack.\
./deploy delete

# To stop the stack.
./deploy stop

# To start it again.
./deploy start
```

So it's easy to use.

# How to contribute?

You can fork and develop your idea.
Copyright 2021 Hosein Yousefi <yousefi.hosein.o@gmail.com>
