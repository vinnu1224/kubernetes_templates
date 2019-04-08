#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo "export VAULT_SKIP_VERIFY=true" >> ~/.bashrc
echo "export VAULT_ADDR=https://13.59.221.194:8200" >> ~/.bashrc
echo "export VAULT_TOKEN=8P8QBI6LdRT9VqLNcMaGyBvr" >> ~/.bashrc
source ~/.bashrc
token=$(/root/vault read secret/K8sToken | awk 'NR==4 {print $2}')
key=$(/root/vault read secret/SHAKEY | awk 'NR==4 {print $2}') 
kubeadm join --token $token 13.59.221.194:6443 --discovery-token-ca-cert-hash sha256:$key
