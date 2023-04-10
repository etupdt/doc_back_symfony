#!/bin/bash

cd /var/www/html/doc_back_symfony | sudo tee -a /var/log/deploy/restartapache.log
pwd | sudo tee -a /var/log/deploy/restartapache.log

curl -sS https://getcomposer.org/installer | sudo php | sudo tee -a /var/log/deploy/restartapache.log
mv -f composer.phar /usr/local/bin/composer | sudo tee -a /var/log/deploy/restartapache.log
ln -sf /usr/local/bin/composer /usr/bin/composer | sudo tee -a /var/log/deploy/restartapache.log

composer install --no-dev --optimize-autoloader | sudo tee -a /var/log/deploy/restartapache.log

php bin/console doctrine:database:create | sudo tee -a /var/log/deploy/restartapache.log
php bin/console doctrine:migration:migrate --quiet | sudo tee -a /var/log/deploy/restartapache.log
