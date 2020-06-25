#!/bin/bash

if [ PWD != "/c/sm64pcBuilder" ]; then
	cd c:/sm64pcBuilder
fi

if [ ! -d BuilderRepos ]; then
	mkdir C:/Users/$USER/Desktop/BuilderRepos
fi

# Delete their setup or old shit
if [ -d sm64ex-master ]; then
	mv sm64ex-master C:/Users/$USER/Desktop/BuilderRepos
fi

if [ -d sm64ex-nightly ]; then
	mv sm64ex-nightly C:/Users/$USER/Desktop/BuilderRepos
fi

if [ -d sm64-port ]; then
	mv sm64-port C:/Users/$USER/Desktop/BuilderRepos
fi

if [ -d sm64pc-master ]; then
	mv sm64pc-master C:/Users/$USER/Desktop/BuilderRepos
fi

if [ -d sm64pc-nightly ]; then
	mv sm64pc-nightly C:/Users/$USER/Desktop/BuilderRepos
fi

if [ -d sm64-port-master ]; then
	mv sm64-port-master C:/Users/$USER/Desktop/BuilderRepos
fi

if [ -d ../sm64pcBuilder ]; then
	rm -rf ../sm64pcBuilder
fi

if [ -f $HOME/build-setup.sh ]; then
	rm $HOME/build-setup.sh
fi

if [ -f $HOME/build.sh ]; then
	rm $HOME/build.sh
fi

# Colors
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# Checks for zenity and installs it if it's missing
if [ ! -f $MINGW_HOME/bin/zenity.exe ]; then
	wget -O $MINGW_HOME/bin/zenity.exe https://cdn.discordapp.com/attachments/718584345912148100/721406762884005968/zenity.exe
fi

echo -e "\n${GREEN}zenity is already installed. ${RESET}\n"

# sm64pcBuilder 2 download info
zenity --info \
--text="sm64pcBuilder has been discontinued. You will now be
redirected to its successor, sm64pcBuilder2.
Your sm64ex-master, sm64ex-nightly, and/or
sm64-port folders can now be found at your desktop
in a folder called \"BuilderRepos\""

# Redirect to sm64pcBuilder 2
start https://sm64pc.info/sm64pcbuilder2/
