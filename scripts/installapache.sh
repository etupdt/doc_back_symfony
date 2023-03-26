#!/bin/bash
echo 'exec installapache.sh'

sudo apt update
sudo apt install apache2

##### sudo apt install php8.1-cli
sudo apt install libapache2-mod-php

cat /etc/apache2/sites-available/000-default.conf | grep -v "9443.conf" | sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null
echo "Include ./scripts/000-default-9443.conf" | sudo tee -a /etc/apache2/sites-available/000-default.conf > /dev/null

export APP_ENV=prod 
export APP_DEBUG=0 

#sudo chmod 755 /var/www/html/doc-back-symfony/composer.phar
./composer.phar install --no-dev --optimize-autoloader

php bin/console doctrine:migration:migrate

sudo a2enmod rewrite
sudo a2enmod ssl 

sudo service apache2 start

#sudo yum update -y
#sudo yum install -y httpd
#sudo systemctl start httpd

