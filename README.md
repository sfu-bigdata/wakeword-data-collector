![Secret Sauce AI](https://github.com/secretsauceai/secret_sauce_ai/blob/main/SSAI_logo_2.3_compressed_cropped.png?raw=true)
# Wakeword Data Collector
![Wake word](https://github.com/secretsauceai/secret_sauce_ai/blob/main/SSAI_wakeword_scene_compressed.png?raw=true)
## Do you want your own personal wakeword?
Wakeword Data Collector is a prototype CLI to record wakewords, non-wakewords, and background noise written in Python. Think of it as your wakeword data collection recipe for creating bullet proof wakeword models. It's part of the Secret Sauce AI [Wakeword Project](https://github.com/secretsauceai/secret_sauce_ai/wiki/Wakeword-Project).

![wakeword data collector wakeword collection example](https://github.com/secretsauceai/secret_sauce_ai/blob/main/SSAI_ww_collector_01.1.gif)

The Wakeword Data Collector records wave files with a sample rate of `16000` for two main categories of data:
* Wakewords (ie 'hey Jarvis') `audio/wake-word/`
  * Wakeword variations (ie saying 'hey jarvis' further/closer to the mic, faster, or slower) `audio/wake-word/variations/`
* Not-wakewords `audio/not-wake-word/`
   * background noise recordings `audio/not-wake-word/background/`
   * syllables (ie 'hey, jar, vis') `audio/not-wake-word/parts/`
   * combinations of syllable permutations (ie 'hey jar', 'jarvis') `audio/not-wake-word/parts/`
   * other longer recordings: recording the TV and a natural conversation `audio/not-wake-word/`

## Installation
You may have to install the pyaudio dependency, ie:
`sudo apt-get install portaudio19-dev`.

As usual once you have cloned the repo, it is recommended to create and activate python virtual environment to install the requirements.
```console
python3 -m venv .venv
source .venv/bin/activate
pip3 install -e .
```

## Docker

### Audio prerequisites

Audio for containerized applications is managed by pulseaudio. 

#### Ubuntu

PulseAudio is part of Ubuntu and is likely pre-installed. Copy/paste the following commands into a shell terminal to creata an environment file `ubuntu.env` in the current directory.
```bash
cat > ubuntu.env << EOF
export PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native
EOF
```

#### MacOS

Install PulseAudio with Homebrew `brew install pulseaudio` and launch with `brew services start pulseaudio`. Further details and examples can be found [here](https://devops.datenkollektiv.de/running-a-docker-soundbox-on-mac.html "Install PulseAudio on the Mac host").

Alternatively, use `sudo pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon --system -v` to start pulseaudio instead of `brew services start pulseaudio`

To play sounds from the docker container, create an environment file `mac.env` with the following variables.

Copy/paste the following commands into a shell terminal to create a file `mac.env` in the current directory.
```bash
cat > mac.env << EOF
export PULSE_SERVER=host.docker.internal
EOF
```
#### Windows Docker with WSL2 backend

On Windows, PulseAusio support is provided by the [WSL2 and WSLg backends](https://github.com/microsoft/wslg). With WSL support, the audio configuration is similar to [ubuntu](#ubuntu).

- Ensure latest version of WSL is installed `wsl --update` _[requires admin privileges]_
- Set default version as WSL2 `wsl --set-default-version 2` _[requires admin privileges]_
- Create an environemnt file `wsl.env`

Copy/paste the following commands into a shell terminal to create a file `wsl.env` in the current directory. 
> The file encoding must be readbale/supported by the underlying *nix shell. The PowerShell `Write-Output` command may produce a file with unexpected encodings/line terminations. The safest method is to create this file via text editor (e.g. notepad) and paste the two lines with `export`.
```bash
cat > wsl.env << EOF
export PULSE_SERVER=unix:/mnt/wslg/PulseServer
export XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir
EOF
```

#### Test the audio

1. Play a known sound with `aplay /usr/share/sounds/alsa/Front_Center.wav`.

2. Record a sound with `arecord -d 5 -f U8 sample.mp3` and playback with `aplay` command.

If the above tests are able to playback and record, then docker is able to use the speaker and microphone from the container app. Otherwise, further troubleshooting may be needed [^1].

[^1]: https://askubuntu.com/questions/57810/how-to-fix-no-soundcards-found/815516#815516

3. To test speaker to check if the audio can be played from inside container try running `docker run -it -e PULSE_SERVER=host.docker.internal -v ~/.config/pulse:/home/pulseaudio/.config/pulse --entrypoint speaker-test --rm jess/pulseaudio -c 2 -l 1 -t wav`

4. In case of a situation where you would want to kill pulseaudio and start again you can do so by using commands like `pulseaudio --kill` or `brew services stop pulseaudio`

### Build & Run

With [Compose](https://docs.docker.com/compose), we can use a YAML file to configure the application. Then, with a single command, create and start all the services from the configuration.
* Build the image from the dockerfile using [`docker compose`](https://docs.docker.com/compose)
	* Get the dockerfile from this repo 
  * build it, for example: `docker compose build` or `docker build -t precise-wakeword-model-maker .`

* Developers can run the container with the command `docker compose run secretsauce-data-collector` which mounts the entire wakeword-data-collector folder and launches a terminal prompt
  * Run the collector with `source .venv/bin/activate` , then `cd wakeword-data-collector/` and finally `wakeword_collect`
  * In case of 'PackageNotFoundError: No package metadata was found for wakeword-collector' run command `pip install -e wakeword-data-collector` before running wakeword_collect
* All other users can run the collector with `docker compose -f production.yaml run secretsauce-data-collector` which automatically launches the `wakeword_collect` and mounts the directory of `audio` recordings

> Note: when using the docker configuration, you will need to one-time configure a dedicated network using the commnad `docker network create -d bridge secretsauce`

## Usage
Simply run `wakeword_collect` in your console and follow the instructions.
```
wakeword_collect
```

For a first time user, it is highly recommended to do a full data collection of all steps (besides `3. Non-wake-word recordings` which is optional) to ensure a production quality wakeword.
* `1. First set of 16 wakeword recordings`
* `2. Wakeword syllable and syllable permutation recordings`
* `4. Second set of 16 wakeword recordings`
* `5. Wakeword variations`
* `6. Third set of 16 wakeword recordings`
* `7. First random conversation recordings`
* `8. Second random TV recording`
* `9. Second random TV recording`
* The background recordings taken throughout the sessions will be in `audio/not-wake-word/background/`

If you are doing a data collection to add another user it is recommended to record:
* `1. First set of 16 wakeword recordings`
* `7. First random conversation recording`
* All of the background recordings from this session in `audio/not-wake-word/background/`
* `2. Wakeword syllable and syllable permutation recordings` is optional, but it can help


### IMPORTANT
* It is recommended to use your production audio hardware and location to collect the samples.
* It is best to use a wakeword with at least three syllables.
* Make sure to check each recording, it is always possible something went wrong. Even one bad or missing recording can be the difference between a bullet proof and a craptastic wakeword model. 
* After collecting your data, it is highly recommended to run the [Precise Wakeword Model Maker](https://github.com/secretsauceai/precise-wakeword-model-maker).

## Secret Sauce AI
* [Secret Sauce AI Overview](https://github.com/secretsauceai/secret_sauce_ai)
* [Wakeword Project](https://github.com/secretsauceai/secret_sauce_ai/wiki/Wakeword-Project)
    * [Precise Wakeword Model Maker](https://github.com/secretsauceai/precise-wakeword-model-maker) 
    * [Precise TensorFlow Lite Engine](https://github.com/OpenVoiceOS/precise_lite_runner)
    * [Precise Rust Engine](https://github.com/sheosi/precise-rs)
    * [SpeechPy MFCC in Rust](https://github.com/secretsauceai/mfcc-rust)

### Special thanks
Although Secret Sauce AI is always about collaboration and community, special thanks should go to [Dan "The Man" Borufka](https://github.com/polygoat/) for his support since day one. Thanks, Dan! 
