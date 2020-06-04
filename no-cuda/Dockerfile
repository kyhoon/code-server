# Author: kyhoon
# modified from Korean locale docker container (ubuntu 18.04) by JHYeom

ARG BASE_IMAGE
FROM $BASE_IMAGE

# Add mirror and update multiverse
RUN sed -i 's/archive.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list \
    && rm -rfv /var/lib/apt/lists/* && sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list \
    && apt-get update && apt-get -y upgrade

# =========================
# Install packages
# =========================
# Common SDK
RUN apt-get install --no-install-recommends -y \
        add-apt-key \
        build-essential \
        bsdtar \
        ca-certificates \
        curl \
        dumb-init \
        gdb \
        git \
        gpg \
        lsb-release \
        net-tools \
        openssh-server \
        openssl \
        pkg-config \
        software-properties-common \
        sudo \
        wget \
        xdg-utils

# Copy OpenSSH configurations
VOLUME /.ssh
RUN service ssh start

# Docker Community Edition
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get install --no-install-recommends -y \
        containerd.io \
        docker-ce \
        docker-ce-cli \
    && service docker start

# Set default user
RUN groupadd -r coder \
    && useradd -m -r coder -g coder -s /bin/bash \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
USER coder
WORKDIR /home/coder

# =========================
# Setup code-server
# =========================
# Install code-server and settings-sync
RUN curl -fsSL https://code-server.dev/install.sh | sh \
    && code-server --install-extension Shan.code-settings-sync

# Create volume for current working directory
RUN mkdir -p /home/coder/project
VOLUME /home/coder/project
WORKDIR /home/coder/project

# Entrypoint
COPY entrypoint.sh /usr/local/bin/
RUN sudo chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080 54321-54329
ENTRYPOINT ["entrypoint.sh"]
CMD ["code-server --bind-addr 0.0.0.0:8080 --auth none"]
