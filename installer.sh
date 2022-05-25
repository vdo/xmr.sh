#!/bin/bash

################################################################
# Color Aliases                                                #
################################################################
# Reset
Off='\033[0m' # Text Reset

# Regular Colors
Black='\033[0;30m'  # Black
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m'   # Blue
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan
White='\033[0;37m'  # White

# Bold
BBlack='\033[1;30m'  # Black
BRed='\033[1;31m'    # Red
BGreen='\033[1;32m'  # Green
BYellow='\033[1;33m' # Yellow
BBlue='\033[1;34m'   # Blue
BPurple='\033[1;35m' # Purple
BCyan='\033[1;36m'   # Cyan
BWhite='\033[1;37m'  # White

# Underline
UBlack='\033[4;30m'  # Black
URed='\033[4;31m'    # Red
UGreen='\033[4;32m'  # Green
UYellow='\033[4;33m' # Yellow
UBlue='\033[4;34m'   # Blue
UPurple='\033[4;35m' # Purple
UCyan='\033[4;36m'   # Cyan
UWhite='\033[4;37m'  # White

# Background
On_Black='\033[40m'  # Black
On_Red='\033[41m'    # Red
On_Green='\033[42m'  # Green
On_Yellow='\033[43m' # Yellow
On_Blue='\033[44m'   # Blue
On_Purple='\033[45m' # Purple
On_Cyan='\033[46m'   # Cyan
On_White='\033[47m'  # White

OkBullet="${OnBlack}${Green}:: ${White}"
WarnBullet="${OnBlack}${Yellow}:: ${White}"
ErrBullet="${OnBlack}${Red}:: ${White}"
Done="${OnBlack}${White} done.${Off}"
Fail="${OnBlack}${Red} failed!${Off}"

################################################################
# Constants                                                    #
################################################################
VERSION="v0.1.0"
XMRSH_DIR="/opt/xmr.sh"
XMRSH_LOG_FILE="/tmp/xmr.sh-$(date +%Y%m%d-%H%M%S).log"

################################################################
# Functions                                                    #
################################################################

header() {
    echo -e "${OnBlack}${Red}                         _     "
    echo -e "__  ___ __ ___  _ __ ___| |__  "
    echo -e "\ \/ / '_ ' _ \| '__/ __| '_ \ "
    echo -e " >  <| | | | | | | _\__ \ | | |"
    echo -e "/_/\_\_| |_| |_|_|(_)___/_| |_|"
    echo -e "                 Version ${VERSION}${Off}\n"
}

detect_root() { (
    set -e
    echo -ne "${OkBullet}Checking root... ${Off}"
    if [[ $EUID -ne 0 ]]; then
        echo -e "${Fail}"
        echo -e "${ErrBullet}You need to run this script as root (UID=0).${Off}"
        exit 1
    fi
    echo -e "${Done}"
); }

detect_docker() { (
    set -e
    which docker >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        docker --version | grep "Docker version" >${XMRSH_LOG_FILE} 2>&1
        if [ $? -eq 0 ]; then
            echo "Docker installation exists!"
        else
            echo "install docker"
        fi
    else
        echo "install docker" >&2
    fi
); }

# Detect Docker Compose
detect_docker_compose() {
    docker compose version >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        docker --version | grep "Docker version" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Docker installation exists!"
        else
            echo "install docker"
        fi
    else
        echo "install docker" >&2
    fi
}

install_docker() { (
    set -e
    echo -ne "${OkBullet}Installing docker... ${Off}"
    # Install docker
    curl -fsSL https://get.docker.com -o - | bash 2>&1
    echo -e "${Done}"
); }
header
detect_root
detect_docker

exit 0
