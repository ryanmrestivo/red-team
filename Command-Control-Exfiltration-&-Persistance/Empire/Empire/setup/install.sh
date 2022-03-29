#!/bin/bash
function install_powershell() {
  echo -e "\x1b[1;34m[*] Installing Powershell\x1b[0m"
  if [ $OS_NAME == "DEBIAN" ]; then
    wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y powershell
  elif [ $OS_NAME == "UBUNTU" ]; then
    sudo apt-get update
    sudo apt-get install -y wget apt-transport-https software-properties-common
    wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update
    sudo add-apt-repository universe
    sudo apt-get install -y powershell
  elif [ $OS_NAME == "KALI" ]; then
    apt update && apt -y install powershell
  fi

  mkdir -p /usr/local/share/powershell/Modules
  cp -r "$PARENT_PATH"/empire/server/powershell/Invoke-Obfuscation /usr/local/share/powershell/Modules
  rm -f packages-microsoft-prod.deb*
}

function install_xar() {
  # xar-1.6.1 has an incompatibility with libssl 1.1.x that is patched here
  wget https://github.com/BC-SECURITY/xar/archive/xar-1.6.1-patch.tar.gz
  rm -rf xar-1.6.1
  rm -rf xar-1.6.1-patch/xar
  rm -rf xar-xar-1.6.1-patch
  tar -xvf xar-1.6.1-patch.tar.gz && mv xar-xar-1.6.1-patch/xar/ xar-1.6.1/
  (cd xar-1.6.1 && ./autogen.sh)
  (cd xar-1.6.1 && ./configure)
  (cd xar-1.6.1 && make)
  (cd xar-1.6.1 && sudo make install)
  rm -rf xar-1.6.1
  rm -rf xar-1.6.1-patch/xar
  rm -rf xar-xar-1.6.1-patch
}

function install_bomutils() {
  rm -rf bomutils
  git clone https://github.com/BC-SECURITY/bomutils.git
  (cd bomutils && make)
  (cd bomutils && sudo make install)
  chmod 755 bomutils/build/bin/mkbom && sudo cp bomutils/build/bin/mkbom /usr/local/bin/.
  rm -rf bomutils
}

export DEBIAN_FRONTEND=noninteractive
set -e

apt-get update && apt-get install -y wget sudo

sudo -v

# https://stackoverflow.com/questions/24112727/relative-paths-based-on-file-location-instead-of-current-working-directory
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; cd .. ; pwd -P )
OS_NAME=
VERSION_ID=
if grep "10.*" /etc/debian_version 2>/dev/null; then
  echo -e "\x1b[1;34m[*] Detected Debian 10\x1b[0m"
  OS_NAME=DEBIAN
  VERSION_ID=$(cat /etc/debian_version)
elif grep -i "NAME=\"Ubuntu\"" /etc/os-release 2>/dev/null; then
  OS_NAME=UBUNTU
  VERSION_ID=$(grep -i VERSION_ID /etc/os-release | grep -o -E [[:digit:]]+\\.[[:digit:]]+)
  if [ $VERSION_ID != "20.04" ]; then
    echo -e '\x1b[1;31m[!] Ubuntu must be 20.04\x1b[0m' && exit
  fi
  echo -e "\x1b[1;34m[*] Detected Ubuntu 20.04\x1b[0m"
elif grep -i "Kali" /etc/os-release 2>/dev/null; then
  echo -e "\x1b[1;34m[*] Detected Kali\x1b[0m"
  OS_NAME=KALI
  VERSION_ID=KALI_ROLLING
else
  echo -e '\x1b[1;31m[!] Unsupported OS. Exiting.\x1b[0m' && exit
fi

if [ $OS_NAME == "DEBIAN" ]; then
  sudo apt-get update
  sudo apt-get -y install -y python3-dev python3-pip
elif [ $OS_NAME == "UBUNTU" ] && [ $VERSION_ID == "20.04" ]; then
  sudo apt-get update
  sudo apt-get -y install -y python3-dev python3-pip
elif [ $OS_NAME == "KALI" ]; then
  apt-get update
  sudo apt-get -y install -y python3-dev python3-pip
fi

install_powershell

echo -n -e "\x1b[1;33m[>] Do you want to install xar and bomutils? They are only needed to generate a .dmg stager (y/N)? \x1b[0m"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
  sudo apt-get install -y make autoconf g++ git zlib1g-dev libxml2-dev libssl1.1 libssl-dev
  install_xar
  install_bomutils
else
    echo -e "\x1b[1;34m[*] Skipping xar and bomutils\x1b[0m"
fi

echo -n -e "\x1b[1;33m[>] Do you want to install OpenJDK? It is only needed to generate a .jar stager (y/N)? \x1b[0m"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
  sudo apt-get install -y default-jdk
  echo -e "\x1b[1;34m[*] Installing OpenJDK\x1b[0m"
else
  echo -e "\x1b[1;34m[*] Skipping OpenJDK\x1b[0m"
fi

echo -n -e "\x1b[1;33m[>] Do you want to install dotnet? It is needed to use CSharp agents and CSharp modules (y/N)? \x1b[0m"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
  if [ $OS_NAME == "DEBIAN" ]; then
    wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y apt-transport-https dotnet-sdk-3.1
  elif [ $OS_NAME == "UBUNTU" ]; then
    wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y apt-transport-https dotnet-sdk-3.1
  elif [ $OS_NAME == "KALI" ]; then
    wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y apt-transport-https dotnet-sdk-3.1
  fi
else
  echo -e "\x1b[1;34m[*] Skipping dotnet\x1b[0m"
fi

echo -n -e "\x1b[1;33m[>] Do you want to install Nim and MinGW? It is only needed to generate a Nim stager (y/N)? \x1b[0m"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
  if [ $OS_NAME == "DEBIAN" ]; then
    sudo apt install -y curl git gcc
    curl https://nim-lang.org/choosenim/init.sh -sSf | sh -s -- -y
    echo "export PATH=/root/.nimble/bin:$PATH" >> ~/.bashrc
    export PATH=/root/.nimble/bin:$PATH
    SOURCE_MESSAGE=true
  else
    sudo apt install -y nim
  fi
  nimble install -y winim zippy nimcrypto
  sudo apt install -y mingw-w64
else
  echo -e "\x1b[1;34m[*] Skipping Nim\x1b[0m"
fi

echo -e "\x1b[1;34m[*] Checking Python version\x1b[0m"
python_version=($(python3 -c 'import sys; print("{} {}".format(sys.version_info.major, sys.version_info.minor))'))

if [ "${python_version[0]}" -eq 3 ] && [ "${python_version[1]}" -lt 8 ]; then
  if ! command -v python3.8 &> /dev/null; then
    if [ $OS_NAME == "UBUNTU" ]; then
      echo -e "\x1b[1;34m[*] Python3 version less than 3.8, installing 3.8\x1b[0m"
      sudo apt-get install -y python3.8 python3.8-dev python3-pip
    elif [ $OS_NAME == "DEBIAN" ]; then
      echo -e "\x1b[1;34m[*] Python3 version less than 3.8, installing 3.8\x1b[0m"
      echo -n -e "\x1b[1;33m[>] Python 3.8 must be built from source on Debian. This might take a bit, do you want to continue (y/N)? \x1b[0m"
      read answer
      if [ "$answer" != "${answer#[Yy]}" ] ;then
        sudo apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev
        curl -O https://www.python.org/ftp/python/3.8.10/Python-3.8.10.tar.xz
        tar -xf Python-3.8.10.tar.xz
        cd Python-3.8.10
        ./configure --enable-optimizations
        make -j$(nproc)
        sudo make altinstall
        cd ..
        rm -rf Python-3.8.10
        rm Python-3.8.10.tar.xz
      else
        echo -e "Abort"
        exit
      fi
    fi
  fi
  python3.8 -m pip install poetry
else
  python3 -m pip install poetry
fi

echo -e "\x1b[1;34m[*] Installing Poetry\x1b[0m"
poetry install

echo -e '\x1b[1;34m[*] Install Complete!\x1b[0m'
echo -e '\x1b[1;34m[*] poetry run python empire.py server\x1b[0m'
echo -e '\x1b[1;34m[*] poetry run python empire.py client\x1b[0m'

if $SOURCE_MESSAGE; then
  echo -e '\x1b[1;34m[*] source ~/.bashrc to enable nim \x1b[0m'
fi
