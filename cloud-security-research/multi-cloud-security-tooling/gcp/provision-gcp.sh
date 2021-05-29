#################
#   VARIABLES   #
#################

# Set your own IP here
# Use something like http://whatismyip.host
# Because this is a CIDR range, also add "/32"
export MY_IP="0.0.0.0/0"

# Settings
export PROJECT_ID=$(gcloud config get-value project)
export INSTANCE_FAMILY="f1-micro"
export REGION="europe-north1"
export ZONE="europe-north1-b"

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Naming
export INSTANCE_NAME="pentestinginstance"
export NETWORK_NAME="PentestingMachines-VPC"
export SUBNET_NAME_A="PentestingMachines-Subnet1a"
export SUBNET_NAME_B="PentestingMachines-Subnet1b"
export SUBNET_NAME_C="PentestingMachines-Subnet1c"
export FIREWALL_RULE_NAME="allow-inbound-tcp-80"

# Networking
export RANGE_SUBNET_A="192.168.100.0/27"
export RANGE_SUBNET_B="192.168.100.32/27"
export RANGE_SUBNET_C="192.168.100.64/27"

#################
#   NETWORKING  #
#################

# Create network
gcloud compute networks create $NETWORK_NAME \
  --subnet-mode=custom

# Create subnet A
gcloud compute networks subnets create $SUBNET_NAME_A \
  --network $NETWORK_NAME \
  --region $REGION \
  --range $RANGE_SUBNET_A

# Create subnet B
gcloud compute networks subnets create $SUBNET_NAME_B \
  --network $NETWORK_NAME \
  --region $REGION \
  --range $RANGE_SUBNET_B

# Create subnet C
gcloud compute networks subnets create $SUBNET_NAME_C \
  --network $NETWORK_NAME \
  --region $REGION \
  --range $RANGE_SUBNET_C

# Create firewall rule opening port 80 over TCP
gcloud compute firewall-rules create $FIREWALL_RULE_NAME \
  --network $NETWORK_NAME \
  --allow ssh:22 \
  --source-ranges $MY_IP \
	--priority 100 \
  --target-tags $FIREWALL_RULE_NAME

#################
#    COMPUTE    #
#################

gcloud beta compute instances create $INSTANCE_NAME \
  --zone $ZONE \
  --machine-type $INSTANCE_FAMILY \
  --subnet $SUBNET_NAME_A \
  --network-tier PREMIUM \
  --tags $FIREWALL_RULE_NAME \
  --image debian-9-stretch-v20200210 \
  --image-project debian-cloud \
  --labels asdf=something