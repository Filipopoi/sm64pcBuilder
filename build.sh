#!/bin/bash

# Directories and Files
LIBDIR=./tools/lib/
LIBAFA=libaudiofile.a
LIBAFLA=libaudiofile.la
AUDDIR=./tools/audiofile-0.3.6
OFFICIAL=./sm64-port/
OFFICIAL_GIT=./sm64-port/.git/
OFFICIAL_OLD_US=./sm64-port.old/baserom.us.z64
OFFICIAL_OLD_JP=./sm64-port.old/baserom.jp.z64
OFFICIAL_OLD_EU=./sm64-port.old/baserom.eu.z64
MASTER=./sm64ex-master/
MASTER_GIT=./sm64ex-master/.git/
MASTER_OLD_US=./sm64ex-master.old/baserom.us.z64
MASTER_OLD_JP=./sm64ex-master.old/baserom.jp.z64
MASTER_OLD_EU=./sm64ex-master.old/baserom.eu.z64
NIGHTLY=./sm64ex-nightly/
NIGHTLY_GIT=./sm64ex-nightly/.git/
NIGHTLY_OLD_US=./sm64ex-nightly.old/baserom.us.z64
NIGHTLY_OLD_JP=./sm64ex-nightly.old/baserom.jp.z64
NIGHTLY_OLD_EU=./sm64ex-nightly.old/baserom.eu.z64
ROM_CHECK_US=./baserom.us.z64
ROM_CHECK_JP=./baserom.jp.z64
ROM_CHECK_EU=./baserom.eu.z64
BINARY_US=./build/us_pc/sm64*
BINARY_JP=./build/jp_pc/sm64*
BINARY_EU=./build/eu_pc/sm64*
FOLDER_PLACEMENT=C:/sm64pcBuilder
MACHINE_TYPE=`uname -m`

# Command line options
OFFICIAL_OPTIONS=("Build an N64 ROM" "Clean build | This deletes the build folder")
OFFICIAL_EXTRA=("TARGET_N64=1" "clean")
SM64EX_OPTIONS=("Analog Camera" "No Draw Distance" "Texture Fixes" "Allow External Resources" "Discord Rich Presence" "Remove Extended Options Menu | Remove additional R button menu options" "DirectX 11 Renderer" "DirectX 12 Renderer" "OpenGL 1.3 Renderer | Unrecommended. Only use if your machine is very old" "Clean build | This deletes the build folder")
SM64EX_EXTRA=("BETTERCAMERA=1" "NODRAWINGDISTANCE=1" "TEXTURE_FIX=1" "EXTERNAL_DATA=1" "DISCORDRPC=1" "EXT_OPTIONS_MENU=0" "RENDER_API=D3D11" "RENDER_API=D3D12" "LEGACY_GL=1" "clean")

# Dependency checks
DEPENDENCIES=("git" "make" "python3" "zip" "unzip" "curl" "unrar" "mingw-w64-i686-gcc" "mingw-w64-x86_64-gcc" "mingw-w64-i686-glew" "mingw-w64-x86_64-glew" "mingw-w64-i686-SDL2" "mingw-w64-x86_64-SDL2" "mingw-w64-i686-python-xdg" "mingw-w64-x86_64-python-xdg")

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

# Checks for dependencies and installs everything if they are missing
echo -e "\n${YELLOW}Checking dependencies... ${RESET}\n"
for i in ${DEPENDENCIES[@]}; do
	if [[ ! $(pacman -Q $i 2> /dev/null) ]]; then
		echo -e "\n${RED}Dependencies are missing. Proceeding with the installation... ${RESET}\n" >&2
		pacman -Sy --needed base-devel mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain \
	                    git subversion mercurial \
	                    mingw-w64-i686-cmake mingw-w64-x86_64-cmake --noconfirm
		pacman -S $i --noconfirm
		pacman -Syuu --noconfirm
	fi
done

if [ ! -f $MINGW_HOME/bin/zenity.exe ]; then
	wget -O $MINGW_HOME/bin/zenity.exe https://cdn.discordapp.com/attachments/718584345912148100/721406762884005968/zenity.exe
fi

echo -e "\n${GREEN}Dependencies are already installed. ${RESET}\n"

# Delete their setup or old shit
if [ -f $HOME/build-setup.sh ]; then
	rm $HOME/build-setup.sh
fi

if [ -f $HOME/build.sh ]; then
	rm $HOME/build.sh
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

[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}build.sh is up to date\n${RESET}" || pull_sm64pcbuilder "$@"

# Update message
if [ "$3" = showchangelog ]; then
	zenity --info  --text "
SM64PC Builder
by serosis, gunvalk, derailius, Filipianosol,
coltonrawr, fgsfds, BrineDude, Recompiler, and others
-----------------------------------------------------
Updates:

- Official Port Support
- Renamed fgsfdsfgs Repo to sm64ex (look for your
  exe in this folder from now on)
- Full JP and EU Support
- Custom Uninstall Menu
- OwO Team's OwOify Textuwe Pack (Wepwaces Mawio)
- Re-enabled EU Discord RPC
- Nightly 60 FPS Patch
- Updated Keanine's Don't Exit From Star Patch
  (Now Includes a Dialog Giving You the Option to
   Stay or Go; Renamed to Stay in Course)
- Exit Course 50 Coin Fix by Keanine

-----------------------------------------------------
build.sh Update 22.3"
fi

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
	echo -e "\n${YELLOW}Downloading available sm64ex-master updates...${RESET}\n"
	git stash push
	git stash drop
	git pull
	sleep 2
}

# Update nightly check
pull_nightly () {
	echo -e "\n${YELLOW}Downloading available sm64ex-nightly updates...${RESET}\n"
	git stash push
	git stash drop
	git pull
	sleep 2
}

if [ "$1" = noupdate ] || [ "$2" = noupdate ]; then
	zenity --question  --text "Which version are you compiling?
The official port's code is cleaner, but
it lacks the new features of the sm64ex
fgsfdsfgs fork at the moment.
Automatic updates are disabled." \
	--ok-label="Official" \
	--cancel-label="sm64ex"
	if [[ $? = 0 ]]; then
		I_Want_Official=true
	else
		zenity --question  --text "Which version are you compiling?
The master version is currently recommended.
Note: 60 FPS Patch is now compatible with
nightly. Other patches are on the way.
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
The official port's code is cleaner, but
it lacks the new features of the sm64ex
fgsfdsfgs fork at the moment.
Automatic updates are enabled." \
	--ok-label="Official" \
	--cancel-label="sm64ex"
	if [[ $? = 0 ]]; then
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
		zenity --question  --text "Which version are you compiling?
The master version is currently recommended.
Note: 60 FPS Patch is now compatible with
nightly. Other patches are on the way.
Automatic updates are enabled." \
		--ok-label="Master" \
		--cancel-label="Nightly"
		if [[ $? = 0 ]]; then
			if [ -d "$MASTER_GIT" ]; then
				cd ./sm64ex-master
				echo -e "\n"
				[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
				sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}sm64ex-master is up to date\n${RESET}" || pull_master "$@"
				if [ -f ./build.sh ]; then
					rm ./build.sh
				fi
				I_Want_Master=true
				cd ../
			else
				if [ -d "$MASTER" ]; then
					mv sm64ex-master sm64ex-master.old
				fi
				echo -e "\n"
				git clone git://github.com/sm64pc/sm64ex sm64ex-master
				I_Want_Master=true
			fi
		elif [ -d "$NIGHTLY_GIT" ]; then
			cd ./sm64ex-nightly
			echo -e "\n"
			[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
			sed 's/\// /g') | cut -f1) ] && echo -e "\n${GREEN}sm64ex-nightly is up to date\n${RESET}" || pull_nightly "$@"
			if [ -f ./build.sh ]; then
				rm ./build.sh
			fi
			I_Want_Nightly=true
			cd ../
			elif [ -d "$NIGHTLY" ]; then
				echo -e "\n"
				mv sm64ex-nightly sm64ex-nightly.old
				git clone -b nightly git://github.com/sm64pc/sm64ex sm64ex-nightly
				if [ -f ./sm64ex-nightly/build.sh ]; then
					rm ./sm64ex-nightly/build.sh
				fi
				I_Want_Nightly=true
			else
				echo -e "\n"
				git clone -b nightly git://github.com/sm64pc/sm64ex sm64ex-nightly
				if [ -f ./sm64ex-nightly/build.sh ]; then
					rm ./sm64ex-nightly/build.sh
				fi
				I_Want_Nightly=true
		fi
	fi
fi

# Checks for which version the user selected
if [ "$I_Want_Official" = true ]; then
	cd ./sm64-port
elif [ "$I_Want_Master" = true ]; then
	cd ./sm64ex-master
elif [ "$I_Want_Nightly" = true ]; then
	cd ./sm64ex-nightly
fi

# Region selection
zenity --question  --text "Which region do you want to compile in?
The American version is the most stable
currently, but doesn't support Japanese,
French, or German." \
--ok-label="United States" \
--cancel-label="Japan/Europe"
# Checks if baserom exists and lets the user select it if it's missing
if [[ $? = 0 ]]; then
	if [ -f "$ROM_CHECK_US" ]; then
		echo -e "\n\n${GREEN}Existing baserom.us.z64 found${RESET}\n"
	else
		echo -e "\n${YELLOW}Select your baserom.us.z64 file${RESET}\n"
		while true; do
		BASEROM_FILE=$(zenity --file-selection --title="Select the baserom.us.z64 file")
		if [[ "$BASEROM_FILE" = *baserom.us.z64 ]]; then
			cp "$BASEROM_FILE" "$ROM_CHECK_US"
		else
			zenity --warning \
			--text="This is not a valid baserom file/not the right region. Make sure it's named baserom.us.z64. Renaming n64 or v64 to z64 won't work."
			continue
		fi
		break
		done
	fi
	I_Want_US=true
else
	zenity --question  --text "Do you want the Japanese or European
version? The Japanese version is in
Japanese, while the European version
includes English, French, and German." \
	--ok-label="Japan" \
	--cancel-label="Europe"
	if [[ $? = 0 ]]; then
		if [ -f "$ROM_CHECK_JP" ]; then
			echo -e "\n\n${GREEN}Existing baserom.jp.z64 found${RESET}\n"
		else
			echo -e "\n${YELLOW}Select your baserom.jp.z64 file${RESET}\n"
			while true; do
			BASEROM_FILE=$(zenity --file-selection --title="Select the baserom.jp.z64 file")
			if [[ "$BASEROM_FILE" = *baserom.jp.z64 ]]; then
				cp "$BASEROM_FILE" "$ROM_CHECK_JP"
			else
				zenity --warning \
				--text="This is not a valid baserom file/not the right region. Make sure it's named baserom.jp.z64. Renaming n64 or v64 to z64 won't work."
				continue
			fi
			break
			done
		fi
		I_Want_JP=true
	elif [ -f "$ROM_CHECK_EU" ]; then
		echo -e "\n\n${GREEN}Existing baserom.eu.z64 found${RESET}\n"
		I_Want_EU=true
	else
		echo -e "\n${YELLOW}Select your baserom.eu.z64 file${RESET}\n"
		while true; do
		BASEROM_FILE=$(zenity --file-selection --title="Select the baserom.eu.z64 file")
		if [[ "$BASEROM_FILE" = *baserom.eu.z64 ]]; then
			cp "$BASEROM_FILE" "$ROM_CHECK_EU"
		else
			zenity --warning \
			--text="This is not a valid baserom file/not the right region. Make sure it's named baserom.eu.z64. Renaming n64 or v64 to z64 won't work."
			continue
		fi
		break
		done		
		I_Want_EU=true
	fi
fi

# Checks for a pre-existing baserom file in old folder then moves it to the new one
if [ -f "$OFFICIAL_OLD_US" ]; then
	mv sm64-port.old/baserom.us.z64 sm64-port/baserom.us.z64
elif [ -f "$OFFICIAL_OLD_JP" ]; then
	mv sm64-port.old/baserom.jp.z64 sm64-port/baserom.jp.z64
elif [ -f "$OFFICIAL_OLD_EU" ]; then
    mv sm64-port.old/baserom.eu.z64 sm64-port/baserom.eu.z64
fi

if [ -f "$MASTER_OLD_US" ]; then
	mv sm64ex-master.old/baserom.us.z64 sm64ex-master/baserom.us.z64
elif [ -f "$MASTER_OLD_JP" ]; then
	mv sm64ex-master.old/baserom.jp.z64 sm64ex-master/baserom.jp.z64
elif [ -f "$MASTER_OLD_EU" ]; then
	mv sm64ex-master.old/baserom.eu.z64 sm64ex-master/baserom.eu.z64
fi

if [ -f "$NIGHTLY_OLD_US" ]; then
	mv sm64ex-nightly.old/baserom.us.z64 sm64ex-nightly/baserom.us.z64
elif [ -f "$NIGHTLY_OLD_JP" ]; then
	mv sm64ex-nightly.old/baserom.jp.z64 sm64ex-nightly/baserom.jp.z64
elif [ -f "$NIGHTLY_OLD_EU" ]; then
	mv sm64ex-nightly.old/baserom.eu.z64 sm64ex-nightly/baserom.eu.z64
fi

# Swaps noupdate out of the $1 position
if [ "$1" = noupdate ]; then
	set -- "$2"
fi

# Checks to see if the libaudio directory and files exist
if [ -d "${LIBDIR}" -a -e "${LIBDIR}${LIBAFA}" -a -e "${LIBDIR}${LIBAFLA}"  ]; then
    echo -e "\n${GREEN}libaudio files exist, going straight to compiling.${RESET}\n"
fi

# Add-ons Menu
if [ "$I_Want_Master" = true ] || [ "$I_Want_Nightly" = true ]; then
while :
do
    clear
	echo \
"${YELLOW}================================================================================${RESET}
${CYAN}Add-ons Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a letter to select:

C)ontinue
U)ninstall
M)odels
V)arious
E)nhancements
S)ound Packs
T)exture Packs | ${RED}Need External Resources
${CYAN}F)ixes
I)nstall Custom

${GREEN}Press C without making a
selection to continue with no
patches.${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "e")  while :
do
    clear
	echo \
"${YELLOW}================================================================================${RESET}
${CYAN}Enhancements Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

1$e_selection1) 60 FPS Patch (Destroys ${YELLOW}Arredondo ${CYAN}HD Mario Head, WIP) | ${GREEN}Works in Master and
   Nightly
${CYAN}2$e_selection2) Stay in Course by ${YELLOW}Keanine ${CYAN}| ${RED}Currently Broken
${CYAN}3$e_selection3) Stay in Level After Star by ${YELLOW}GateGuy ${CYAN}| ${RED}Cheat (conflicts with other patched
   cheats)
${CYAN}4$e_selection4) Download Reshade - Post processing effects (Glitchy as fuck for some people,
   only use if you're experienced)
C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/60fps_interpolation_wip.patch" ]] && [ "$I_Want_Master" = true ]; then
			git apply ./enhancements/60fps_interpolation_wip.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Selected${RESET}\n"
			e_selection1="+"
		  elif [ "$I_Want_Master" = true ]; then
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/707763437975109788/715783586460205086/60fps_interpolation_wip.patch
		  	cd ../
	      	git apply ./enhancements/60fps_interpolation_wip.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}60 FPS Patch (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Selected${RESET}\n"
		e_selection1="+"
          fi
          if [[ -f "./enhancements/60fps_interpolation_wip_nightly.patch" ]] && [ "$I_Want_Nightly" = true ]; then
			git apply ./enhancements/60fps_interpolation_wip_nightly.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Selected${RESET}\n"
			e_selection1="+"
		  elif [ "$I_Want_Nightly" = true ]; then
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/721806706547490868/723907484653453403/60fps_interpolation_wip_nightly.patch
		  	cd ../
	      	git apply ./enhancements/60fps_interpolation_wip_nightly.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}60 FPS Patch (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Selected${RESET}\n"
		e_selection1="+"
          fi
          sleep 2
            ;;
    "2")  if [[ -f "./enhancements/stay_in_course.patch" ]]; then
			git apply ./enhancements/stay_in_course.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Stay in Course by ${YELLOW}Keanine ${GREEN}Selected${RESET}\n"
			e_selection2="+"
		  else
		  	cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/721806706547490868/723908274461737070/stay_in_course.patch
		  	cd ../
		  	git apply ./enhancements/stay_in_course.patch --ignore-whitespace --reject
		  	echo -e "$\n${GREEN}Stay in Course by ${YELLOW}Keanine ${GREEN}Selected${RESET}\n"
			e_selection2="+"
		  fi
		  sleep 2
            ;;
    "3")  if [[ -f "./enhancements/stay_after_star_nonstop_mode_cheat.patch" ]]; then
			git apply ./enhancements/stay_after_star_nonstop_mode_cheat.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Stay in Level After Star by ${YELLOW}GateGuy ${GREEN}Selected${RESET}\n"
			e_selection3="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/722831880701083648/stay_after_star_nonstop_mode_cheat.patch
		  	cd ../
	      	git apply ./enhancements/stay_after_star_nonstop_mode_cheat.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}Stay in Level After Star by ${YELLOW}GateGuy ${GREEN}Selected${RESET}\n"
		e_selection3="+"
          fi
          sleep 2
            ;;
    "4")  wget https://reshade.me/downloads/ReShade_Setup_4.6.1.exe
		  echo -e "$\n${GREEN}Reshade Downloaded${RESET}\n"
		  e_selection4="+"
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
"${YELLOW}================================================================================${RESET}
${CYAN}Models Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

1$m_selection1) HD Mario by ${YELLOW}Arredondo ${CYAN}| ${RED}Needs External Resources
${CYAN}2$m_selection2) HD Mario (Old School Style) by ${YELLOW}Xinus${CYAN}, ported by ${YELLOW}TzKet-Death
${CYAN}3$m_selection3) HD Bowser by ${YELLOW}Arredondo
${CYAN}4$m_selection4) 3D Coin Patch v2 by ${YELLOW}grego2d ${CYAN}and ${YELLOW}TzKet-Death
${CYAN}5$m_selection5) N64 Luigi (Replaces Mario) by ${YELLOW}Cjes${CYAN}, ${YELLOW}rise${CYAN}, and ${YELLOW}Weegeepie ${CYAN}| ${RED}Needs External
   Resources
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

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
"${YELLOW}================================================================================${RESET}
${CYAN}Sound Packs Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

1$s_selection1) Super Mario Sunshine Mario Voice by ${YELLOW}Kris The Coder Goat ${CYAN}| ${RED}Needs External
   Resources
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  #wget https://cdn.discordapp.com/attachments/710283360794181633/718232544457523247/Sunshine_Mario_VO.rar
		  #unrar x -o+ Sunshine_Mario_VO.rar
		  #rm Sunshine_Mario_VO.rar
		  wget https://cdn.discordapp.com/attachments/718584345912148100/719492399411232859/sunshinesounds.zip
		  echo -e "$\n${GREEN}Super Mario Sunshine Mario Voice by ${YELLOW}Kris The Coder Goat ${GREEN}Selected${RESET}\n"
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
"${YELLOW}================================================================================${RESET}
${CYAN}Texture Packs Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

1$t_selection1) ${YELLOW}Hypatia${CYAN}´s Mario Craft 64 | ${RED}Needs External Resources
${CYAN}2$t_selection2) ${YELLOW}Mollymutt${CYAN}'s Texture Pack | ${RED}Needs External Resources
${CYAN}3$t_selection3) ${YELLOW}K1wOwO_K1tt3h${CYAN}'s, ${YELLOW}cOwOltowonwawaewewXD${CYAN}'s, and the Whowe OwO Team's OwOify
   (Mawio Wepwacement by ${YELLOW}NapstiOwO${CYAN}) | ${RED}Needs External Resources
${CYAN}C)ontinue${RESET}

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

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
	"3")  wget https://cdn.discordapp.com/attachments/719182301396860988/724447689907109939/owo-wip-1.2.3-1.zip
          cd ./actors/mario
          wget https://cdn.discordapp.com/attachments/722985251512516618/724428744185348116/mario.rar
          if [ ! -f ../../owo-wip-1.2.3-1.zip ] || [ ! -f mario.rar ]; then
          	echo -e "${RED}Your download fucked up"
          else
          	unrar x -o+ mario.rar
          	rm mario.rar
          	cd ../../
			if grep -q '#include "mario/geo_header.h"' "./actors/group0.h"; then
			    echo -e "\n${RED}The fiwe is awweady modified cowwectwy.${RESET}\n"
			else
			    sed -i '/#endif/i \
#include "mario/geo_header.h"' ./actors/group0.h
			fi
          	echo -e "$\n${YELLOW}K1wOwO_K1tt3h${GREEN}'s, ${YELLOW}cOwOltowonwawaewewXD${GREEN}'s, and the Whowe OwO Team's OwOify\n(Mawio Wepwacement by ${YELLOW}NapstiOwO${GREEN}) Sewected${RESET}\n"
		t_selection3="+"
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
"${YELLOW}================================================================================${RESET}
${CYAN}Various Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

1$v_selection1) 120 Star Save
2$v_selection2) Enable Debug Level Selector (WIP) by ${YELLOW}Dummy unu boi
${CYAN}3$v_selection3) BLJ Anywhere by ${YELLOW}GateGuy ${CYAN}| ${RED}Cheat (conflicts with other patched cheats)
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  wget https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
		  if [ -f $APPDATA/sm64ex/sm64_save_file.bin ]; then
		  	mv -f $APPDATA/sm64ex/sm64_save_file.bin $APPDATA/sm64ex/sm64_save_file.old.bin
		  	mv sm64_save_file.bin $APPDATA/sm64ex/sm64_save_file.bin
		  else
		  	mv sm64_save_file.bin $APPDATA/sm64ex/sm64_save_file.bin
		  fi
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
			echo -e "$\n${GREEN}Enable Debug Level Selector (WIP) by ${YELLOW}Dummy unu boi ${GREEN}Selected${RESET}\n"
			v_selection2="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/722566901749907496/0001-WIP-Enable-debug-level-selector.patch
		  	cd ../
	      	git apply ./enhancements/0001-WIP-Enable-debug-level-selector.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}Enable Debug Level Selector (WIP) by ${YELLOW}Dummy unu boi ${GREEN}Selected${RESET}\n"
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
"${YELLOW}================================================================================${RESET}
${CYAN}Fixes Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

1$f_selection1) Mouse Support and Fixes for Reshade (WIP) by ${YELLOW}Dummy unu boi
${CYAN}2$f_selection2) Increase Delay on Star Select by ${YELLOW}GateGuy ${CYAN}| ${RED}Breaks TAS Support
${CYAN}3$f_selection3) Go Back to Title Screen from Ending by ${YELLOW}GateGuy
${CYAN}4$f_selection4) Exit Course 50 Coin Fix by ${YELLOW}Keanine ${CYAN}| ${GREEN}Works in Master and Nightly
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch" ]]; then
			git apply ./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Mouse Support and Fixes for Reshade (WIP) by ${YELLOW}Dummy unu boi ${GREEN}Selected${RESET}\n"
			f_selection1="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/722662190267760660/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch
		  	cd ../
	      	git apply ./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}Mouse Support and Fixes for Reshade (WIP) by ${YELLOW}Dummy unu boi ${GREEN}Selected${RESET}\n"
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
    "4")  if [[ -f "./enhancements/exit_course_50_coin_fix.patch" ]]; then
			git apply ./enhancements/exit_course_50_coin_fix.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Exit Course 50 Coin Fix by ${YELLOW}Keanine ${GREEN}Selected${RESET}\n"
			f_selection4="+"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/721818545087840257/725094603258200105/exit_course_50_coin_fix.patch
		  	cd ../
	      	git apply ./enhancements/exit_course_50_coin_fix.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}Exit Course 50 Coin Fix by ${YELLOW}Keanine ${GREEN}Selected${RESET}\n"
		f_selection4="+"
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
"${YELLOW}================================================================================${RESET}
${CYAN}Custom Install Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

1) Install Patches                    
2) Install Texture Packs | ${RED}Needs External Resources
${CYAN}C)ontinue${RESET}

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  echo -e "\n${YELLOW}Select a patch to install${RESET}\n"
    	  PATCH_FILE=$(zenity --file-selection --title="Select the patch file")
    	  git apply $PATCH_FILE --ignore-whitespace --reject
    	  echo ""
    	  echo "${GREEN}$PATCH_FILE selected${RESET}"
          sleep 2
            ;;
    "2")  echo -e "\n${YELLOW}Select a texture pack to install${RESET}\n"
    	  TEXTURE_PACK=$(zenity --file-selection --title="Select the texture pack zip file")
		  if [ "$I_Want_US" = true ]; then
				mkdir -p build/us_pc/res
				cp $TEXTURE_PACK ./build/us_pc/res
		  elif [ "$I_Want_JP" = true ]; then
				mkdir -p build/jp_pc/res
				cp $TEXTURE_PACK ./build/jp_pc/res
		  elif [ "$I_Want_EU" = true ]; then
				mkdir -p build/eu_pc/res
				cp $TEXTURE_PACK ./build/eu_pc/res
		  fi
  		  echo "${GREEN}$TEXTURE_PACK selected${RESET}"
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
"${YELLOW}================================================================================${RESET}
${CYAN}Uninstall Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a letter to select:

C)ontinue
cU)stom
M)odels
V)arious
E)nhancements
F)ixes

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

	read -n1 -s
    case "$REPLY" in
    "u")  while :
do
    clear
	echo \
"${YELLOW}================================================================================${RESET}
${CYAN}Custom Uninstall Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

1) Uninstall Patches                    
2) Uninstall Texture Packs
C)ontinue${RESET}

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  echo -e "\n${YELLOW}Select a patch to uninstall${RESET}\n"
    	  PATCH_FILE=$(zenity --file-selection --title="Select the patch file")
    	  git apply -R $PATCH_FILE --ignore-whitespace --reject
    	  echo ""
    	  echo "${GREEN}$PATCH_FILE removed${RESET}"
          sleep 2
            ;;
    "2")  if [ "$I_Want_US" = true ]; then
				echo -e "\n${YELLOW}Select a texture pack to uninstall. They are found in build/us_pc/res${RESET}\n"
				TEXTURE_PACK=$(zenity --file-selection --title="Select the texture pack zip file found in build/us_pc/res")
		  elif [ "$I_Want_JP" = true ]; then
				echo -e "\n${YELLOW}Select a texture pack to uninstall. They are found in build/jp_pc/res${RESET}\n"
				TEXTURE_PACK=$(zenity --file-selection --title="Select the texture pack zip file found in build/jp_pc/res")
		  elif [ "$I_Want_EU" = true ]; then
				echo -e "\n${YELLOW}Select a texture pack to uninstall. They are found in build/eu_pc/res${RESET}\n"
				TEXTURE_PACK=$(zenity --file-selection --title="Select the texture pack zip file found in build/eu_pc/res")
		  fi
  		  rm $TEXTURE_PACK
  		  echo "${GREEN}$TEXTURE_PACK removed${RESET}"
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
"${YELLOW}================================================================================${RESET}
${CYAN}Uninstall Models Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

1$m_u_selection1) Uninstall 3D Coin Patch v2 by ${YELLOW}grego2d ${CYAN}and ${YELLOW}TzKet-Death
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

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
"${YELLOW}================================================================================${RESET}
${CYAN}Uninstall Various Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

${CYAN}1$v_u_selection1) Uninstall Enable Debug Level Selector (WIP) by ${YELLOW}Dummy unu boi
${CYAN}2$v_u_selection2) Uninstall BLJ Anywhere by ${YELLOW}GateGuy ${CYAN}| ${RED}Cheat (conflicts with other patched
   cheats)
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/0001-WIP-Enable-debug-level-selector.patch" ]]; then
			git apply -R ./enhancements/0001-WIP-Enable-debug-level-selector.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Enable Debug Level Selector (WIP) by ${YELLOW}Dummy unu boi ${GREEN}Removed${RESET}\n"
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
"${YELLOW}================================================================================${RESET}
${CYAN}Uninstall Enhancements Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

1$e_u_selection1) Uninstall 60 FPS Patch (Destroys ${YELLOW}Arredondo ${CYAN}HD Mario Head, WIP) | ${GREEN}Works in
   Master and Nightly
${CYAN}2$e_u_selection2) Uninstall Stay in Course by ${YELLOW}Keanine ${CYAN}| ${RED}Currently Broken
${CYAN}3$e_u_selection3) Uninstall Stay in Level After Star by ${YELLOW}GateGuy ${CYAN}| ${RED}Cheat (conflicts with other
   patched cheats)
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/60fps_interpolation_wip.patch" ]] && [ "$I_Want_Master" = true ]; then
			git apply -R ./enhancements/60fps_interpolation_wip.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Removed${RESET}\n"
			e_u_selection1="+"
		  elif [[ -f "./enhancements/60fps_interpolation_wip_nightly.patch" ]] && [ "$I_Want_Nightly" = true ]; then
			git apply -R ./enhancements/60fps_interpolation_wip_nightly.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch (Destroys ${YELLOW}Arredondo ${GREEN}HD Mario Head, WIP) Removed${RESET}\n"
			e_u_selection1="+"
          fi
          sleep 2
            ;;
    "2")  if [[ -f "./enhancements/stay_in_course.patch" ]]; then
			git apply -R ./enhancements/stay_in_course.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Stay in Course by ${YELLOW}Keanine ${GREEN}Removed${RESET}\n"
			e_u_selection2="+"
		  fi
		  sleep 2
		    ;;
    "3")  if [[ -f "./enhancements/stay_after_star_nonstop_mode_cheat.patch" ]]; then
			git apply -R ./enhancements/stay_after_star_nonstop_mode_cheat.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Stay in Level After Star by ${YELLOW}GateGuy ${GREEN}Removed${RESET}\n"
			e_u_selection3="+"
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
"${YELLOW}================================================================================${RESET}
${CYAN}Uninstall Fixes Menu${RESET}
${YELLOW}--------------------------------------------------------------------------------${RESET}
${CYAN}Press a number to select:

${CYAN}1$f_u_selection1) Uninstall Mouse Support and Fixes for Reshade (WIP) by ${YELLOW}Dummy unu boi
${CYAN}2$f_u_selection2) Uninstall Increase Delay on Star Select by ${YELLOW}GateGuy ${CYAN}| ${RED}Breaks TAS Support
${CYAN}3$f_u_selection3) Uninstall Go Back to Title Screen from Ending by ${YELLOW}GateGuy
${CYAN}4$f_u_selection4) Uninstall Exit Course 50 Coin Fix by ${YELLOW}Keanine ${CYAN}| ${GREEN}Works in Master and Nightly
${CYAN}C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}--------------------------------------------------------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch" ]]; then
			git apply -R ./enhancements/0001-WIP-Added-mouse-support-and-some-fixes-for-reshade.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Mouse Support and Fixes for Reshade (WIP) by ${YELLOW}Dummy unu boi ${GREEN}Removed${RESET}\n"
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
    "4")  if [[ -f "./enhancements/exit_course_50_coin_fix.patch" ]]; then
			git apply -R ./enhancements/exit_course_50_coin_fix.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}Exit Course 50 Coin Fix by ${YELLOW}Keanine ${GREEN}Removed${RESET}\n"
			f_u_selection4="+"
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
			printf "${RED}RUN \"Clean build\" REGULARLY. Every time you want to update to a newer version or\nbuild with different options you have to choose the option \"Clean build\" or\nmanually remove or rename sm64-port/build\n${RESET}"
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

# sm64ex flags menu
if [ "$I_Want_Master" = true ] || [ "$I_Want_Nightly" = true ]; then
	menu() {
			printf "\nAvailable options:\n"
			for i in ${!SM64EX_OPTIONS[@]}; do 
					printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${SM64EX_OPTIONS[i]}"
			done
			if [[ "$msg" ]]; then echo "$msg"; fi
			printf "${YELLOW}Please do not select \"Clean build\" with any other option.\n"
			printf "${RED}WARNING: Backup your save file before selecting \"Clean build\".\n"
			printf "${CYAN}Press the corresponding number and press enter to select it.\nWhen all desired options are selected, press Enter to continue.\n"
			if [ "$I_Want_Master" = true ]; then
				printf "${RED}RUN \"Clean build\" REGULARLY. Every time you want to update to a newer version or\nbuild with different options you have to choose the option \"Clean build\" or\nmanually remove or rename sm64ex-master/build\n"
			elif [ "$I_Want_Nightly" = true ]; then
				printf "${RED}RUN \"Clean build\" REGULARLY. Every time you want to update to a newer version or\nbuild with different options you have to choose the option \"Clean build\" or\nmanually remove or rename sm64ex-nightly/build\n"
			fi
			printf "${YELLOW}Check Remove Extended Options Menu & leave other options unchecked for a Vanilla\nbuild.\n${RESET}"
	}

	prompt="Check an option (again to uncheck, press ENTER):"$'\n'
	while menu && read -rp "$prompt" num && [[ "$num" ]]; do
			[[ "$num" != *[![:digit:]]* ]] &&
			(( num > 0 && num <= ${#SM64EX_OPTIONS[@]} )) ||
			{ msg="Invalid option: $num"; continue; }
			((num--)); # msg="${SM64EX_OPTIONS[num]} was ${choices[num]:+un}checked"
			[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
	done

	for i in ${!SM64EX_OPTIONS[@]}; do 
			[[ "${choices[i]}" ]] && { CMDL+=" ${SM64EX_EXTRA[i]}"; }
	done
fi

# Checks the computer architecture
if [ "${CMDL}" != " clean" ] && [ "$I_Want_US" = true ]; then
	echo -e "\n${YELLOW} Executing: ${CYAN}make${CMDL} $1${RESET}\n\n"
	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
		PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL $1
	else
		PATH=/mingw32/bin:$PATH make $CMDL $1
	fi
	if ls $BINARY_US 1> /dev/null 2>&1; then
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
			if [ -f owo-wip-1.2.3-1.zip ]; then
				mv owo-wip-1.2.3-1.zip ./build/us_pc/res
			fi
		fi

		# Shows the correct binary location
    	zenity --info \
		--text="The binary is now available in the 'build/us_pc/' folder."
		echo -e "\n${YELLOW}If fullscreen doesn't seem like the correct resolution, then right click on the\nexe, go to properties, compatibility, then click Change high DPI settings.\nCheck the 'Override high DPI scaling behavior' checkmark, leave it on\napplication, then press apply."
		cd ./build/us_pc/
		start .
	else
		zenity --warning \
		--text="Oh no! Something went wrong."
	fi

# Checks the computer architecture
elif [ "${CMDL}" != " clean" ] && [ "$I_Want_JP" = true ]; then
	echo -e "\n${YELLOW} Executing: ${CYAN}make${CMDL} VERSION=jp $1${RESET}\n\n"
	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
		PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL VERSION=jp $1
	else
		PATH=/mingw32/bin:$PATH make $CMDL VERSION=jp $1
	fi
	if ls $BINARY_JP 1> /dev/null 2>&1; then
		if [ -f ReShade_Setup_4.6.1.exe ]; then
			mv ./ReShade_Setup_4.6.1.exe ./build/jp_pc/ReShade_Setup_4.6.1.exe
		fi

		# Move sound packs
		if [ -d ./build/jp_pc/res ]; then
			if [ -f sunshinesounds.zip ]; then
				mv sunshinesounds.zip ./build/jp_pc/res
				rm sunshinesounds* # in case they exist from running the script before or selecting multiple times.
			fi
		fi

		# Move texture packs
		if [ -d ./build/jp_pc/res ]; then
			if [ -f Hypatia_Mario_Craft_Complete.part3.rar ]; then
				mkdir ./build/hmcc/
				unrar x -o+ Hypatia_Mario_Craft_Complete.part1.rar ./build/hmcc/
				mv ./build/hmcc/res ./build/hmcc/gfx
				cd ./build/hmcc/
				zip -r hypatiamariocraft gfx
				mv hypatiamariocraft.zip ../../build/jp_pc/res
				cd ../../
            	rm Hypatia_Mario_Craft_Complete.part*
				rm -rf ./build/hmcc/
			fi
			if [ -f mollymutt.zip ]; then
				mv mollymutt.zip ./build/jp_pc/res
			fi
			if [ -f owo-wip-1.2.3-1.zip ]; then
				mv owo-wip-1.2.3-1.zip ./build/jp_pc/res
			fi
		fi

		# Shows the correct binary location
    	zenity --info \
		--text="The binary is now available in the 'build/jp_pc/' folder."
		echo -e "\n${YELLOW}If fullscreen doesn't seem like the correct resolution, then right click on the\nexe, go to properties, compatibility, then click Change high DPI settings.\nCheck the 'Override high DPI scaling behavior' checkmark, leave it on\napplication, then press apply."
		cd ./build/jp_pc/
		start .
	else
		zenity --warning \
		--text="Oh no! Something went wrong."
	fi

# Checks the computer architecture
elif [ "${CMDL}" != " clean" ] && [ "$I_Want_EU" = true ]; then
	echo -e "\n${YELLOW} Executing: ${CYAN}make${CMDL} VERSION=eu $1${RESET}\n\n"
	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
		PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL VERSION=eu $1
	else
		PATH=/mingw32/bin:$PATH make $CMDL VERSION=eu $1
	fi
	if ls $BINARY_EU 1> /dev/null 2>&1; then
		if [ -f ReShade_Setup_4.6.1.exe ]; then
			mv ./ReShade_Setup_4.6.1.exe ./build/eu_pc/ReShade_Setup_4.6.1.exe
		fi

		# Move sound packs
		if [ -d ./build/eu_pc/res ]; then
			if [ -f sunshinesounds.zip ]; then
				mv sunshinesounds.zip ./build/eu_pc/res
				rm sunshinesounds* # in case they exist from running the script before or selecting multiple times.
			fi
		fi

		# Move texture packs
		if [ -d ./build/eu_pc/res ]; then
			if [ -f Hypatia_Mario_Craft_Complete.part3.rar ]; then
				mkdir ./build/hmcc/
				unrar x -o+ Hypatia_Mario_Craft_Complete.part1.rar ./build/hmcc/
				mv ./build/hmcc/res ./build/hmcc/gfx
				cd ./build/hmcc/
				zip -r hypatiamariocraft gfx
				mv hypatiamariocraft.zip ../../build/eu_pc/res
				cd ../../
            	rm Hypatia_Mario_Craft_Complete.part*
				rm -rf ./build/hmcc/
			fi
			if [ -f mollymutt.zip ]; then
				mv mollymutt.zip ./build/eu_pc/res
			fi
			if [ -f owo-wip-1.2.3-1.zip ]; then
				mv owo-wip-1.2.3-1.zip ./build/eu_pc/res
			fi
		fi

		# Shows the correct binary location
    	zenity --info \
		--text="The binary is now available in the 'build/eu_pc/' folder."
		echo -e "\n${YELLOW}If fullscreen doesn't seem like the correct resolution, then right click on the\nexe, go to properties, compatibility, then click Change high DPI settings.\nCheck the 'Override high DPI scaling behavior' checkmark, leave it on\napplication, then press apply."
		cd ./build/eu_pc/
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
