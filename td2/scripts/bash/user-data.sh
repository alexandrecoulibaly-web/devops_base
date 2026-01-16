#!/usr/bin/env bash
 
# 1. On utilise yum car l'AMI est une Amazon Linux
sudo yum update -y
 
# 2. Installation de Node.js (Version compatible Amazon Linux 2023 ou 2)
sudo yum install -y nodejs
 
# 3. Téléchargement du fichier BRUT (Raw)
# Notez le début du lien : raw.githubusercontent.com
curl -o /home/ec2-user/app.js https://raw.githubusercontent.com/BTajini/devops-base/main/td1/sample-app/app.js
 
# 4. Lancement de l'application
# On utilise le chemin complet /home/ec2-user/
# On redirige les logs pour pouvoir debugger si besoin
nohup node /home/ec2-user/app.js > /home/ec2-user/app.log 2>&1 &
 
echo "L'application Node.js a été lancée en arrière-plan."