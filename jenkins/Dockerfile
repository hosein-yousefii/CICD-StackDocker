ARG JENKINS_IMAGE_VERSION=lts-slim
FROM jenkins/jenkins:$JENKINS_IMAGE_VERSION

LABEL maintainer="Hossein Yousefi <yousefi.hosein.o@gmail.com>"

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml

USER root

# PLUGINS

RUN jenkins-plugin-cli --plugins \
 configuration-as-code \
 workflow-aggregator \
 job-dsl \
 pipeline-model-definition \
 pam-auth:latest \
 pipeline-github-lib:latest \
 pipeline-stage-view:latest \
 antisamy-markup-formatter \
 docker-plugin \
 docker-commons \
 docker-workflow \
 git \
 git-parameter \
 github \
 github-branch-source \
 gradle \
 mailer \
 htmlpublisher \
 generic-webhook-trigger \
 credentials \
 credentials-binding \
 email-ext:latest \
 rebuild \
 run-condition \
 ssh-slaves \
 timestamper \
 ssh \
 publish-over-ssh \
 metrics \
 http_request \
 config-file-provider \
 ansicolor \
 join \
 ws-cleanup \
 ssh-steps \
 permissive-script-security \
 ssh-credentials \
 multibranch-scan-webhook-trigger \
 remote-file \
 build-timeout:latest \
 authorize-project:latest \
 matrix-auth 

# Dependencies

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https \
  ca-certificates curl \
  gnupg gnupg2 \
  software-properties-common \
  lsb-release \
  apt-utils

# Docker client

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce-cli

# Helm

RUN curl -fsSL https://baltocdn.com/helm/signing.asc | apt-key add -
RUN apt-add-repository "deb https://baltocdn.com/helm/stable/debian all main"
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y helm

# Casc

COPY casc.yaml /var/jenkins_home/casc.yaml

USER jenkins
