#################
#   VARIABLES   #
#################

# Set your own IP here
# Use something like http://whatismyip.host
# Because this is a CIDR range, also add "/32"
export MY_IP="0.0.0.0/0"
export ADMIN_USERNAME="azuresecurityuser"

# Settings
export LOCATION="westeurope"

# Naming
export VNET_NAME="Pentesting-VNet"
export NSG_NAME="Pentesting-NSG"
export ROUTE_TABLE_NAME="Pentesting-RouteTable"
export RESOURCE_GROUP_NAME="Pentesting-ResourceGroup"
export VM_NAME="Pentesting-VM"

# Networking
export SUBNET_NAME_A="PentestingMachines-Subnet1a"
export SUBNET_NAME_B="PentestingMachines-Subnet1b"
export SUBNET_NAME_C="PentestingMachines-Subnet1c"
export NETWORK_RANGE="192.168.100.0/24"
export RANGE_SUBNET_A="192.168.100.0/27"
export RANGE_SUBNET_B="192.168.100.32/27"
export RANGE_SUBNET_C="192.168.100.64/27"

#################
#   NETWORKING  #
#################

#https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-cli

az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

az network vnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VNET_NAME \
  --address-prefix $NETWORK_RANGE

az network route-table create \
  --name $ROUTE_TABLE_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION

az network nsg create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $NSG_NAME

az network nsg rule create \
  --resource-group $RESOURCE_GROUP_NAME \
  --nsg-name $NSG_NAME \
  --name Allow-SSH-My-Ip \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 100 \
  --source-address-prefix Internet \
  --source-port-range $MY_IP \
  --destination-address-prefix "*" \
  --destination-port-range 22

az network vnet subnet create \
  --address-prefixes $RANGE_SUBNET_A \
  --name $SUBNET_NAME_A \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --network-security-group $NSG_NAME \
  --route-table $ROUTE_TABLE_NAME

az network vnet subnet create \
  --address-prefixes $RANGE_SUBNET_B \
  --name $SUBNET_NAME_B \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --network-security-group $NSG_NAME \
  --route-table $ROUTE_TABLE_NAME

az network vnet subnet create \
  --address-prefixes $RANGE_SUBNET_C \
  --name $SUBNET_NAME_C \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --network-security-group $NSG_NAME \
  --route-table $ROUTE_TABLE_NAME

#################
#    COMPUTE    #
#################

az vm create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VM_NAME \
  --image UbuntuLTS \
  --admin-username $ADMIN_USERNAME \
  --generate-ssh-keys \
  --location $LOCATION \
  --nsg $NSG_NAME \
  --data-disk-sizes-gb 10 \
  --size Standard_B1ms