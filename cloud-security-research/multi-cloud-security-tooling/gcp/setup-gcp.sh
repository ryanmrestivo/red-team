##########################
# Update your machine!
##########################

sudo apt -y update

##########################
# Install Python 3
# https://www.python.org
##########################

python3 --version

sudo apt -y install python3 python3-pip virtualenv

##########################
# Install jq
# https://stedolan.github.io/jq/
##########################

sudo apt -y install jq

##########################
# Install Docker
# https://docs.docker.com/install/linux/docker-ce/centos/
##########################

# Thanks to: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-debian-9
sudo apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt -y update
apt-cache policy docker-ce
sudo apt -y install docker-ce
sudo systemctl status docker


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