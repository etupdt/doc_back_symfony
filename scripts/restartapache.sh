#!/bin/bash
echo 'exec restartapache.sh'

phph /var/www/html/doc-back-symfony/bin/console doctrine:migration:migrate

cat /etc/apache2/sites-available/000-default.conf | grep -v "9443.conf" | sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null
echo "Include /var/www/html/doc-back-symfony/scripts/000-default-9443.conf" | sudo tee -a /etc/apache2/sites-available/000-default.conf > /dev/null

sudo service apache2 restart
#sudo systemctl restart httpd
