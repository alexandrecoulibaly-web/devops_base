#!/usr/bin/env bash
 
set -e
export AWS_DEFAULT_REGION="us-east-2"
 
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
user_data=$(cat "$SCRIPT_DIR/user-data.sh")
 
echo "--- Création du groupe de sécurité ---"
# Attention: Si le groupe existe déjà avec une config port 80, il faut soit le supprimer avant, 
# soit changer le nom ici (ex: "sample-app-v2") pour éviter les conflits.
GROUP_NAME="sample-app-v2"
 
security_group_id=$(aws ec2 create-security-group \
  --group-name "$GROUP_NAME" \
  --description "Allow HTTP traffic on port 8080" \
  --output text \
  --query GroupId  | tr -d '\r')
 
echo "ID du Groupe de Sécurité : $security_group_id"
echo "DEBUG: security_group_id=[$security_group_id]"


# IMPORTANT : On ouvre le port 8080 (standard pour Node.js) au lieu du 80
aws ec2 authorize-security-group-ingress \
  --group-id $security_group_id \
  --protocol tcp \
  --port 8080 \
  --cidr "0.0.0.0/0" > /dev/null
 
 
echo "--- Lancement de l'instance EC2 ---"
instance_id=$(aws ec2 run-instances \
  --image-id "ami-0900fe555666598a2" \
  --instance-type "t3.micro" \
  --security-group-ids "$security_group_id" \
  --user-data "$user_data" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=sample-app}]' \
  --output text \
  --query Instances[0].InstanceId  | tr -d '\r')
 
echo "Instance ID = $instance_id"
echo "Attente du démarrage de l'instance..."
 
aws ec2 wait instance-running --instance-ids "$instance_id"
 
public_ip=$(aws ec2 describe-instances \
  --instance-ids "$instance_id" \
  --output text \
  --query 'Reservations[*].Instances[*].PublicIpAddress')
 
echo "-------------------------------------------"
echo "Déploiement terminé !"
echo "Public IP         : $public_ip"
echo "Accédez à l'app   : http://$public_ip:8080"  # Notez le :8080
echo "-------------------------------------------"
