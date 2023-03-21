#!/bin/bash
echo 'exec installapache.sh'

sudo apt update
sudo apt install apache2
sudo service apache2 start
#sudo yum update -y
#sudo yum install -y httpd
#sudo systemctl start httpd
