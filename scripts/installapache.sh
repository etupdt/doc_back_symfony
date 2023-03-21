#!/bin/bash
echo 'exec installapache.sh'

sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
