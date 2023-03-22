#### base image ####
####################
FROM python:3.7.12 AS base

# Install Packages via apt and pip
RUN apt-get update && apt-get install -y --force-yes \
    git \
    portaudio19-dev \
    alsa-utils \
    pulseaudio

RUN pip install --upgrade pip

# Clone Precise Wakeword Model Maker from Secret Sauce AI git repo
RUN mkdir /app 
WORKDIR /app

#### dev image ####
###################
FROM base as dev
# Dev:
COPY . wakeword-data-collector/ 

# Pip Install additional dependencies in venv
RUN python3 -m venv .venv
RUN /app/.venv/bin/python3 -m pip install --upgrade pip
RUN .venv/bin/pip install -e wakeword-data-collector

WORKDIR /app
RUN touch version-`date +%Y-%m-%d:%H:%M.%p`.dev

# Start audio server
# RUN pulseaudio --daemonize --system
# RUN modprobe snd-hda-intel

# So we start it with bash, a user types 'source .venv/bin/activate' and then runs the command "wakeword_collect"
# CMD "/app/.venv/bin/wakeword_collect"
CMD bash


