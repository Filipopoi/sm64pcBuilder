#!/bin/bash

# Directories and Files
LIBDIR=./tools/lib/
LIBAFA=libaudiofile.a
LIBAFLA=libaudiofile.la
AUDDIR=./tools/audiofile-0.3.6
OFFICIAL=./sm64-port/
OFFICIAL_GIT=./sm64-port/.git/
OFFICIAL_OLD=./sm64-port.old/baserom.us.z64
MASTER=./sm64pc-master/
MASTER_GIT=./sm64pc-master/.git/
MASTER_OLD=./sm64pc-master.old/baserom.us.z64
NIGHTLY=./sm64pc-nightly/
NIGHTLY_GIT=./sm64pc-nightly/.git/
NIGHTLY_OLD=./sm64pc-nightly.old/baserom.us.z64
ROM_CHECK=./baserom.us.z64
BINARY=./build/us_pc/sm64*
FOLDER_PLACEMENT=C:/sm64pcBuilder
MACHINE_TYPE=`uname -m`

# Command line options
OFFICIAL_OPTIONS=("Build using JP ROM | May contain glitches" "Build using EU ROM | May contain glitches" "Build an N64 ROM" "Clean build | This deletes the build folder")
OFFICIAL_EXTRA=("VERSION=jp" "VERSION=eu" "TARGET_N64=1" "clean")
MASTER_OPTIONS=("Analog Camera" "No Draw Distance" "Texture Fixes" "Remove Extended Options Menu | Remove additional R button menu options" "Clean build | This deletes the build folder")
MASTER_EXTRA=("BETTERCAMERA=1" "NODRAWINGDISTANCE=1" "TEXTURE_FIX=1" "EXT_OPTIONS_MENU=0" "clean")
NIGHTLY_OPTIONS=("Analog Camera" "No Draw Distance" "Texture Fixes" "Allow External Resources" "Discord Rich Presence" "Remove Extended Options Menu | Remove additional R button menu options" "Build using JP ROM | May contain glitches" "Build using EU ROM | May contain glitches" "DirectX 11 Renderer" "DirectX 12 Renderer" "OpenGL 1.3 Renderer | Unrecommended. Only use if your machine is very old" "Clean build | This deletes the build folder")
NIGHTLY_EXTRA=("BETTERCAMERA=1" "NODRAWINGDISTANCE=1" "TEXTURE_FIX=1" "EXTERNAL_DATA=1" "DISCORDRPC=1" "EXT_OPTIONS_MENU=0" "VERSION=jp" "VERSION=eu" "RENDER_API=D3D11" "RENDER_API=D3D12" "LEGACY_GL=1" "clean")

# Extra dependency checks
DEPENDENCIES_OFFICIAL_64=("git" "make" "python3" "mingw-w64-x86_64-gcc")
DEPENDENCIES_OFFICIAL_32=("git" "make" "python3" "mingw-w64-i686-gcc")
DEPENDENCIES_UNOFFICIAL=("git" "make" "zip" "unzip" "curl" "unrar" "mingw-w64-i686-gcc" "mingw-w64-x86_64-gcc" "mingw-w64-i686-glew" "mingw-w64-x86_64-glew" "mingw-w64-i686-SDL2" "mingw-w64-x86_64-SDL2")

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

if [ PWD != "/c/sm64pcBuilder" ]; then
	cd c:/sm64pcBuilder
fi

# Antivirus fuck you message
if [ -d "C:/Program Files/Avast Software/" ] || [ -d "C:/Program Files (x86)/Avast Software/" ]; then
	echo -e "\n${RED}Avast Detected${RESET}\n\n${YELLOW}Uninstall Avast. It's garbage and will fuck up your install.\nAt the very least make sure it's disabled.${RESET}\n"
	sleep 3
fi

if [ -d "C:/Program Files/AVG/" ] || [ -d "C:/Program Files (x86)/AVG/" ]; then
	echo -e "\n${RED}AVG Detected${RESET}\n\n${YELLOW}Uninstall AVG. It's garbage and will fuck up your install.\nAt the very least make sure it's disabled.${RESET}\n"
	sleep 3
fi

if [ -d "C:/Program Files/Norton Security/" ] || [ -d "C:/Program Files (x86)/Norton Security/" ]; then
	echo -e "\n${RED}Norton Security Detected${RESET}\n\n${YELLOW}Uninstall Norton Security. It's garbage and will fuck up your install.\nAt the very least make sure it's disabled.${RESET}\n"
	sleep 3
fi

if [ -d "C:/Program Files/McAfee/" ] || [ -d "C:/Program Files (x86)/McAfee/" ]; then
	echo -e "\n${RED}McAfee Detected${RESET}\n\n${YELLOW}Uninstall McAfee. It's garbage and will fuck up your install.\nAt the very least make sure it's disabled.${RESET}\n"
	sleep 3
fi

if [ -d "C:/Program Files/Kaspersky Lab/" ] || [ -d "C:/Program Files (x86)/Kaspersky Lab/" ]; then
	echo -e "\n${RED}Kaspersky Detected${RESET}\n\n${YELLOW}Uninstall Kaspersky. It's garbage and will fuck up your install.\nAt the very least make sure it's disabled.${RESET}\n"
	sleep 3
fi

# Update sm64pcbuilder check
pull_sm64pcbuilder () {
	echo -e "\n${YELLOW}Downloading available build.sh updates...${RESET}\n"
	git stash push
	git stash drop
	git pull https://github.com/Filipianosol/sm64pcBuilder
	echo -e "\n${GREEN}Restarting...${RESET}\n"
	sleep 2
	set -- "$1" "$2" "showchangelog"
	exec ./build.sh "$@"
}

# Check for build updates and show changelog if there are
build_update_changelog () {
	[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
	sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}build.sh is up to date\n${RESET}" || pull_sm64pcbuilder "$@"
	# Update message
	if [ "$3" = showchangelog ]; then
	zenity --info  --text "
	SM64PC Builder (by serosis, gunvalk, derailius, Filipianosol, coltonrawr, fgsfds, BrineDude, Recompiler, and others)
	------------------------------
	Updates:

	- Official Port Support
	- Fixed BLJ Anywhere by GateGuy

	------------------------------
	build.sh Update 21"
	fi
}

# Checks for official x64 dependencies
depcheck_official () {
	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
		echo -e "\n${YELLOW}Checking dependencies... ${RESET}\n"
		for i in ${DEPENDENCIES_OFFICIAL_64[@]}; do
			if [[ ! $(pacman -Q $i 2> /dev/null) ]]; then
				pacman -Syu --noconfirm
				pacman -Su --noconfirm
				pacman -S $i --noconfirm
				pacman -Syuu --noconfirm
			fi
		done
	else
		for i in ${DEPENDENCIES_OFFICIAL_32[@]}; do
			if [[ ! $(pacman -Q $i 2> /dev/null) ]]; then
				pacman -Syu --noconfirm
				pacman -Su --noconfirm
				pacman -S $i --noconfirm
				pacman -Syuu --noconfirm
			fi
		done
	fi

	if [ ! -f $MINGW_HOME/bin/zenity.exe ]; then
		wget -O $MINGW_HOME/bin/zenity.exe https://cdn.discordapp.com/attachments/718584345912148100/721406762884005968/zenity.exe
	fi

	echo -e "\n${GREEN}Dependencies are installed. ${RESET}\n"
}

depcheck_unofficial () {
	# Checks for common required executables (make, git) and installs everything if they are missing
	if  [[ ! $(command -v make) || ! $(command -v git) ]]; then
		echo -e "\n${RED}Dependencies are missing. Proceeding with the installation... ${RESET}\n" >&2
		pacman -Sy --needed base-devel mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain \
	                    git subversion mercurial \
	                    mingw-w64-i686-cmake mingw-w64-x86_64-cmake --noconfirm
	    pacman -S mingw-w64-i686-glew mingw-w64-x86_64-glew mingw-w64-i686-SDL2 mingw-w64-x86_64-SDL2 mingw-w64-i686-python-xdg mingw-w64-x86_64-python-xdg python3 zip curl --noconfirm
		pacman -Syuu --noconfirm
	fi

	# Checks for some dependencies again
	echo -e "\n${YELLOW}Checking dependencies... ${RESET}\n"
	for i in ${DEPENDENCIES_UNOFFICIAL[@]}; do
		if [[ ! $(pacman -Q $i 2> /dev/null) ]]; then
			pacman -S $i --noconfirm
		fi
	done

	if [ ! -f $MINGW_HOME/bin/zenity.exe ]; then
		wget -O $MINGW_HOME/bin/zenity.exe https://cdn.discordapp.com/attachments/718584345912148100/721406762884005968/zenity.exe
	fi

	echo -e "\n${GREEN}Dependencies are installed. ${RESET}\n"
}

# Gives options to download from GitHub

# Update official check
pull_official () {
	echo -e "\n${YELLOW}Downloading available sm64-port updates...${RESET}\n"
	git stash push
	git stash drop
	git pull
	sleep 2
}

# Update master check
pull_master () {
	echo -e "\n${YELLOW}Downloading available sm64pc-master updates...${RESET}\n"
	git stash push
	git stash drop
	git pull
	sleep 2
}

# Update nightly check
pull_nightly () {
	echo -e "\n${YELLOW}Downloading available sm64pc-nightly updates...${RESET}\n"
	git stash push
	git stash drop
	git pull
	sleep 2
}

if [ "$1" = noupdate ] || [ "$2" = noupdate ]; then
	zenity --question  --text "Which version are you compiling?
The official version's code is cleaner, but
it lacks the new features of the unofficial
version at the moment.
Automatic updates are disabled." \
	--ok-label="Official" \
	--cancel-label="Unofficial"
	if [[ $? = 0 ]]; then
		depcheck_official "$@"
		build_update_changelog "$@"
		I_Want_Official=true
	else
		depcheck_unofficial "$@"
		build_update_changelog "$@"
		zenity --question  --text "Which version are you compiling?
The nightly version is currently recommended.
Automatic updates are disabled." \
		--ok-label="Master" \
		--cancel-label="Nightly"
		if [[ $? = 0 ]]; then
		  I_Want_Master=true
		else
		  I_Want_Nightly=true
		fi
	fi
else
	zenity --question  --text "Which version are you compiling?
The official version's code is cleaner, but
it lacks the new features of the unofficial
version at the moment.
Automatic updates are enabled." \
	--ok-label="Official" \
	--cancel-label="Unofficial"
	if [[ $? = 0 ]]; then
		depcheck_official "$@"
		build_update_changelog "$@"
		if [ -d "$OFFICIAL_GIT" ]; then
			cd ./sm64-port
			echo -e "\n"
			[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
			sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}sm64-port is up to date\n${RESET}" || pull_official "$@"
			if [ -f ./build.sh ]; then
				rm ./build.sh
			fi
			I_Want_Official=true
			cd ../
		else
			if [ -d "$OFFICIAL" ]; then
				mv sm64-port sm64-port.old
			fi
			echo -e "\n"
			git clone https://github.com/sm64-port/sm64-port.git
			I_Want_Official=true
		fi
	else
		depcheck_unofficial "$@"
		build_update_changelog "$@"
		zenity --question  --text "Which version are you compiling?
The nightly version is currently recommended.
Automatic updates are enabled." \
		--ok-label="Master" \
		--cancel-label="Nightly"
		if [[ $? = 0 ]]; then
			if [ -d "$MASTER_GIT" ]; then
				cd ./sm64pc-master
				echo -e "\n"
				[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
				sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}sm64pc-master is up to date\n${RESET}" || pull_master "$@"
				if [ -f ./build.sh ]; then
					rm ./build.sh
				fi
				I_Want_Master=true
				cd ../
			else
				if [ -d "$MASTER" ]; then
					mv sm64pc-master sm64pc-master.old
				fi
				echo -e "\n"
				git clone git://github.com/sm64pc/sm64pc sm64pc-master
				I_Want_Master=true
			fi
		elif [ -d "$NIGHTLY_GIT" ]; then
			cd ./sm64pc-nightly
			echo -e "\n"
			[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
			sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}sm64pc-nightly is up to date\n${RESET}" || pull_nightly "$@"
			if [ -f ./build.sh ]; then
				rm ./build.sh
			fi
			I_Want_Nightly=true
			cd ../
			elif [ -d "$NIGHTLY" ]; then
				echo -e "\n"
				mv sm64pc-nightly sm64pc-nightly.old
				git clone -b nightly git://github.com/sm64pc/sm64pc sm64pc-nightly
				if [ -f ./sm64pc-nightly/build.sh ]; then
					rm ./sm64pc-nightly/build.sh
				fi
				I_Want_Nightly=true
			else
				echo -e "\n"
				git clone -b nightly git://github.com/sm64pc/sm64pc sm64pc-nightly
				if [ -f ./sm64pc-nightly/build.sh ]; then
					rm ./sm64pc-nightly/build.sh
				fi
				I_Want_Nightly=true
		fi
	fi
fi

# Delete their setup or old shit
if [ -f $HOME/build-setup.sh ]; then
	rm $HOME/build-setup.sh
fi

if [ -f $HOME/build.sh ]; then
	rm $HOME/build.sh
fi

# Checks for a pre-existing baserom file in old folder then moves it to the new one
if [ -f "$OFFICIAL_OLD" ]; then
    mv sm64-port.old/baserom.us.z64 sm64-port/baserom.us.z64
fi

if [ -f "$MASTER_OLD" ]; then
    mv sm64pc-master.old/baserom.us.z64 sm64pc-master/baserom.us.z64
fi

if [ -f "$NIGHTLY_OLD" ]; then
    mv sm64pc-nightly.old/baserom.us.z64 sm64pc-nightly/baserom.us.z64
fi

# Checks for which version the user selected & if baserom exists
if [ "$I_Want_Official" = true ]; then
    cd ./sm64-port
    if [ -f "$ROM_CHECK" ]; then
    	echo -e "\n\n${GREEN}Existing baserom found${RESET}\n"
    else
    	echo -e "\n${YELLOW}Select your baserom.us.z64 file${RESET}\n"
    	BASEROM_FILE=$(zenity --file-selection --title="Select the baserom.us.z64 file")
    	cp "$BASEROM_FILE" c:/sm64pcBuilder/sm64-port/baserom.us.z64
	fi
fi

if [ "$I_Want_Master" = true ]; then
    cd ./sm64pc-master
    if [ -f "$ROM_CHECK" ]; then
    	echo -e "\n\n${GREEN}Existing baserom found${RESET}\n"
    else
    	echo -e "\n${YELLOW}Select your baserom.us.z64 file${RESET}\n"
    	BASEROM_FILE=$(zenity --file-selection --title="Select the baserom.us.z64 file")
    	cp "$BASEROM_FILE" c:/sm64pcBuilder/sm64pc-master/baserom.us.z64
	fi
fi

if [ "$I_Want_Nightly" = true ]; then
    cd ./sm64pc-nightly
    if [ -f "$ROM_CHECK" ]; then
    	echo -e "\n\n${GREEN}Existing baserom found${RESET}\n"
    else
    	echo -e "\n${YELLOW}Select your baserom.us.z64 file${RESET}\n"
    	BASEROM_FILE=$(zenity --file-selection --title="Select the baserom.us.z64 file")
    	cp "$BASEROM_FILE" c:/sm64pcBuilder/sm64pc-nightly/baserom.us.z64
	fi
fi

# Swaps noupdate out of the $1 position
if [ "$1" = noupdate ]; then
	set -- "$2"
fi

# Checks to see if the libaudio directory and files exist
if [ -d "${LIBDIR}" -a -e "${LIBDIR}${LIBAFA}" -a -e "${LIBDIR}${LIBAFLA}"  ]; then
    echo -e "\n${GREEN}libaudio files exist, going straight to compiling.${RESET}\n"
elif [ "$I_Want_Master" = true ]; then
	echo -e "\n${GREEN}libaudio files not found, starting initialization process.${RESET}\n\n"

    echo -e "${YELLOW} Changing directory to: ${CYAN}${AUDDIR}${RESET}\n\n"
	cd $AUDDIR

    echo -e "${YELLOW} Executing: ${CYAN}autoreconf -i${RESET}\n\n"
	autoreconf -i

	echo -e "\n${YELLOW} Executing: ${CYAN}./configure --disable-docs${RESET}\n\n"

	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  PATH=/mingw64/bin:/mingw32/bin:$PATH LIBS=-lstdc++ ./configure --disable-docs
	else
	  PATH=/mingw32/bin:$PATH LIBS=-lstdc++ ./configure --disable-docs
	fi

	echo -e "\n${YELLOW} Executing: ${CYAN}make $1${RESET}\n\n"

	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  PATH=/mingw64/bin:/mingw32/bin:$PATH make $1
	else
	  PATH=/mingw32/bin:$PATH make $1
	fi

    echo -e "\n${YELLOW} Making new directory ${CYAN}../lib${RESET}\n\n"
	mkdir ../lib

    echo -e "${YELLOW} Copying libaudio files to ${CYAN}../lib${RESET}\n\n"
	cp libaudiofile/.libs/libaudiofile.a ../lib/
	cp libaudiofile/.libs/libaudiofile.la ../lib/

    echo -e "${YELLOW} Going up one directory.${RESET}\n\n"
	cd ../

	sed -i 's/tabledesign_CFLAGS := -Wno-uninitialized -laudiofile/tabledesign_CFLAGS := -Wno-uninitialized -laudiofile -lstdc++/g' Makefile

	# Checks the computer architecture
	echo -e "${YELLOW} Executing: ${CYAN}make $1${RESET}\n\n"

	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  PATH=/mingw64/bin:/mingw32/bin:$PATH make $1
	else
	  PATH=/mingw32/bin:$PATH make $1
	fi

    echo -e "\n${YELLOW} Going up one directory.${RESET}\n"
		cd ../
fi

# Add-ons Menu
if [ "$I_Want_Master" = true ] || [ "$I_Want_Nightly" = true ]; then
while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Add-ons Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a letter to select:

C)ontinue
U)ninstall Patches
M)odels
V)arious
E)nhancements
S)ound Packs
T)exture Packs
F)ixes
I)nstall Custom

${GREEN}Press C without making a selection to
continue with no patches.${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "e")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Enhancements Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

1$e_selection1) 60 FPS Patch (Destroys ${YELLOW}Arredondo ${CYAN}HD Mario Head, WIP)
2$e_selection2) 60 FPS Patch Uncapped Framerate (Destroys ${YELLOW}Arredondo ${CYAN}HD Mario Head, WIP)
3$e_selection3) Don't Exit From Star Patch by ${YELLOW}Keanine
${CYAN}4$e_selection4) Stay in Level After Star by ${YELLOW}GateGuy ${CYAN}| ${RED}Cheat (conflicts with other patched
   cheats)
${CYAN}5$e_selection5) Download Reshade - Post processing effects (Glitchy as fuck for some people,
   only use if you're experienced)
C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/60fps_interpolation_wip.patch" ]]; then
			git apply ./enhancements/60fps_interpolation_wip.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Selected${RESET}\n"
			e_selection1="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/707763437975109788/715783586460205086/60fps_interpolation_wip.patch
		  	cd ../
	      	git apply ./enhancements/60fps_interpolation_wip.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}60 FPS Patch (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Selected${RESET}\n"
		e_selection1="+"
          fi
          sleep 2
            ;;
    "2")  if [[ -f "./enhancements/60fps_interpolation_wip_nocap.patch" ]]; then
			git apply ./enhancements/60fps_interpolation_wip_nocap.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch Uncapped Framerate (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Selected${RESET}\n"
			e_selection2="+"
		  else
		  	cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/707763437975109788/716761081355173969/60fps_interpolation_wip_nocap.patch
		  	cd ../
		  	git apply ./enhancements/60fps_interpolation_wip_nocap.patch --ignore-whitespace --reject
		  	echo -e "$\n${GREEN}60 FPS Patch Uncapped Framerate (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Selected${RESET}\n"
			e_selection2="+"
		  fi
		  sleep 2
            ;;
    "3")  if [[ -f "./enhancements/DontExitFromStar.patch" ]]; then
			git apply ./enhancements/DontExitFromStar.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Don't Exit From Star Patch by ${YELLOW}Keanine ${GREEN}Selected${RESET}\n"
			e_selection3="+"
		  else
		  	cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/718584345912148100/720292073798107156/DontExitFromStar.patch
		  	cd ../
		  	git apply ./enhancements/DontExitFromStar.patch --ignore-whitespace --reject
		  	echo -e "$\n${GREEN}Don't Exit From Star Patch by ${YELLOW}Keanine ${GREEN}Selected${RESET}\n"
			e_selection3="+"
		  fi
		  sleep 2
            ;;
    "4")  if [[ -f "./enhancements/stay_after_star_nonstop_mode_cheat.patch" ]]; then
			git apply ./enhancements/stay_after_star_nonstop_mode_cheat.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Stay in Level After Star by ${YELLOW}GateGuy ${GREEN}Selected${RESET}\n"
			e_selection4="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/722831880701083648/stay_after_star_nonstop_mode_cheat.patch
		  	cd ../
	      	git apply ./enhancements/stay_after_star_nonstop_mode_cheat.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}Stay in Level After Star by ${YELLOW}GateGuy ${GREEN}Selected${RESET}\n"
		e_selection4="+"
          fi
          sleep 2
            ;;
    "5")  wget https://reshade.me/downloads/ReShade_Setup_4.6.1.exe
		  echo -e "$\n${GREEN}Reshade Downloaded${RESET}\n"
		  e_selection5="+"
		  sleep 2
      		;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
    "m")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Models Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

1$m_selection1) HD Mario by ${YELLOW}Arredondo | ${RED}Nightly Only, Needs External Resources${CYAN}
2$m_selection2) HD Mario (Old School Style) by ${YELLOW}Xinus${CYAN}, ported by ${YELLOW}TzKet-Death
${CYAN}3$m_selection3) HD Bowser by ${YELLOW}Arredondo
${CYAN}4$m_selection4) 3D Coin Patch v2 by ${YELLOW}grego2d ${CYAN}and ${YELLOW}TzKet-Death
${CYAN}5$m_selection5) N64 Luigi (Replaces Mario) by ${YELLOW}Cjes${CYAN}, ${YELLOW}rise${CYAN}, and ${YELLOW}Weegeepie ${CYAN}| ${RED}Nightly Only,
   Needs External Resources${CYAN}
C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  wget https://cdn.discordapp.com/attachments/710283360794181633/717479061664038992/HD_Mario_Model.rar
		  unrar x -o+ HD_Mario_Model.rar
		  rm HD_Mario_model.rar
		  echo -e "$\n${GREEN}HD Mario by ${YELLOW}Arredondo ${GREEN}Selected${RESET}\n"
		  m_selection1="+"
		  sleep 2
            ;;
    "2")  wget https://cdn.discordapp.com/attachments/710283360794181633/719737291613929513/Old_School_HD_Mario_Model.zip
		  unzip -o Old_School_HD_Mario_Model.zip
		  rm Old_School_HD_Mario_Model.zip
		  echo -e "$\n${GREEN}HD Mario (Old School Style) by ${YELLOW}Xinus${GREEN}, ported by ${YELLOW}TzKet-Death ${GREEN}Selected${RESET}\n"
		  m_selection2="+"
		  sleep 2
            ;;
    "3")  wget https://cdn.discordapp.com/attachments/716459185230970880/718990046442684456/hd_bowser.rar
		  unrar x -o+ hd_bowser.rar
		  rm hd_bowser.rar
		  echo -e "$\n${GREEN}HD Bowser by ${YELLOW}Arredondo ${GREEN}Selected${RESET}\n"
		  m_selection3="+"
		  sleep 2
            ;;
    "4")  if [[ -f "./enhancements/3d_coin_v2.patch" ]]; then
			git apply ./enhancements/3d_coin_v2.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}3D Coin Patch v2 by ${YELLOW}grego2d ${GREEN}and ${YELLOW}TzKet-Death ${GREEN}Selected${RESET}\n"
			m_selection4="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/718674249631662120/3d_coin_v2.patch
		  	cd ../
	      	git apply ./enhancements/3d_coin_v2.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}3D Coin Patch v2 by ${YELLOW}grego2d ${GREEN}and ${YELLOW}TzKet-Death ${GREEN}Selected${RESET}\n"
		m_selection4="+"
          fi
          sleep 2
            ;;
    "5")  wget https://cdn.discordapp.com/attachments/720090270863196210/720903424744357968/LuigiMod.zip
		  unzip -o LuigiMod.zip
		  rm LuigiMod.zip
		  echo -e "$\n${GREEN}L IS REAL 2401${RESET}\n"
		  m_selection5="+"
		  sleep 2
            ;;
    #"6")  wget https://cdn.discordapp.com/attachments/716459185230970880/718994292311326730/Hi_Poly_MIPS.rar
		  #unrar x -o+ Hi_Poly_MIPS.rar
		  #rm Hi_Poly_MIPS.rar
		  #echo -e "$\n${GREEN}Hi-Poly MIPS Selected${RESET}\n"
		  #m_selection6="+"
		  #sleep 2
            #;;
    #"7")  wget https://cdn.discordapp.com/attachments/716459185230970880/718999316194263060/Mario_Party_Whomp.rar
		  #unrar x -o+ Mario_Party_Whomp.rar
		  #rm Mario_Party_Whomp.rar
		  #echo -e "$\n${GREEN}Mario Party Whomp Selected${RESET}\n"
		  #m_selection7="+"
		  #sleep 2
            #;;
    #"8")  wget https://cdn.discordapp.com/attachments/716459185230970880/719001278184685598/Mario_Party_Piranha_Plant.rar
		  #unrar x -o+ Mario_Party_Piranha_Plant.rar
		  #rm Mario_Party_Piranha_Plant.rar
		  #echo -e "$\n${GREEN}Mario Party Piranha Plant Selected${RESET}\n"
		  #m_selection8="+"
		  #sleep 2
            #;;
    #"9")  wget https://cdn.discordapp.com/attachments/716459185230970880/719004227464331394/Hi_Poly_Penguin_1.4.rar
		  #unrar x -o+ Hi_Poly_Penguin_1.4.rar
		  #rm Hi_Poly_Penguin_1.4.rar
		  #echo -e "$\n${GREEN}Hi-Poly Penguin 1.4 Selected${RESET}\n"
		  #m_selection9="+"
		  #sleep 2
            #;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
    "s")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Sound Packs Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

1$s_selection1) Super Mario Sunshine Mario Voice by ${YELLOW}!!!! Kris The Goat ${CYAN}| ${RED}Nightly Only, Needs
   External Resources${CYAN}
C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  #wget https://cdn.discordapp.com/attachments/710283360794181633/718232544457523247/Sunshine_Mario_VO.rar
		  #unrar x -o+ Sunshine_Mario_VO.rar
		  #rm Sunshine_Mario_VO.rar
		  wget https://cdn.discordapp.com/attachments/718584345912148100/719492399411232859/sunshinesounds.zip
		  echo -e "$\n${GREEN}Super Mario Sunshine Mario Voice by ${YELLOW}!!!! Kris The Goat ${GREEN}Selected${RESET}\n"
		  s_selection1="+"
		  sleep 2
            ;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
    "t")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Texture Packs Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

1$t_selection1) ${YELLOW}Hypatia${CYAN}´s Mario Craft 64 | ${RED}Nightly Only, Needs External Resources${RESET}
${CYAN}2$t_selection2) ${YELLOW}Mollymutt${CYAN}'s Texture Pack | ${RED}Nightly Only, Needs External Resources
${CYAN}C)ontinue${RESET}

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  wget https://cdn.discordapp.com/attachments/718584345912148100/718901885657940091/Hypatia_Mario_Craft_Complete.part1.rar
          wget https://cdn.discordapp.com/attachments/718584345912148100/718902211165290536/Hypatia_Mario_Craft_Complete.part2.rar
          wget https://cdn.discordapp.com/attachments/718584345912148100/718902377553592370/Hypatia_Mario_Craft_Complete.part3.rar
          if [ ! -f Hypatia_Mario_Craft_Complete.part3.rar ]; then
          	echo -e "${RED}Your download fucked up"
          else
          	echo -e "$\n${YELLOW}Hypatia${GREEN}´s Mario Craft 64 Selected${RESET}\n"
		t_selection1="+"
          fi
          sleep 2
            ;;
	"2")  wget https://cdn.discordapp.com/attachments/718584345912148100/719639977662611466/mollymutt.zip
          if [ ! -f mollymutt.zip ]; then
          	echo -e "${RED}Your download fucked up"
          else
          	echo -e "$\n${YELLOW}Mollymutt${GREEN}'s Texture Pack Selected${RESET}\n"
		t_selection2="+"
          fi
          sleep 2
            ;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
    "v")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Various Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

1$v_selection1) 120 Star Save | ${RED}Nightly Only${RESET}
${CYAN}2$v_selection2) Enable Debug Level Selector (WIP) by ${YELLOW}Funny unu boi
${CYAN}3$v_selection3) BLJ Anywhere by ${YELLOW}GateGuy ${CYAN}| ${RED}Cheat (conflicts with other patched cheats)
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  wget https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
		  if [ -f $APPDATA/sm64pc/sm64_save_file.bin ]; then
		  	mv -f $APPDATA/sm64pc/sm64_save_file.bin $APPDATA/sm64pc/sm64_save_file.old.bin
		  	mv sm64_save_file.bin $APPDATA/sm64pc/sm64_save_file.bin
		  else
		  	mv sm64_save_file.bin $APPDATA/sm64pc/sm64_save_file.bin
		  fi
		  echo -e "$\n${GREEN}120 Star Save Selected${RESET}\n"
		  v_selection1="+"
		  sleep 2
            ;;
    "2")  if [[ -f "./enhancements/0001-WIP-Enable-debug-level-selector.patch" ]]; then
			git apply ./enhancements/0001-WIP-Enable-debug-level-selector.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Enable Debug Level Selector (WIP) by ${YELLOW}Funny unu boi ${GREEN}Selected${RESET}\n"
			v_selection2="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/722566901749907496/0001-WIP-Enable-debug-level-selector.patch
		  	cd ../
	      	git apply ./enhancements/0001-WIP-Enable-debug-level-selector.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}Enable Debug Level Selector (WIP) by ${YELLOW}Funny unu boi ${GREEN}Selected${RESET}\n"
		v_selection2="+"
          fi
          sleep 2
            ;;
    "3")  if [[ -f "./enhancements/blj_anywhere_cheat.patch" ]]; then
			git apply ./enhancements/blj_anywhere_cheat.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}BLJ Anywhere by ${YELLOW}GateGuy ${GREEN}Selected${RESET}\n"
			v_selection3="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/722949729394098236/blj_anywhere_cheat.patch
		  	cd ../
	      	git apply ./enhancements/blj_anywhere_cheat.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}BLJ Anywhere by ${YELLOW}GateGuy ${GREEN}Selected${RESET}\n"
		v_selection3="+"
          fi
          sleep 2
            ;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
        "f")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Fixes Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

1$f_selection1) Mouse Support and Fixes for Reshade (WIP) by ${YELLOW}Funny unu boi
${CYAN}2$f_selection2) Increase Delay on Star Select by ${YELLOW}GateGuy ${CYAN}| ${RED}Breaks TAS Support
${CYAN}3$f_selection3) Go Back to Title Screen from Ending by ${YELLOW}GateGuy
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch" ]]; then
			git apply ./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Mouse Support and Fixes for Reshade (WIP) by ${YELLOW}Funny unu boi ${GREEN}Selected${RESET}\n"
			f_selection1="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/722662190267760660/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch
		  	cd ../
	      	git apply ./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}Mouse Support and Fixes for Reshade (WIP) by ${YELLOW}Funny unu boi ${GREEN}Selected${RESET}\n"
		f_selection1="+"
          fi
          sleep 2
            ;;
    "2")  if [[ -f "./enhancements/increase_delay_on_star_select.patch" ]]; then
			git apply ./enhancements/increase_delay_on_star_select.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Increase Delay on Star Select by ${YELLOW}GateGuy ${GREEN}Selected${RESET}\n"
			f_selection2="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/722874655723225109/increase_delay_on_star_select.patch
		  	cd ../
	      	git apply ./enhancements/increase_delay_on_star_select.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}Increase Delay on Star Select by ${YELLOW}GateGuy ${GREEN}Selected${RESET}\n"
		f_selection2="+"
          fi
          sleep 2
            ;;
    "3")  if [[ -f "./enhancements/go_back_to_title_from_ending.patch" ]]; then
			git apply ./enhancements/go_back_to_title_from_ending.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Go Back to Title Screen from Ending by ${YELLOW}GateGuy ${GREEN}Selected${RESET}\n"
			f_selection3="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/722875150923726928/go_back_to_title_from_ending.patch
		  	cd ../
	      	git apply ./enhancements/go_back_to_title_from_ending.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}Go Back to Title Screen from Ending by ${YELLOW}GateGuy ${GREEN}Selected${RESET}\n"
		f_selection3="+"
          fi
          sleep 2
            ;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
        "i")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Custom Install Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

1) Install Patches                    
2) Install Texture Packs | ${RED}Nightly Only, Needs External Resources
${CYAN}C)ontinue${RESET}

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  echo -e "\n${YELLOW}Select a patch to install${RESET}\n"
    	  PATCH_FILE=$(zenity --file-selection --title="Select the patch file")
    	  git apply $PATCH_FILE --ignore-whitespace --reject
    	  echo -e "\n${GREEN}$PATCH_FILE selected${RESET}\n"
          sleep 2
            ;;
    "2")  echo -e "\n${YELLOW}Select a texture pack to install${RESET}\n"
    	  TEXTURE_PACK=$(zenity --file-selection --title="Select the texure pack zip file")
  		  mkdir -p build/us_pc/res
  		  cp $TEXTURE_PACK ./build/us_pc/res
  		  echo -e "\n${GREEN}$TEXTURE_PACK selected${RESET}\n"
		  sleep 2
            ;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
    "u")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Uninstall Patch Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a letter to select:

C)ontinue
M)odels
V)arious
E)nhancements
F)ixes

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

	read -n1 -s
    case "$REPLY" in
    "m")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Uninstall Models Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

1$m_u_selection1) Uninstall 3D Coin Patch v2 by ${YELLOW}grego2d ${CYAN}and ${YELLOW}TzKet-Death
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/3d_coin_v2.patch" ]]; then
			git apply -R ./enhancements/3d_coin_v2.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}3D Coin Patch v2 by ${YELLOW}grego2d ${GREEN}and ${YELLOW}TzKet-Death ${GREEN}Removed${RESET}\n"
			m_u_selection1="+"
		  fi
		  sleep 2
		    ;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
    "v")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Uninstall Various Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

${CYAN}1$v_u_selection1) Uninstall Enable Debug Level Selector (WIP) by ${YELLOW}Funny unu boi
${CYAN}2$v_u_selection2) Uninstall BLJ Anywhere by ${YELLOW}GateGuy ${CYAN}| ${RED}Cheat (conflicts with other patched
   cheats)
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/0001-WIP-Enable-debug-level-selector.patch" ]]; then
			git apply -R ./enhancements/0001-WIP-Enable-debug-level-selector.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Enable Debug Level Selector (WIP) by ${YELLOW}Funny unu boi ${GREEN}Removed${RESET}\n"
			v_u_selection1="+"
		  fi
		  sleep 2
		    ;;
    "2")  if [[ -f "./enhancements/blj_anywhere_cheat.patch" ]]; then
			git apply -R ./enhancements/blj_anywhere_cheat.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}BLJ Anywhere by ${YELLOW}GateGuy ${GREEN}Removed${RESET}\n"
			v_u_selection2="+"
		  fi
		  sleep 2
		    ;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
    "e")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Uninstall Enhancements Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

1$e_u_selection1) Uninstall 60 FPS Patch (Destroys ${YELLOW}Arredondo ${CYAN}HD Mario Head, WIP)
2$e_u_selection2) Uninstall 60 FPS Patch Uncapped Framerate (Destroys ${YELLOW}Arredondo ${CYAN}HD Mario Head,
   WIP)
3$e_u_selection3) Uninstall Don't Exit From Star Patch by ${YELLOW}Keanine
${CYAN}4$e_u_selection4) Uninstall Stay in Level After Star by ${YELLOW}GateGuy ${CYAN}| ${RED}Cheat (conflicts with other
   patched cheats)
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/60fps_interpolation_wip.patch" ]]; then
			git apply -R ./enhancements/60fps_interpolation_wip.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Removed${RESET}\n"
			e_u_selection1="+"
          fi
          sleep 2
            ;;
    "2")  if [[ -f "./enhancements/60fps_interpolation_wip_nocap.patch" ]]; then
			git apply -R ./enhancements/60fps_interpolation_wip_nocap.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch Uncapped Framerate (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Removed${RESET}\n"
			e_u_selection2="+"
		  fi
		  sleep 2
            ;;
    "3")  if [[ -f "./enhancements/DontExitFromStar.patch" ]]; then
			git apply -R ./enhancements/DontExitFromStar.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Don't Exit From Star Patch by ${YELLOW}Keanine ${GREEN}Removed${RESET}\n"
			e_u_selection3="+"
		  fi
		  sleep 2
		    ;;
    "4")  if [[ -f "./enhancements/stay_after_star_nonstop_mode_cheat.patch" ]]; then
			git apply -R ./enhancements/stay_after_star_nonstop_mode_cheat.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Stay in Level After Star by ${YELLOW}GateGuy ${GREEN}Removed${RESET}\n"
			e_u_selection4="+"
		  fi
		  sleep 2
		    ;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
    "f")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Uninstall Fixes Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

${CYAN}1$f_u_selection1) Uninstall Mouse Support and Fixes for Reshade (WIP) by ${YELLOW}Funny unu boi
${CYAN}2$f_u_selection2) Uninstall Increase Delay on Star Select by ${YELLOW}GateGuy ${CYAN}| ${RED}Breaks TAS Support
${CYAN}3$f_u_selection3) Uninstall Go Back to Title Screen from Ending by ${YELLOW}GateGuy
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch" ]]; then
			git apply -R ./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Mouse Support and Fixes for Reshade (WIP) by ${YELLOW}Funny unu boi ${GREEN}Removed${RESET}\n"
			f_u_selection1="+"
		  fi
		  sleep 2
		    ;;
    "2")  if [[ -f "./enhancements/increase_delay_on_star_select.patch" ]]; then
			git apply -R ./enhancements/increase_delay_on_star_select.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Increase Delay on Star Select by ${YELLOW}GateGuy ${GREEN}Removed${RESET}\n"
			f_u_selection2="+"
		  fi
		  sleep 2
		    ;;
    "3")  if [[ -f "./enhancements/go_back_to_title_from_ending.patch" ]]; then
			git apply -R ./enhancements/go_back_to_title_from_ending.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Go Back to Title Screen from Ending by ${YELLOW}GateGuy ${GREEN}Removed${RESET}\n"
			f_u_selection3="+"
		  fi
		  sleep 2
		    ;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
			;;
    "c")  break
            ;;
    "C")  echo "use lower case c!!"
          sleep 2
            ;;
     * )  echo "invalid option"
          sleep 2
            ;;
    esac
done
fi

# Official flags menu
if [ "$I_Want_Official" = true ]; then
	menu() {
			printf "\nAvailable options:\n"
			for i in ${!OFFICIAL_OPTIONS[@]}; do 
					printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${OFFICIAL_OPTIONS[i]}"
			done
			if [[ "$msg" ]]; then echo "$msg"; fi
			printf "${YELLOW}Please do not select \"Clean build\" with any other option.\n"
			printf "${RED}WARNING: Backup your save file before selecting \"Clean build\".\n"
			printf "${CYAN}Press the corresponding number and press enter to select it.\nWhen all desired options are selected, press Enter to continue.\n"
			printf "${RED}RUN \"Clean build\" REGULARLY.\n"
			printf "Every time you want to update to a newer version or build with different options\nyou have to choose the option \"Clean build\" or manually remove or rename\nsm64-port/build\n"
	}

	prompt="Check an option (again to uncheck, press ENTER):"$'\n'
	while menu && read -rp "$prompt" num && [[ "$num" ]]; do
			[[ "$num" != *[![:digit:]]* ]] &&
			(( num > 0 && num <= ${#OFFICIAL_OPTIONS[@]} )) ||
			{ msg="Invalid option: $num"; continue; }
			((num--)); # msg="${OFFICIAL_OPTIONS[num]} was ${choices[num]:+un}checked"
			[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
	done

	for i in ${!OFFICIAL_OPTIONS[@]}; do 
			[[ "${choices[i]}" ]] && { CMDL+=" ${OFFICIAL_EXTRA[i]}"; }
	done
fi

# Master flags menu
if [ "$I_Want_Master" = true ]; then
	menu() {
			printf "\nAvailable options:\n"
			for i in ${!MASTER_OPTIONS[@]}; do 
					printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${MASTER_OPTIONS[i]}"
			done
			if [[ "$msg" ]]; then echo "$msg"; fi
			printf "${YELLOW}Please do not select \"Clean build\" with any other option.\n"
			printf "${RED}WARNING: Backup your save file before selecting \"Clean build\".\n"
			printf "${CYAN}Press the corresponding number and press enter to select it.\nWhen all desired options are selected, press Enter to continue.\n"
			printf "${RED}RUN \"Clean build\" REGULARLY.\n"
			printf "Every time you want to update to a newer version or build with different options\nyou have to choose the option \"Clean build\" or manually remove or rename\nsm64pc-master/build\n"
			printf "${YELLOW}Check Remove Extended Options Menu & leave other options unchecked for a Vanilla\nbuild.\n${RESET}"
	}

	prompt="Check an option (again to uncheck, press ENTER):"$'\n'
	while menu && read -rp "$prompt" num && [[ "$num" ]]; do
			[[ "$num" != *[![:digit:]]* ]] &&
			(( num > 0 && num <= ${#MASTER_OPTIONS[@]} )) ||
			{ msg="Invalid option: $num"; continue; }
			((num--)); # msg="${MASTER_OPTIONS[num]} was ${choices[num]:+un}checked"
			[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
	done

	for i in ${!MASTER_OPTIONS[@]}; do 
			[[ "${choices[i]}" ]] && { CMDL+=" ${MASTER_EXTRA[i]}"; }
	done
fi

# Nightly flags menu
if [ "$I_Want_Nightly" = true ]; then
	menu() {
			printf "\nAvailable options:\n"
			for i in ${!NIGHTLY_OPTIONS[@]}; do 
					printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${NIGHTLY_OPTIONS[i]}"
			done
			if [[ "$msg" ]]; then echo "$msg"; fi
			printf "${YELLOW}Please do not select \"Clean build\" with any other option.\n"
			printf "${RED}WARNING: Backup your save file before selecting \"Clean build\".\n"
			printf "${CYAN}Press the corresponding number and press enter to select it.\nWhen all desired options are selected, press Enter to continue.\n"
			printf "${RED}RUN \"Clean build\" REGULARLY.\n"
			printf "Every time you want to update to a newer version or build with different options\nyou have to choose the option \"Clean build\" or manually remove or rename\nsm64pc-nightly/build\n"
			printf "${YELLOW}Check Remove Extended Options Menu & leave other options unchecked for a Vanilla\nbuild.\n${RESET}"
	}

	prompt="Check an option (again to uncheck, press ENTER):"$'\n'
	while menu && read -rp "$prompt" num && [[ "$num" ]]; do
			[[ "$num" != *[![:digit:]]* ]] &&
			(( num > 0 && num <= ${#NIGHTLY_OPTIONS[@]} )) ||
			{ msg="Invalid option: $num"; continue; }
			((num--)); # msg="${NIGHTLY_OPTIONS[num]} was ${choices[num]:+un}checked"
			[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
	done

	for i in ${!NIGHTLY_OPTIONS[@]}; do 
			[[ "${choices[i]}" ]] && { CMDL+=" ${NIGHTLY_EXTRA[i]}"; }
	done
fi

# Checks the computer architecture
if [ "${CMDL}" != " clean" ]; then
	echo -e "\n${YELLOW} Executing: ${CYAN}make${CMDL} $1${RESET}\n\n"

	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL $1
	else
	  PATH=/mingw32/bin:$PATH make $CMDL $1
	fi

	if ls $BINARY 1> /dev/null 2>&1; then
		if [ -f ReShade_Setup_4.6.1.exe ]; then
			mv ./ReShade_Setup_4.6.1.exe ./build/us_pc/ReShade_Setup_4.6.1.exe
		fi
		
		# Move sound packs
		if [ -d ./build/us_pc/res ]; then
			if [ -f sunshinesounds.zip ]; then
				mv sunshinesounds.zip ./build/us_pc/res
				rm sunshinesounds* # in case they exist from running the script before or selecting multiple times.
			fi
		fi
				
		# Move texture packs
		if [ -d ./build/us_pc/res ]; then
			if [ -f Hypatia_Mario_Craft_Complete.part3.rar ]; then
				mkdir ./build/hmcc/
				unrar x -o+ Hypatia_Mario_Craft_Complete.part1.rar ./build/hmcc/
				mv ./build/hmcc/res ./build/hmcc/gfx
				cd ./build/hmcc/
				zip -r hypatiamariocraft gfx
				mv hypatiamariocraft.zip ../../build/us_pc/res
				cd ../../
            	rm Hypatia_Mario_Craft_Complete.part*
				rm -rf ./build/hmcc/
			fi
			if [ -f mollymutt.zip ]; then
				mv mollymutt.zip ./build/us_pc/res
			fi
		fi
		
    	zenity --info \
		--text="The sm64pc binary is now available in the 'build/us_pc/' folder."
		echo -e "\n${YELLOW}If fullscreen doesn't seem like the correct resolution, then right click on the\nexe, go to properties, compatibility, then click Change high DPI settings.\nCheck the 'Override high DPI scaling behavior' checkmark, leave it on\napplication, then press apply."
		cd ./build/us_pc/
		start .
	else
		zenity --warning \
		--text="Oh no! Something went wrong."
	fi

else

	echo -e "\n${YELLOW} Executing: ${CYAN}make${CMDL} $1${RESET}\n\n"

	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL $1
	else
	  PATH=/mingw32/bin:$PATH make $CMDL $1
	fi

	echo -e "${GREEN}\nYour build is now clean.\n"
fi
