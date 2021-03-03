FROM adoptopenjdk/openjdk11:alpine

ARG VERSION=4.6

LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="$version"

ARG AGENT_WORKDIR=/home/jenkins/agent
ARG JENKINS_HOME=/home/jenkins

RUN apk add --update --no-cache curl bash git git-lfs openssh-client openssl procps \
  && curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && apk del curl

ENV AGENT_WORKDIR=${AGENT_WORKDIR}
ENV JENKINS_HOME=${JENKINS_HOME}
RUN mkdir -p ${JENKINS_HOME}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME ${JENKINS_HOME}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR ${JENKINS_HOME}


COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent

# OCP Specific - See: https://docs.openshift.com/container-platform/4.7/openshift_images/create-images.html#use-uid_create-images
RUN chgrp -R 0 ${JENKINS_HOME} && \
    chmod -R g=u ${JENKINS_HOME}

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]

