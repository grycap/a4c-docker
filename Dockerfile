FROM ubuntu:16.04

RUN apt-get update && apt-get -y install build-essential curl python3 openjdk-8-jdk ruby  git ruby-dev maven sudo bash apt-transport-https ca-certificates software-properties-common
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN apt-get update && apt-get -y install nodejs docker-ce
#RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install -g bower
RUN npm -g install grunt-cli
RUN gem install compass
RUN npm install grunt-contrib-compass --save-dev

# These are development only libs, speeds up testing
RUN apt-get -y install vim htop

ENV A4C_PORT 8088
ENV A4C_VER 2.0.0-SNAPSHOT
ENV A4C_INSTALL_PATH /opt
ENV A4C_INSTALL_DIR a4c
ENV A4C_SRC_DIR a4c-src
ENV USER a4c



RUN mkdir -p "${A4C_INSTALL_PATH}/${A4C_INSTALL_DIR}"
RUN mkdir -p "/home/${USER}"
RUN useradd -ms /bin/bash ${USER}
RUN chown -R ${USER}:${USER} "${A4C_INSTALL_PATH}"
RUN chown -R ${USER}:${USER} "/home/${USER}"

USER ${USER}

RUN git clone https://github.com/alien4cloud/alien4cloud "${A4C_INSTALL_PATH}/${A4C_SRC_DIR}"

WORKDIR "${A4C_INSTALL_PATH}/${A4C_SRC_DIR}"

RUN mvn clean install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true

RUN cp "${A4C_INSTALL_PATH}/${A4C_SRC_DIR}/alien4cloud-ui/target/alien4cloud-ui-${A4C_VER}-standalone.war" "${A4C_INSTALL_PATH}/${A4C_INSTALL_DIR}/alien4cloud-ui-standalone.war"

ADD --chown=${USER}:${USER} alien4cloud.sh "${A4C_INSTALL_PATH}/${A4C_INSTALL_DIR}"
ADD --chown=${USER}:${USER} config "${A4C_INSTALL_PATH}/${A4C_INSTALL_DIR}"
ADD --chown=${USER}:${USER} init "${A4C_INSTALL_PATH}/${A4C_INSTALL_DIR}"
#USER root
#RUN chown -R ${USER}:${USER} "${A4C_INSTALL_PATH}"
#USER ${USER}
RUN chmod +x "${A4C_INSTALL_PATH}/${A4C_INSTALL_DIR}/alien4cloud.sh"

EXPOSE ${A4C_PORT}

ENTRYPOINT cd ${A4C_INSTALL_PATH}/${A4C_INSTALL_DIR} && ./alien4cloud.sh