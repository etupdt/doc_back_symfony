#!/bin/bash
echo 'exec restartapache.sh'

cat /etc/apache2/sites-available/000-default.conf | grep -v "9443.conf" > /etc/apache2/sites-available/000-default.conf
echo "Include /var/www/html/doc-back-symfony/scripts/000-default-9443.conf" >> /etc/apache2/sites-available/000-default.conf

sudo service apache2 restart
#sudo systemctl restart httpd
