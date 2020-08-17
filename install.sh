#!/usr/bin/env bash

info() {
    clear
    echo -e "\033[1;34m##############################################################\033[1;37m"
    echo -e "\033[1;34m##\033[1;37m             \033[1;33mQlauncher Installer for \033[1;35mRaspbian\033[1;37m\033[1;34m             ##\033[1;37m"
    echo -e "\033[1;34m##############################################################\033[1;37m"
}

tools() {
	echo
	echo -e "\033[1;32m	[+] Updating Package...\033[1;37m"
	sudo apt update -y
	sudo apt upgrade -y
	echo -e "\033[1;32m     [+] Installing Requirements...\033[1;37m"
	sudo apt install curl wget nano net-tools nmap dmidecode lolcat -y > sudo /dev/null 2>&1 &
	wget https://github.com/poseidon-network/qlauncher-linux/releases/latest/download/ql-linux.tar.gz -O ql.tar.gz > sudo /dev/null 2>&1 &
}

docker() {
	echo
	echo -e "\033[1;32m     [+] Installing Docker ...\033[1;37m"
	curl -sSL https://get.docker.com | sh
	sudo usermod -aG docker pi
}

ql() {
	echo
	echo -e "\033[1;32m     [+] Installing qlauncher...\033[1;37m"
	mkdir /home/pi/qlauncher > sudo /dev/null 2>&1 &
	tar -vxzf ql.tar.gz -C /home/pi/qlauncher > sudo /dev/null 2>&1 &
}

onboot() {
sudo cat > /etc/systemd/system/qlauncher.service << EOF
[Unit]
Description=qlauncher.service
[Service]
Type=simple
ExecStart=/home/pi/qlauncher/qlauncher.sh start
ExecStop=/home/pi/qlauncher/qlauncher.sh stop
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
}

reload() {
sudo systemctl daemon-reload
sudo systemctl enable qlauncher
}

script() {
sudo curl -o /usr/local/bin/Q https://raw.githubusercontent.com/jakues/ql-rpi/master/conf/Q
sudo chmod +x /usr/local/bin/Q
}

#Checking if user run on rpi
HOST_ARCH=$(uname -m)
if [ "${HOST_ARCH}" != "armv7l" ] && [ "${HOST_ARCH}" != "aarch64" ]; then
  echo -e "\033[1;31m     [!] This script is only intended to run on ARM devices."
  exit 1
fi

PI_MODEL=$(cat /proc/device-tree/model)
if [[ "${PI_MODEL}" == *"Raspberry Pi 4"* ]]; then
  info
  tools
  docker
  ql
  onboot
  reload
  script
  clear
  Q --help
  Q --about
else
  echo -e "\033[1;31m     [!] This is not a Raspberry Pi 4."
  exit 1
fi
