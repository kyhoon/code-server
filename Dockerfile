# Author: kyhoon
# modified from Korean locale docker container (ubuntu 18.04) by JHYeom

FROM ubuntu:18.04

# =========================
# Install packages
# =========================
# Common SDK
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list && \
    apt-get update && apt-get install --no-install-recommends -y \
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
    openssl \
    pkg-config \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/*

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

# Python extension
RUN mkdir -p ${VSCODE_EXTENSIONS}/python \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/python extension

# Settings-sync extension
RUN mkdir -p ${VSCODE_EXTENSIONS}/code-settings-sync \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/Shan/vsextensions/code-settings-sync/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/code-settings-sync extension

EXPOSE 8080 54321

ENTRYPOINT ["dumb-init", "--"]
CMD ["code-server"]
