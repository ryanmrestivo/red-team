##########################
# Update your machine!
##########################

sudo softwareupdate -i -a

# If you use Brew
# brew update
# brew upgrade
# brew cleanup

# If you use NPM
# npm install npm -g
# npm update -g

##########################
# Install brew
# https://brew.sh
##########################

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

##########################
# Install Python 3
# https://www.python.org
##########################

# Verify if you already have Python 3
python3 --version

brew install python3 python3-pip virtualenv

##########################
# Install jq
# https://stedolan.github.io/jq/
##########################

brew install jq

curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-macos.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

##########################
# Install Awsume
# https://github.com/trek10inc/awsume
##########################

pip3 install awsume

##########################
# Install Docker
# https://hub.docker.com/editions/community/docker-ce-desktop-mac/
##########################

echo "\nInstall Docker Desktop for Mac from:\nhttps://hub.docker.com/editions/community/docker-ce-desktop-mac/\n"

##########################
# Install S3Scanner
# https://github.com/sa7mon/S3Scanner
##########################

git clone https://github.com/sa7mon/S3Scanner.git
cd S3Scanner
pip3 install -r requirements.txt
cd ..

##########################
# Install pacu
# https://github.com/RhinoSecurityLabs/pacu
##########################

git clone https://github.com/RhinoSecurityLabs/pacu.git
cd pacu
bash install.sh
cd ..

##########################
# Install LambdaGuard
# https://github.com/Skyscanner/LambdaGuard
##########################

git clone https://github.com/Skyscanner/lambdaguard.git
cd lambdaguard
sudo make install
cd ..

##########################
# Install wafw00f
# https://github.com/EnableSecurity/wafw00f
##########################

git clone https://github.com/EnableSecurity/wafw00f.git
cd wafw00f
python setup.py install
cd ..

##########################
# Install Nikto
# https://github.com/sullo/nikto
##########################

git clone https://github.com/sullo/nikto.git

##########################
# Install Prowler
# https://github.com/toniblyx/prowler
##########################

pip3 install awscli ansi2html detect-secrets
git clone https://github.com/toniblyx/prowler

##########################
# Install Metasploit
# https://www.metasploit.com
##########################

curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
  chmod 755 msfinstall && \
  ./msfinstall

##########################
# Install ScoutSuite
# https://github.com/nccgroup/ScoutSuite/
##########################

pip3 install virtualenv
git clone https://github.com/nccgroup/ScoutSuite
cd ScoutSuite
virtualenv -p python3 venv
source venv/bin/activate
pip3 install -r requirements.txt
python scout.py --help
cd ..

##########################
# Install Photon
# https://github.com/s0md3v/Photon
##########################

git clone https://github.com/s0md3v/Photon.git