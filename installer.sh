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
Ok="${OnBlack}${Green} ok.${Off}"
Fail="${OnBlack}${Red} failed!${Off}"
Nok="${OnBlack}${Yellow} nok.${Off}"
Stat="${OnBlack}${Purple}"
StatInfo="${OnBlack}${White}"

################################################################
# Vars                                                         #
################################################################
VERSION="v0.1.0"
XMRSH_DIR="/opt/xmr.sh"
XMRSH_BRANCH="main"
XMRSH_URL="https://github.com/vdo/xmr.sh"
XMRSH_LOG_FILE="/tmp/xmr.sh-$(date +%Y%m%d-%H%M%S).log"
DOCKER_INSTALLED=false
DOCKER_COMPOSE_INSTALLED=false
DOCKER_COMPOSE_VERSION="v2.5.0"
DEPENDENCIES="git curl"
ONION="Not Available"
TLS_PORT="443"
TLS_DOMAIN=""
TLS_EMAIL=""

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

detect_root() {
    echo -ne "${OkBullet}Checking root... ${Off}"
    if [[ $EUID -ne 0 ]]; then
        echo -e "${Fail}"
        echo -e "${ErrBullet}You need to run this script as root (UID=0).${Off}"
        exit 1
    fi
    echo -e "${Ok}"
}

check_deps() {
    echo -ne "${OkBullet}Checking and installing dependencies... ${Off}"
    # shellcheck disable=SC2068
    for pkg in ${DEPENDENCIES[@]}; do
        if ! command -v "${pkg}" >>"${XMRSH_LOG_FILE}" 2>&1; then
            install_pkg "${pkg}"
            check_return $?
        fi
    done
    echo -e "${Ok}"
}

install_pkg() {
    # This detects both ubuntu and debian
    if grep -q "debian" /etc/os-release; then
        apt-get update >>"${XMRSH_LOG_FILE}" 2>&1
        apt-get install -y "$1" >>"${XMRSH_LOG_FILE}" 2>&1
    elif grep -q "fedora" /etc/os-release || grep -q "centos" /etc/os-release; then
        dnf install -y "$1" >>"${XMRSH_LOG_FILE}" 2>&1
    else
        echo -e "${ErrBullet}Cannot detect your distribution package manager.${Off}"
        exit 1
    fi
}

detect_curl() {
    echo -ne "${OkBullet}Checking curl... ${Off}"
    # docker --version >>"${XMRSH_LOG_FILE}" 2>&1 | grep -q "Docker version"
    if curl --version >>"${XMRSH_LOG_FILE}" 2>&1; then
        echo -e "${Ok}"
    else
        echo -e "${Nok}"
        echo -e "${ErrBullet}Please install curl first.${Off}"
        exit 1
    fi
}

detect_docker() {
    echo -ne "${OkBullet}Checking docker... ${Off}"
    # docker --version >>"${XMRSH_LOG_FILE}" 2>&1 | grep -q "Docker version"
    if docker --version >>"${XMRSH_LOG_FILE}" 2>&1; then
        DOCKER_INSTALLED=true
        echo -e "${Ok}"
    else
        echo -e "${Nok}"
    fi
}

detect_docker_compose() {
    echo -ne "${OkBullet}Checking docker compose... ${Off}"
    #docker-compose --version >>"${XMRSH_LOG_FILE}" 2>&1 | grep -q "Docker Compose version"
    if docker-compose --version >>"${XMRSH_LOG_FILE}" 2>&1; then
        DOCKER_COMPOSE_INSTALLED=true
        echo -e "${Ok}"
    else
        echo -e "${Nok}"
    fi
}

install_docker() {
    echo -ne "${OkBullet}Installing docker... ${Off}"
    # Docker Installer as provided in
    curl -fsSL https://get.docker.com -o - | bash >>"${XMRSH_LOG_FILE}" 2>&1
    check_return $?
    # Fedora and Centos need to enable & start the daemon
    if grep -q "fedora" /etc/os-release || grep -q "centos" /etc/os-release; then
        systemctl enable docker >>"${XMRSH_LOG_FILE}" 2>&1
        systemctl start docker >>"${XMRSH_LOG_FILE}" 2>&1
    fi
    echo -e "${Ok}"
}

install_docker_compose() {
    echo -ne "${OkBullet}Installing compose... ${Off}"
    # Install docker-compose binary, even if "docker compose" exists, for consistency.
    curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose >>"${XMRSH_LOG_FILE}" 2>&1
    check_return $?
    chmod +x /usr/local/bin/docker-compose >>"${XMRSH_LOG_FILE}" 2>&1
    check_return $?
    echo -e "${Ok}"
}

install_xmrsh() {
    echo -ne "${OkBullet}Installing xmr.sh... ${Off}"
    if [ ! -d "$XMRSH_DIR" ]; then
        git clone -b "${XMRSH_BRANCH}" "${XMRSH_URL}" "${XMRSH_DIR}" >>"${XMRSH_LOG_FILE}" 2>&1
        check_return $?
        pushd "${XMRSH_DIR}" >>"${XMRSH_LOG_FILE}" 2>&1 || return
    else
        echo -e "${Ok}"
        echo -e "${WarnBullet}Warning: xmr.sh already present in ${XMRSH_DIR}" #FIXME: This should probably exit
        return
    fi
    echo -e "${Ok}"
}

configure_tls_domain() {
    echo -e "${OkBullet}Enter the desired domain for the Let's Encrypt SSL certificate."
    read -r -e -p "   Leave empty to use a self signed certificate []: " TLS_DOMAIN
    if [ -n "${TLS_DOMAIN}" ]; then
        while ! echo "${TLS_DOMAIN}" | grep -qP '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'; do
            echo -e "${WarnBullet}Domain not valid."
            read -r -p "   Enter again your desired domain []: " TLS_DOMAIN
        done
        echo -e "${OkBullet}Enter the desired email for the Let's Encrypt SSL certificate."
        read -r -e -p "   Enter a valid email. Let's Encrypt validates it! []: " TLS_DOMAIN
        while ! echo "${TLS_EMAIL}" | grep -qP '^[A-Za-z0-9+._-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}$'; do
            echo -e "${WarnBullet}Email not valid."
            read -r -p "   Enter again your desired email []: " TLS_EMAIL
        done
        # Set domain and email address in vars
        sed -i "s/DOMAIN=.*/DOMAIN=${TLS_DOMAIN}/g" .env
        sed -i "s/TRAEFIK_ACME_EMAIL=.*/TRAEFIK_ACME_EMAIL=${TLS_EMAIL}/g" .env
        # Enable LE settings in compose
        sed -i '/#!le/s/# //g' docker-compose.yml
        sed -i "/#\!traefik-command/s/\*traefik-command-nole/\*traefik-command-le/g" docker-compose.yml
    fi
}

configure_cors() {
    echo -e "${OkBullet}Configuring CORS..."
    while true; do
        read -r -e -p "   Do you want to enabe CORS headers so the node can be used in webapps? [y/n]: " yn
        case $yn in
        [Yy]*)
            sed -i '/#!cors/s/# //g' docker-compose.yml
            break
            ;;
        [Nn]*) break ;;
        *) echo "   Please answer yes or no." ;;
        esac
    done
}

configure_tor() {
    echo -e "${OkBullet}Configuring tor..."
    while true; do
        read -r -e -p "   Do you want to enable a Tor hidden service? [y/n]: " yn
        case $yn in
        [Yy]*)
            sed -i '/#!tor/s/# //g' docker-compose.yml
            ENABLE_TOR=true
            break
            ;;
        [Nn]*) break ;;
        *) echo "   Please answer yes or no." ;;
        esac
    done
}

configure_explorer() {
    echo -e "${OkBullet}Configuring explorer..."
    while true; do
        read -r -e -p "   Do you want to enable an explorer service? [y/n]: " yn
        case $yn in
        [Yy]*)
            sed -i '/#!explorer/s/# //g' docker-compose.yml
            ENABLE_EXPLORER=true
            break
            ;;
        [Nn]*) break ;;
        *) echo "   Please answer yes or no." ;;
        esac
    done
}

configure_watchtower() {
    echo -e "${OkBullet}Configuring watchtower..."
    while true; do
        read -r -e -p "   Do you want to enable automatic updates using watchtower? [y/n]: " yn
        case $yn in
        [Yy]*)
            sed -i '/#!watchtower/s/# //g' docker-compose.yml
            break
            ;;
        [Nn]*) break ;;
        *) echo "   Please answer yes or no." ;;
        esac
    done
}

# get_public_ip() {
#     # Using dig:
#     # dig +short txt ch whoami.cloudflare @1.0.0.1
#     PUBLIC_IP=$(curl -s ifconfig.co)
# }

validate_domain() {
    echo "$1" | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'
}

start_xmrsh() {
    echo -ne "${OkBullet}Starting monero node and services... ${Off}"
    docker-compose pull >>"${XMRSH_LOG_FILE}" 2>&1
    check_return $?
    docker-compose up -d >>"${XMRSH_LOG_FILE}" 2>&1
    check_return $?

    if ENABLE_TOR = true; then
        sleep 3
        ONION=$(docker logs tor 2>&1 | grep Entrypoint | cut -d " " -f 8)
    fi
    echo -e "${Ok}"
}

check_return() {
    if [ "$1" -ne 0 ]; then
        echo -e "${Fail}"
        echo -e "${ErrBullet}Installation failed. Check the logs in ${XMRSH_LOG_FILE}${Off}"
        exit "$1"
    fi
}

completed() {
    echo -e "${OkBullet}Deployment complete.${Off}"
    echo
    echo -e " ${Red}┌───────────────────────────────────────────────────────────────────────────[info]──"
    if [ -n "$TLS_DOMAIN" ]; then
        echo -e " ${Red}│${Stat} URL: ${StatInfo}${TLS_DOMAIN}:${TLS_PORT}"
    fi
    echo -e " ${Red}│${Stat} Public IP: ${StatInfo}$(curl -s ifconfig.co 2>>"${XMRSH_LOG_FILE}"):${TLS_PORT}"
    echo -e " ${Red}│${Stat} Onion Service: ${StatInfo}$ONION"
    echo -e " ${Red}│"
    echo
}

header
detect_root
check_deps
detect_docker
detect_docker_compose

if [ $DOCKER_INSTALLED = false ]; then
    install_docker
    install_docker_compose
fi

if [ $DOCKER_INSTALLED = true ] && [ $DOCKER_COMPOSE_INSTALLED = false ]; then
    install_docker_compose
fi

install_xmrsh
configure_tls_domain
configure_cors
configure_tor
configure_explorer
configure_watchtower
start_xmrsh
completed

exit 0
