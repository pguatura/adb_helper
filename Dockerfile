FROM openjdk:8-jdk-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && apt-get install -y \
    git apt sudo openssh-client ca-certificates gzip curl make unzip

RUN groupadd --gid 3434 android-docker \
  && useradd --uid 3434 --gid android-docker --shell /bin/bash --create-home android-docker \
  && echo 'android-docker ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-android-docker \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

USER android-docker
ENV PATH /home/android-docker/.local/bin:/home/android-docker/bin:${PATH}

CMD ["/bin/sh"]

ENV HOME /home/android-docker
ARG ANDROID_HOME=/opt/android/sdk

# SHA-256 92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9

RUN sudo apt-get update && \
    sudo apt-get install --yes \
        wget xvfb lib32z1 lib32stdc++6 build-essential python3-pip \
        libcurl4-openssl-dev libglu1-mesa libxi-dev libxmu-dev \
        libglu1-mesa-dev && \
    sudo rm -rf /var/lib/apt/lists/*

# Download and install Android SDK
RUN sudo mkdir -p ${ANDROID_HOME} && sudo chown -R android-docker:android-docker ${ANDROID_HOME}

# Set environmental variables
ENV ANDROID_HOME ${ANDROID_HOME}

ADD adb_helper $HOME

run bash $HOME/adb_helper prepare

ENV PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}