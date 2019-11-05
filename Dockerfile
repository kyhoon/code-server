# Author: kyhoon
# modified from Korean locale docker container (ubuntu 18.04) by JHYeom

FROM ubuntu:18.04

# =========================
# Install packages
# =========================
# Common SDK
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list \
    && apt-get update && apt-get install --no-install-recommends -y \
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
        xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Copy OpenSSH configurations
VOLUME /.ssh
RUN service ssh start

# Docker Community Edition
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update && apt-get install --no-install-recommends -y \
        containerd.io \
        docker-ce \
        docker-ce-cli \
    && rm -rf /var/lib/apt/lists/* \
    && service docker start

# Python3 SDK
RUN apt-get update && apt-get install --no-install-recommends -y \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
    && rm -rf /var/lib/apt/lists/*

# Set default user
RUN groupadd -r coder \
    && useradd -m -r coder -g coder -s /bin/bash \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
USER coder
WORKDIR /home/coder

# =========================
# Setup code-server
# =========================
# Install code-server
ENV DISABLE_TELEMETRY true
ENV CODE_VERSION="2.1523-vsc1.38.1"
RUN curl -sL https://github.com/cdr/code-server/releases/download/${CODE_VERSION}/code-server${CODE_VERSION}-linux-x86_64.tar.gz | sudo tar --strip-components=1 -zx -C /usr/local/bin code-server${CODE_VERSION}-linux-x86_64/code-server

# Create extensions directory
ENV VSCODE_USER "/home/coder/.local/share/code-server/User"
ENV VSCODE_EXTENSIONS "/home/coder/.local/share/code-server/extensions"
RUN mkdir -p ${VSCODE_USER}

# Settings-sync extension
RUN mkdir -p ${VSCODE_EXTENSIONS}/code-settings-sync \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/Shan/vsextensions/code-settings-sync/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/code-settings-sync extension

# Create volume for current working directory
RUN mkdir -p /home/coder/project
VOLUME /home/coder/project
WORKDIR /home/coder/project

# Entrypoint
COPY entrypoint.sh /usr/local/bin/
RUN sudo chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080-8089 54321
ENTRYPOINT ["entrypoint.sh"]
CMD ["code-server"]
