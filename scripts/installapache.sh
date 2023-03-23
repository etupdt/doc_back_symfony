#!/bin/bash
echo 'exec installapache.sh'

sudo apt update
sudo apt install apache2

##### sudo apt install php8.1-cli
sudo apt install libapache2-mod-php

cat /etc/apache2/sites-available/000-default.conf | grep -v "9443.conf" | sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null
echo "Include /var/www/html/doc-back-symfony/scripts/000-default-9443.conf" | sudo tee -a /etc/apache2/sites-available/000-default.conf > /dev/null

sudo apt install composer

wget https://get.symfony.com/cli/installer -O - | bash
export APP_ENV=prod 
export APP_DEBUG=0 
composer install --no-dev --optimize-autoloader | sudo tee /tmp/log > /dev/null

php /var/www/html/doc-back-symfony/bin/console doctrine:migration:migrate

sudo service apache2 start

#sudo yum update -y
#sudo yum install -y httpd
#sudo systemctl start httpd
