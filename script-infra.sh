#! /bin/bash

# Load balance VMs across availability zones

# Variable block

let "randomIdentifier=$RANDOM*$RANDOM"

location=francecentral
vNet="msdocs-vnet-lb-myvnet$randomIdentifier"
subnet="msdocs-subnet-lb-subnet$randomIdentifier"
loadBalancerPublicIp="msdocs-public-ip-lb-$randomIdentifier"
ipSku=Standard
zone="1 2 3"
loadBalancer="msdocs-load-balancer-loadbalancer$randomIdentifier"
frontEndIp="msdocs-front-end-ip-lb-$randomIdentifier"
backEndPool="msdocs-back-end-pool-lb-$randomIdentifier"
probe80="msdocs-port80-health-probe-lb-$randomIdentifier"
loadBalancerRuleWeb="msdocs-load-balancer-rule-port80-$randomIdentifier"
loadBalancerRuleSSH="msdocs-load-balancer-rule-port22-$randomIdentifier"
networkSecurityGroup="msdocs-network-security-group-lb-networksecuritygroup"
networkSecurityGroupRuleSSH="msdocs-network-security-rule-port22-lb-$randomIdentifier"
networkSecurityGroupRuleWeb="msdocs-network-security-rule-port80-lb-$randomIdentifier"
nic="msdocs-nic-lb-$randomIdentifier"
image=UbuntuLTS
mdbserv=mdbserv$randomIdentifier

myNATgateway=msdocs-NAT-gateway$randomIdentifier
myNATgatewayIP=msdocs-NAT-gateway-IP$randomIdentifier


read -p "Entrez le nom de votre Groupe de Ressource: " GroupeDeRessource

read -p "Entrez le nom de votre VM: " vm

read -p "Entrez votre nom d'Utilisateur: " azureuser

read -p "Entrez votre nom d'utilsateur pour MariaDB: " UserMDB

# read -p "Entrez votre mot de passe pour MariaDB: "


# Create a resource group
echo "Creating $GroupeDeRessource in France Central"

az group create \
    --name $GroupeDeRessource \
    --location $location


# Create a virtual network and a subnet.
echo "Creating $vNet and $subnet"

az network vnet create \
    --resource-group $GroupeDeRessource \
    --name $vNet \
    --location $location \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name $subnet
    --subnet-prefixes 10.1.0.0/24

# Create a zonal Standard public IP address for load balancer.
echo "Creating $loadBalancerPublicIp"

az network public-ip create \
    --resource-group $GroupeDeRessource \
    --name $loadBalancerPublicIp \
    --sku $ipSku \
    --zone $zone

# Create an Azure Load Balancer.
echo "Creating $loadBalancer with $frontEndIP and $backEndPool"

az network lb create \
    --resource-group $GroupeDeRessource \
    --name $loadBalancer \
    --public-ip-address $loadBalancerPublicIp \
    --frontend-ip-name $frontEndIp \
    --backend-pool-name $backEndPool \
    --sku $ipSku

# Create an LB probe on port 80.
echo "Creating $probe80 in $loadBalancer"

az network lb probe create \
    --resource-group $GroupeDeRessource \
    --lb-name $loadBalancer \
    --name $probe80 \
    --protocol tcp \
    --port 80

# Create an LB rule for port 80.
echo "Creating $loadBalancerRuleWeb for $loadBalancer"

az network lb rule create \
    --resource-group $GroupeDeRessource \
    --lb-name $loadBalancer \
    --name $loadBalancerRuleWeb \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name $frontEndIp \
    --backend-pool-name $backEndPool \
    --probe-name $probe80
#    --disable-outbound-snat true \
#    --idle-timeout 15 \
#    --enable-tcp-reset true

# Create two NAT rules for port 22.
echo "Creating two NAT rules named $loadBalancerRuleSSH"

  for i in `seq 1 2`
  do
    az network lb inbound-nat-rule create \
    --resource-group $GroupeDeRessource \
    --lb-name $loadBalancer \
    --name $loadBalancerRuleSSH$i \
    --protocol tcp \
    --frontend-port 422$i \
    --backend-port 22 \
    --frontend-ip-name $frontEndIp
  done

# Create a network security group
echo "Creating $networkSecurityGroup"

az network nsg create \
    --resource-group $GroupeDeRessource \
    --name $networkSecurityGroup

# Create a network security group rule for port 22.
echo "Creating $networkSecurityGroupRuleSSH in $networkSecurityGroup for port 22"

az network nsg rule create \
    --resource-group $GroupeDeRessource \
    --nsg-name $networkSecurityGroup \
    --name $networkSecurityGroupRuleSSH \
    --protocol tcp \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 22 \
    --access allow \
    --priority 1000


# Create a network security group rule for port 80.
echo "Creating $networkSecurityGroupRuleWeb in $networkSecurityGroup for port 22"

az network nsg rule create \
    --resource-group $GroupeDeRessource \
    --nsg-name $networkSecurityGroup \
    --name $networkSecurityGroupRuleWeb \
    --protocol tcp \
    --direction inbound \
    --priority 1001 \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 80 \
    --access allow \
    --priority 2000

# Create two virtual network cards and associate with public IP address and NSG.
echo "Creating two NICs named $nic for $vNet and $subnet"

  for i in `seq 1 2`
  do
    az network nic create \
    --resource-group $GroupeDeRessource \
    --name $nic$i \
    --vnet-name $vNet \
    --subnet $subnet \
    --network-security-group $networkSecurityGroup \
    --lb-name $loadBalancer \
    --lb-address-pools $backEndPool \
    --lb-inbound-nat-rules $loadBalancerRuleSSH$i
  done

# Create two virtual machines, this creates SSH keys if not present.
echo "Creating two VMs named $vm with $nic using $image"


# read -p "Entrez le nombre de VM souhaité: " END
# for i in  $(seq 1 $END)

  for i in `seq 1 2` 
  do
    az vm create \
    --resource-group $GroupeDeRessource \
    --name $vm$i \
    --zone $i \
    --nics $nic$i \
    --image $image \
    --admin-username $azureuser \
    --generate-ssh-keys \
    --no-wait
  done

  for i in `seq 1 2`
  do
    az vm open-port \
    --port 80 \
    --resource-group $GroupeDeRessource \
    --name $vm$i
  done


# List the virtual machines

az vm list \
    --resource-group $GroupeDeRessource

# Test the load balancer


IpPublic=$(az network public-ip show \
    --resource-group $GroupeDeRessource \
    --name $loadBalancerPublicIp \
    --query ipAddress \
    --output tsv)

echo $IpPublic

# Create a NAT Gateway

az network public-ip create \
    --resource-group $GroupeDeRessource \
    --name $myNATgatewayIP \
    --sku Standard \
    --zone $zone

az network nat gateway create \
    --resource-group $GroupeDeRessource \
    --name $myNATgateway \
    --public-ip-addresses $myNATgatewayIP \
    --idle-timeout 10

az network vnet subnet update \
    --resource-group $GroupeDeRessource \
    --vnet-name $vNet \
    --name $subnet \
    --nat-gateway $myNATgateway

# Create a Maria DB server

az mariadb server create \
    --resource-group $GroupeDeRessource \
    --name $mdbserv \
    --ssl-enforcement Disabled \
    --public-network-access Disabled \
    --location francecentral \
    --admin-user $UserMDB \
    --admin-password PIcciNO69200!MaRaTEa? \
    --sku-name GP_Gen5_2 \
    --version 10.2

az mariadb server firewall-rule create \
    --resource-group $GroupeDeRessource \
    --server $mdbserv \
    --name AllowMyIP \
    --start-ip-address $IpPublic \
    --end-ip-address $IpPublic



az mariadb server show \
    --resource-group $GroupeDeRessource \
    --name $mdbserv

ssh -i .ssh/id_rsa $azureuser@$IpPublic -p 4221 
