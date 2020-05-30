#!/bin/bash

# Directories and Files
LIBDIR=./tools/lib/
LIBAFA=libaudiofile.a
LIBAFLA=libaudiofile.la
AUDDIR=./tools/audiofile-0.3.6
MASTER=./sm64pc-master/
MASTER_GIT=./sm64pc-master/.git/
MASTER_ROM=./sm64pc-master/baserom.us.z64
MASTER_OLD=./sm64pc-master.old/baserom.us.z64
NIGHTLY=./sm64pc-nightly/
NIGHTLY_GIT=./sm64pc-nightly/.git/
NIGHTLY_ROM=./sm64pc-nightly/baserom.us.z64
NIGHTLY_OLD=./sm64pc-nightly.old/baserom.us.z64
OLD_BUILD_SH=../build_1.5.5-test.sh

# Command line options
OPTIONS=("Analog Camera" "No Draw Distance" "Texture Fixes" "Allow External Textures | Nightly Only" "Remove Extended Options Menu | Remove additional R button menu options" "OpenGL 1.3 Renderer | Unrecommended. Only use if your machine is very old" "Build for the web" "Build for a Raspberry Pi" "Clean build")
EXTRA=("BETTERCAMERA=1" "NODRAWINGDISTANCE=1" "TEXTURE_FIX=1" "EXTERNAL_TEXTURES=1" "EXT_OPTIONS_MENU=0" "LEGACY_GL=1" "TARGET_WEB=1" "TARGET_RPI=1" "clean")

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

if [ -f "$OLD_BUILD_SH" ]; then
	rm ../build_1.5.5-test.sh
else
	pull https://github.com/gunvalk/sm64pcBuilder


#Installs the msys dependency bullshit if it's not installed yet
if  [[ ! $(command -v make) || ! $(command -v git) ]]; then
	printf "\n${RED}dependencies are missing. Proceeding with the installation... ${RESET}\n" >&2
	pacman -S --needed base-devel mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain \
                    git subversion mercurial \
                    mingw-w64-i686-cmake mingw-w64-x86_64-cmake --noconfirm
    pacman -S mingw-w64-i686-glew mingw-w64-x86_64-glew mingw-w64-i686-SDL2 mingw-w64-x86_64-SDL2 mingw-w64-i686-python-xdg mingw-w64-x86_64-python-xdg python3 --noconfirm
	pacman -Syuu --noconfirm
else
	printf "\n${GREEN}dependencies are already installed ${RESET}\n"
fi

# Gives options to download from the Github
printf "\n${GREEN}Would you like to download the latest source files from Github? ${CYAN}(y/n) ${RESET}\n"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	printf "\n${GREEN}Would you like to download the master (stable version with new updates)\nor the nightly (newest experimental version)? ${CYAN}(master/nightly) ${RESET}\n"
    read answer
	if [ "$answer" != "${answer#[Mm]}" ] ;then
		# Checks for existence of previous .git folder, then creates one if it doesn't exist and moves the old folder
		if [ -d "$MASTER_GIT" ]; then
			cd ./sm64pc-master
			printf "\n"
			git stash push
			git stash drop
			git pull https://github.com/sm64pc/sm64pc
			I_Want_Master=true
			cd ../
		else
			if [ -d "$MASTER" ]; then
				mv sm64pc-master sm64pc-master.old
				printf "\n"
				git clone git://github.com/sm64pc/sm64pc sm64pc-master
				I_Want_Master=true
			else
				printf "\n"
				git clone git://github.com/sm64pc/sm64pc sm64pc-master
				I_Want_Master=true
			fi
		fi
	else
		if [ -d "$NIGHTLY_GIT" ]; then
			cd ./sm64pc-nightly
			printf "\n"
			git stash push
			git stash drop
			git pull https://github.com/sm64pc/sm64pc
			I_Want_Nightly=true
			cd ../
		else
			if [ -d "$NIGHTLY" ]; then
				printf "\n"
				mv sm64pc-nightly sm64pc-nightly.old
				git clone -b nightly git://github.com/sm64pc/sm64pc sm64pc-nightly
				I_Want_Nightly=true
			else
				printf "\n"
				git clone -b nightly git://github.com/sm64pc/sm64pc sm64pc-nightly
				I_Want_Nightly=true
			fi
		fi
	fi
else
	if  [[ ! -d "$MASTER" && ! -d "$NIGHTLY" ]]; then
		printf "\n${RED}WARNING: Source files are missing. You need to download them before you proceed.\n"
		sleep 3
		printf "\n${GREEN}Would you like to download the master (stable version with new updates)\nor the nightly (newest experimental version)? ${CYAN}(master/nightly) ${RESET}\n"
    	read answer
		if [ "$answer" != "${answer#[Mm]}" ] ;then
			# Checks for existence of previous .git folder, then creates one if it doesn't exist and moves the old folder
			if [ -d "$MASTER_GIT" ]; then
				cd ./sm64pc-master
				printf "\n"
				git stash push
				git stash drop
				git pull https://github.com/sm64pc/sm64pc
				I_Want_Master=true
				cd ../
			else
				if [ -d "$MASTER" ]; then
					mv sm64pc-master sm64pc-master.old
					printf "\n"
					git clone git://github.com/sm64pc/sm64pc sm64pc-master
					I_Want_Master=true
				else
					printf "\n"
					git clone git://github.com/sm64pc/sm64pc sm64pc-master
					I_Want_Master=true
				fi
			fi
		else
			if [ -d "$NIGHTLY_GIT" ]; then
				cd ./sm64pc-nightly
				printf "\n"
				git stash push
				git stash drop
				git pull https://github.com/sm64pc/sm64pc
				I_Want_Nightly=true
				cd ../
			else
				if [ -d "$NIGHTLY" ]; then
					printf "\n"
					mv sm64pc-nightly sm64pc-nightly.old
					git clone -b nightly git://github.com/sm64pc/sm64pc sm64pc-nightly
					I_Want_Nightly=true
				else
					printf "\n"
					git clone -b nightly git://github.com/sm64pc/sm64pc sm64pc-nightly
					I_Want_Nightly=true
				fi
			fi
		fi
	fi
    printf "\n${GREEN}Are you building master or nightly? ${CYAN}(master/nightly) ${RESET}\n"
	read answer
	if [ "$answer" != "${answer#[Mm]}" ] ;then
		cd ./sm64pc-master
		if [[ `git status --porcelain` ]]; then
			printf "\n${GREEN}An update to the master branch is available. Would you like to update? ${CYAN}(y/n) ${RESET}\n"
			read answer
			if [ "$answer" != "${answer#[Yy]}" ]; then
				printf "\n"
				git stash push
				git stash drop
				git pull https://github.com/sm64pc/sm64pc
				I_Want_Master=true
				cd ../
			fi
		fi
	else
		cd ./sm64pc-nightly
		if [[ `git status --porcelain` ]]; then
			printf "\n${GREEN}An update to the nightly branch is available. Would you like to update? ${CYAN}(y/n) ${RESET}\n"
			read answer
			if [ "$answer" != "${answer#[Yy]}" ]; then
				printf "\n"
				git stash push
				git stash drop
				git pull https://github.com/sm64pc/sm64pc
				I_Want_Nightly=true
				cd ../
			fi
		fi
	fi
fi

# Checks for baserom in sm64pc-master or sm64pc-nightly
if [ -f "$MASTER_ROM" ]; then
	Base_Rom=true
fi

if [ -f "$NIGHTLY_ROM" ]; then
	Base_Rom=true
fi

# Checks for a pre-existing baserom file in old folder then moves it to the new one
if [ -f "$MASTER_OLD" ]; then
	cd ./sm64pc-master.old
    mv baserom.us.z64 ../sm64pc-master/baserom.us.z64
	cd ../
	Base_Rom=true
fi

if [ -f "$NIGHTLY_OLD" ]; then
	cd ./sm64pc-nightly.old
    mv baserom.us.z64 ../sm64pc-nightly/baserom.us.z64
	cd ../
	Base_Rom=true
fi

if [ "$Base_Rom" = true ] ; then
	printf "\n\n${GREEN}Existing baserom found${RESET}"
else
	if [ "$I_Want_Master" = true ]; then
		printf "\n${YELLOW}Place your baserom.us.z64 file in the ${MASTER} folder${RESET}"
		read -n 1 -r -s -p $'\n\nPRESS ENTER TO CONTINUE...\n'
	fi
	
	if [ "$I_Want_Nightly" = true ]; then
		printf "\n${YELLOW}Place your baserom.us.z64 file in the ${NIGHTLY} folder${RESET}"
		read -n 1 -r -s -p $'\n\nPRESS ENTER TO CONTINUE...\n'
	fi
fi

# Checks for which version the user selected
if [ "$I_Want_Master" = true ]; then
    cd ./sm64pc-master
fi

if [ "$I_Want_Nightly" = true ]; then
    cd ./sm64pc-nightly
fi

# Checks to see if the libaudio directory and files exist
if [ -d "$LIBDIR" -a -e "${LIBDIR}$LIBAFA" -a -e "${LIBDIR}$LIBAFLA"  ]; then
    printf "\n${GREEN}libaudio files exist, going straight to compiling.${RESET}\n"
else 
    printf "\n${GREEN}libaudio files not found, starting initialization process.${RESET}\n\n"

    printf "${YELLOW} Changing directory to: ${CYAN}${AUDDIR}${RESET}\n\n"
		cd $AUDDIR

    printf "${YELLOW} Executing: ${CYAN}autoreconf -i${RESET}\n\n"
		autoreconf -i

	#Checks the computer architecture
	if [ `getconf LONG_BIT` = "64" ]; then
    	printf "\n${YELLOW} Executing: ${CYAN}./configure --disable-docs${RESET}\n\n"
			PATH=/mingw64/bin:/mingw32/bin:$PATH LIBS=-lstdc++ ./configure --disable-docs

    	printf "\n${YELLOW} Executing: ${CYAN}make -j${RESET}\n\n"
			PATH=/mingw64/bin:/mingw32/bin:$PATH make -j
	else
		if [ `getconf LONG_BIT` = "32" ]; then
			printf "\n${YELLOW} Executing: ${CYAN}./configure --disable-docs${RESET}\n\n"
				PATH=/mingw32/bin:/mingw64/bin:$PATH LIBS=-lstdc++ ./configure --disable-docs

    		printf "\n${YELLOW} Executing: ${CYAN}make${RESET}\n\n"
				PATH=/mingw32/bin:/mingw64/bin:$PATH make
		fi
	fi
    printf "\n${YELLOW} Making new directory ${CYAN}../lib${RESET}\n\n"
		mkdir ../lib


    printf "${YELLOW} Copying libaudio files to ${CYAN}../lib${RESET}\n\n"
		cp libaudiofile/.libs/libaudiofile.a ../lib/
		cp libaudiofile/.libs/libaudiofile.la ../lib/

    printf "${YELLOW} Going up one directory.${RESET}\n\n"
		cd ../
		
		#Checks if the Makefile has already been changed

		sed -i 's/tabledesign_CFLAGS := -Wno-uninitialized -laudiofile/tabledesign_CFLAGS := -Wno-uninitialized -laudiofile -lstdc++/g' Makefile

	#Checks the computer architecture
    if [ `getconf LONG_BIT` = "64" ]; then
    	printf "${YELLOW} Executing: ${CYAN}make -j${RESET}\n\n"
			PATH=/mingw64/bin:/mingw32/bin:$PATH make -j
	else
		if [ `getconf LONG_BIT` = "32" ]; then
			printf "${YELLOW} Executing: ${CYAN}make${RESET}\n\n"
				PATH=/mingw32/bin:/mingw64/bin:$PATH make
		fi
	fi
    printf "\n${YELLOW} Going up one directory.${RESET}\n"
		cd ../
fi 

menu() {
		printf "\nAvaliable options:\n"
		for i in ${!OPTIONS[@]}; do 
				printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${OPTIONS[i]}"
		done
		if [[ "$msg" ]]; then echo "$msg"; fi
		printf "${YELLOW}Please do not select \"Clean build\" with any other option.\n"
		printf "${RED}WARNING: Backup your save file before selecting \"Clean build\".\n"
		printf "${CYAN}Press the corresponding number and press enter to select it.\nWhen all desired options are selected, press Enter to continue.\n"
		printf "${YELLOW}Check Remove Extended Options Menu & leave other options unchecked for a Vanilla\nbuild.\n${RESET}"
}

prompt="Check an option (again to uncheck, press ENTER):"$'\n'
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
		[[ "$num" != *[![:digit:]]* ]] &&
		(( num > 0 && num <= ${#OPTIONS[@]} )) ||
		{ msg="Invalid option: $num"; continue; }
		((num--)); # msg="${OPTIONS[num]} was ${choices[num]:+un}checked"
		[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
done

for i in ${!OPTIONS[@]}; do 
		[[ "${choices[i]}" ]] && { CMDL+=" ${EXTRA[i]}"; }
done 

#Checks the computer architecture
if [ "${CMDL}" != " clean" ] && [ `getconf LONG_BIT` = "64" ]; then
	printf "${YELLOW}Only cross-compile if you intend to play the game on an OS that has a different\narchitecture than yours. ${RESET}\n"
	printf "${CYAN}Make sure to select \"Clean build\" before attempting to cross-compile. ${RESET}\n"
	printf "${GREEN}Would you like to cross-compile a 32-bit binary? ${CYAN}(y/n) ${RESET}\n"
	read answer
	if [ "$answer" != "${answer#[Yy]}" ]; then
		printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL} TARGET_BITS=32 -j${RESET}\n\n"
		PATH=/mingw32/bin:/mingw64/bin:$PATH make $CMDL TARGET_BITS=32 -j
	else
		printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL} -j${RESET}\n\n"
		PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL -j
	fi

	if [ "${CMDL}" != " clean" ] && [ `getconf LONG_BIT` = "32" ]; then
	printf "${YELLOW}Only cross-compile if you intend to play the game on an OS that has a different\narchitecture than yours. ${RESET}\n"
	printf "${CYAN}Make sure to select \"Clean build\" before attempting to cross-compile. ${RESET}\n"
	printf "${GREEN}Would you like to cross-compile a 64-bit binary? ${CYAN}(y/n) ${RESET}\n"
	read answer
		if [ "$answer" != "${answer#[Yy]}" ]; then
			printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL} TARGET_BITS=64${RESET}\n\n"
			PATH=/mingw32/bin:/mingw64/bin:$PATH make $CMDL TARGET_BITS=64
		else
			printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL} TARGET_BITS=32${RESET}\n\n"
			PATH=/mingw32/bin:/mingw64/bin:$PATH make $CMDL TARGET_BITS=32
		fi
	fi

	#Check if an exe was built
	if [ "$?" = "0" ]; then
		printf "\n${GREEN}The sm64pc binary is now available in the 'build/us_pc/' folder.\n"
		printf "\n${YELLOW}If fullscreen doesn't seem like the correct resolution, then right click on the\nexe, go to properties, compatibility, then click Change high DPI settings.\nCheck the 'Override high DPI scaling behavior' checkmark, leave it on application,\nthen press apply."
		# allow the user to run the game from here in the script if they wish
		#printf "${CYAN}Would you like to run the game? [y or n]: ${RESET}"
		#read answer
		#if [ "$answer" == "${answer#[Yy]}" && [ TARGET_WEB ] && [ ! TARGET_RPI ] ] ]; then
			#xdg-open build/us_pc/sm64.us.f3dex2e.html
		#else
			#if [ "$answer" == "${answer#[Yy]}" && [ ! TARGET_WEB ] && [ ! TARGET_RPI ] ] ]; then
    			#exec build/us_pc/sm64.us.f3dex2e.exe
    		#fi
    	#fi
	else
		printf "\n${RED}Oh no! Something went wrong."
	fi
	
else
	if [ `getconf LONG_BIT` = "64" ]; then
		printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL} -j${RESET}\n\n"
		PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL -j
	else
		if [ `getconf LONG_BIT` = "32" ]; then
		printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL}${RESET}\n\n"
		PATH=/mingw32/bin:/mingw64/bin:$PATH make $CMDL
		fi
	fi
	printf "\nYour build is now clean.\n"
fi 