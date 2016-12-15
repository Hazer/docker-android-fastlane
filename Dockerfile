FROM ruby:latest

ENV ANDROID_HOME /opt/android-sdk-linux


# ------------------------------------------------------
# --- Install required tools

RUN apt-get update -qq

# Base (non android specific) tools
# -> should be added to bitriseio/docker-bitrise-base

# Dependencies to execute Android builds
RUN dpkg --add-architecture i386
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget zip unzip libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386 && \
	apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update && \
    echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default && \
	echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME

ENV ANDROID_SDK_URL https://dl.google.com/android/repository/tools_r25.2.3-linux.zip

RUN cd /opt \
    && wget --output-document=android-sdk.zip --quiet $ANDROID_SDK_URL \
    && unzip android-sdk.zip -d android-sdk-linux \
    && rm -f android-sdk.zip \
    && chown -R root:root android-sdk-linux

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  android list sdk --no-ui --all --extended
# (!!!) Only install one package at a time, as "echo y" will only work for one license!
#       If you don't do it this way you might get "Unknown response" in the logs,
#         but the android SDK tool **won't** fail, it'll just **NOT** install the package.
RUN echo y | android update sdk --no-ui --all --filter platform-tools | grep 'package installed'

# SDKs
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter android-25 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter android-24 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter android-23 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter android-22 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter android-19 | grep 'package installed'

# build tools
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter build-tools-25.0.2 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter build-tools-25.0.1 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter build-tools-24.0.3 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter build-tools-23.0.3 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter build-tools-22.0.1 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter build-tools-19.1.0 | grep 'package installed'

# Android System Images, for emulators
# Please keep these in descending order!
# RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-24 | grep 'package installed'
# RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-22 | grep 'package installed'
# RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-21 | grep 'package installed'
# RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-19 | grep 'package installed'
# RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-17 | grep 'package installed'
# RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-15 | grep 'package installed'

# Extras
RUN echo y | android update sdk --no-ui --all --filter extra-android-m2repository | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter extra-google-m2repository | grep 'package installed'
# RUN echo y | android update sdk --no-ui --all --filter extra-android-support | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter extra-google-google_play_services | grep 'package installed'

# google apis
# Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter addon-google_apis-google-23 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter addon-google_apis-google-22 | grep 'package installed'

SHELL ["/bin/bash", "--login", "-c"]

# ENV SDKMAN_DIR /usr/local/sdkman

# SDK Manager
RUN curl -s "https://get.sdkman.io" | bash && \
 	source "$HOME/.sdkman/bin/sdkman-init.sh"


# ------------------------------------------------------
# --- Install Gradle from PPA

# Gradle PPA
RUN source "/root/.sdkman/bin/sdkman-init.sh" && sdk install gradle 2.14.1
# RUN apt-get update
# RUN apt-get -y install gradle
RUN gradle -v

# # ------------------------------------------------------
# # --- Install Maven 3 from PPA

# RUN apt-get purge maven maven2
# RUN apt-get update
# RUN apt-get -y install maven
# RUN mvn --version

# ------------------------------------------------------
# --- Install Fastlane

SHELL ["/bin/sh", "-c"]

RUN gem install fastlane --no-document
RUN fastlane --version

# ------------------------------------------------------
# --- Install Google Cloud SDK
# https://cloud.google.com/sdk/downloads
#  Section: apt-get (Debian and Ubuntu only)
#
# E.g. for "Using Firebase Test Lab for Android from the gcloud Command Line":
#  https://firebase.google.com/docs/test-lab/command-line
#

# RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk-`lsb_release -c -s` main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# RUN sudo apt-get update -qq
# RUN sudo apt-get install -y -qq google-cloud-sdk

# ENV GCLOUD_SDK_CONFIG /usr/lib/google-cloud-sdk/lib/googlecloudsdk/core/config.json

# # gcloud config doesn't update config.json. See the official Dockerfile for details:
# #  https://github.com/GoogleCloudPlatform/cloud-sdk-docker/blob/master/Dockerfile
# RUN /usr/bin/gcloud config set --installation component_manager/disable_update_check true
# RUN sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' $GCLOUD_SDK_CONFIG

# RUN /usr/bin/gcloud config set --installation core/disable_usage_reporting true
# RUN sed -i -- 's/\"disable_usage_reporting\": false/\"disable_usage_reporting\": true/g' $GCLOUD_SDK_CONFIG

# ENV BITRISE_DOCKER_REV_NUMBER_ANDROID v2016_12_13_1
# CMD bitrise -version

# GO to workspace
RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace
