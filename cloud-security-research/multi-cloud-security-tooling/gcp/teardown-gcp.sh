#################
#    DELETE     #
#################

gcloud compute firewall-rules delete $FIREWALL_RULE_NAME -q
gcloud compute networks subnets delete $SUBNET_NAME_A -q
gcloud compute networks subnets delete $SUBNET_NAME_B -q
gcloud compute networks subnets delete $SUBNET_NAME_C -q
gcloud compute networks delete $NETWORK_NAME -q