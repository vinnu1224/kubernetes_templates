#!/bin/bash
PATH=/usr/bin:/sbin:; export PATH

T=$(date +%Y%m%d-%H%M%S)

L=/root/AppZ-Images/appz/log/token-$(date +%Y%m%d-%H%M%S).log

echo "$T> creating a client token" >> $L

export VAULT_SKIP_VERIFY=true

cd /root/AppZ-Images

echo "$T> creating kubeadm token" >> $L
token_output=$(kubeadm token create)
echo "token output is:" >> $L
echo "$token_output" >> $L

echo "$T> saving kubeadm token to vault " >> $L
/root/vault write secret/K8sToken token=$token_output

echo "$T> kubeadm token is " >> $L
k8s_token=$(/root/vault read secret/K8sToken)
echo "$k8s_token" >> $L

Token=$(/root/vault write -field=token auth/approle/login role_id=f3ed527d-5c8d-320a-3f8e-37759059857f secret_id=fa7052d5-a6df-a6d3-5b6c-aa29028d81e4)
echo "client Token is:" >> $L
echo "$Token" >> $L



echo "$T> exporting token" >> $L
echo "export VAULT_TOKEN=$Token" >> ~/.bashrc

echo "$T> Login to the token" >> $L
/root/vault login $Token



