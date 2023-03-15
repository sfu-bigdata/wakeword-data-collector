#### base image ####
####################
FROM python:3.7.12 AS base

# Install Packages via apt and pip
RUN apt-get update
RUN apt-get install git portaudio19-dev -y --force-yes
RUN pip install --upgrade pip

# Clone Precise Wakeword Model Maker from Secret Sauce AI git repo
RUN mkdir /app 
WORKDIR /app

#### dev image ####
###################
FROM base as dev
# Prod:
# RUN git clone https://github.com/secretsauceai/wakeword-data-collector.git .
# Dev
COPY . wakeword-data-collector/ 

# Pip Install additional dependencies in venv
RUN python3 -m venv .venv
RUN .venv/bin/pip install -e wakeword-data-collector

# So we start it with bash, a user types 'source .venv/bin/activate' and then runs the command "wakeword_collect"
WORKDIR /app
RUN touch version.dev
CMD bash

#### prod image ####
####################
FROM base as prod
# Prod:
COPY . wakeword-data-collector/ 
# RUN git clone https://github.com/secretsauceai/wakeword-data-collector.git 

# Pip Install additional dependencies in venv
# WORKDIR wakeword-data-collector
RUN python3 -m venv .venv
RUN .venv/bin/pip install -e wakeword-data-collector

WORKDIR app
RUN touch version.prod

# I would love to start the container and it opens in the terminal in the venv with this script running, then a user can select which option they want, but it doesn't seem to work.
# CMD "/app/.venv/bin/wakeword_collect"
ENTRYPOINT "/app/.venv/bin/wakeword_collect"

# So we start it with bash, a user types 'source .venv/bin/activate' and then runs the command "wakeword_collect"
# WORKDIR /app
# CMD bash
# CMD source .venv/bin/activate
# CMD wakeword_collect