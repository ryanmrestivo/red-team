#################
#   VARIABLES   #
#################

# Set your own IP here
# Use something like http://whatismyip.host
# Because this is a CIDR range, also add "/32"
export MY_IP="0.0.0.0/0"

# AMI ID for:
# (region) eu-north-1
# (machine) amzn2-ami-hvm-2.0.20200207.1-x86_64-ebs
# Reference for finding an AMI ID: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
export AMI_ID="ami-0a134eda5b9c5fbb2"

# Networking
export NETWORK_RANGE="192.168.100.0/24"
export RANGE_SUBNET_A="192.168.100.0/27"
export RANGE_SUBNET_B="192.168.100.32/27"
export RANGE_SUBNET_C="192.168.100.64/27"

#################
#   NETWORKING  #
#################

aws ec2 create-vpc --cidr-block $NETWORK_RANGE

# Use ID from above and set it below before exporting it. Example ID: vpc-2f09a348
export VPC_ID=""

aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $RANGE_SUBNET_A
# Use ID from above and set it below before exporting it. Example ID: subnet-b46032ec
export SUBNET_1_ID=""

aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $RANGE_SUBNET_B
# Use ID from above and set it below before exporting it. Example ID: subnet-b46032ec
export SUBNET_2_ID=""

aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $RANGE_SUBNET_C
# Use ID from above and set it below before exporting it. Example ID: subnet-b46032ec
export SUBNET_3_ID=""

aws ec2 create-internet-gateway

# Use ID from above and set it below before exporting it. Example ID: igw-1ff7a07b
export IGW_ID=""

# Using the ID from the previous step, attach the Internet gateway to your VPC.
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID

aws ec2 create-route-table --vpc-id $VPC_ID

# Use IGW ID from above
aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block $MY_IP \
  --gateway-id $IGW_ID

# Use ID from above and set it below before exporting it. Example ID: rtb-c1c8faa6
export ROUTE_TABLE_ID=""

aws ec2 describe-route-tables --route-table-id $ROUTE_TABLE_ID

aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[*].{ID:SubnetId,CIDR:CidrBlock}'

# Use ID from above and set it below before exporting it. Example ID: subnet-b46032ec
export SUBNET_ID=""

# associate with public subnet (?)
aws ec2 associate-route-table \
  --subnet-id $SUBNET_ID \
  --route-table-id $ROUTE_TABLE_ID

#################
#    COMPUTE    #
#################

aws ec2 create-key-pair \
  --key-name MyKeyPair \
  --query 'KeyMaterial' \
  --output text > MyKeyPair.pem

chmod 400 MyKeyPair.pem

aws ec2 create-security-group \
  --group-name SSHAccess \
  --description "Security group for SSH access" \
  --vpc-id $VPC_ID

# Use ID from above and set it below before exporting it. Example ID: sg-e1fb8c9a
export SECURITY_GROUP_ID=""

aws ec2 authorize-security-group-ingress
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 22 \
  --cidr $MY_IP

aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type t3.micro \
  --key-name MyKeyPair \
  --security-group-ids $SECURITY_GROUP_ID \
  --subnet-id $SUBNET_ID
