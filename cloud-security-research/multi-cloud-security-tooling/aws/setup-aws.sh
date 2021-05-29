##########################
# Update your machine!
##########################

sudo yum update

##########################
# Install Python 3
# https://www.python.org
##########################

# Verify if you already have Python 3
python3 --version

sudo yum install python3 python3-pip virtualenv

##########################
# Install jq
# https://stedolan.github.io/jq/
##########################

sudo yum install jq

##########################
# Install AWS CLI (version 2)
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
##########################

curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

##########################
# Install Awsume
# https://github.com/trek10inc/awsume
##########################

pip3 install awsume

##########################
# Install Docker
# https://docs.docker.com/install/linux/docker-ce/centos/
##########################

# Thanks to: https://gist.github.com/npearce/6f3c7826c7499587f00957fee62f8ee9#gistcomment-3119398
sudo yum install polkit
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user

sudo chkconfig docker on
sudo yum install -y git
sudo reboot

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