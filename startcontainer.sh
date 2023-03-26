
#!/bin/bash
echo 'exec installapache.sh'

apt update
apt install apache2

##### sudo apt install php8.1-cli
apt install libapache2-mod-php

cat /etc/apache2/sites-available/000-default.conf | grep -v "9443.conf" | tee /etc/apache2/sites-available/000-default.conf > /dev/null
echo "Include /var/www/html/doc_back_symfony/scripts/000-default-9443.conf" | tee -a /etc/apache2/sites-available/000-default.conf > /dev/null

export APP_ENV=prod 
export APP_DEBUG=0 

#sudo chmod 755 /var/www/html/doc-back-symfony/composer.phar
./composer.phar install --no-dev --optimize-autoloader

php bin/console doctrine:migration:migrate

a2enmod rewrite
a2enmod ssl 

service apache2 start

#sudo yum update -y
#sudo yum install -y httpd
#sudo systemctl start httpd

tail -f /dev/null
