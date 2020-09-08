#!/bin/bash 

# Start terraform apply
cd terraform
terraform apply -input=false -auto-approve
echo "Criando servidor na AWS"
terraform output > ../dnsPublicServer.json
dns=$(cat ../dnsPublicServer.json | sed -n '2,2p' | tr -d \", | awk '{print$1}')
sleep 15

# Conectando ao servidor
echo "Conectando SSH ao servidor"
ssh -o StrictHostKeyChecking=no ubuntu@$dns

# Destruindo o servidor criado
echo "O servidor será destruido em 60 segundos..."
sleep 60
echo "Destruindo o servidor"
terraform destroy -input=false -auto-approve