#!/bin/bash

echo 'debut restartapache' | sudo tee /var/log/deploy/restartapache.log

sudo ln -s /var/www/html/doc_back_symfony doc_back_symfony_ln
cd doc_back_symfony_ln

#=============================================== mysql dor symfony =====================================================

export user=$(grep '^DATABASE_URL=' .env | cut -d'/' -f3 | sed 's/\@/\:/' | cut -d':' -f1)
export password=$(grep '^DATABASE_URL=' .env | cut -d'/' -f3 | sed 's/\@/\:/' | cut -d':' -f2)
export host=$(grep '^DATABASE_URL=' .env | cut -d'/' -f3 | sed 's/\@/\:/' | cut -d':' -f3)
export port=$(grep '^DATABASE_URL=' .env | cut -d'/' -f3 | sed 's/\@/\:/' | cut -d':' -f4)

sudo mysql -sfu root <<EOS
-- create user with password
CREATE USER '${user}'@'${host}' IDENTIFIED BY '$password';
GRANT ALL PRIVILEGES ON *.* TO '${user}'@'${host}';
-- make changes immediately",
FLUSH PRIVILEGES;
EOS

#=============================================== symfony =====================================================

pwd | sudo tee -a /var/log/deploy/restartapache.log

curl -sS https://getcomposer.org/installer | sudo php | sudo tee -a /var/log/deploy/restartapache.log

sudo mv -f composer.phar /usr/local/bin/composer | sudo tee -a /var/log/deploy/restartapache.log
sudo ln -sf /usr/local/bin/composer /usr/bin/composer | sudo tee -a /var/log/deploy/restartapache.log

sudo composer install --no-dev --optimize-autoloader | sudo tee -a /var/log/deploy/restartapache.log

sudo php bin/console doctrine:database:create | sudo tee -a /var/log/deploy/restartapache.log
sudo php bin/console doctrine:migration:migrate --quiet | sudo tee -a /var/log/deploy/restartapache.log

#export APP_ENV=prod 
#export APP_DEBUG=0 

#=============================================== cle pour jwt =====================================================

passphrase=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32 | xargs)

sudo sed -i "s/^JWT_PASSPHRASE=.*$/JWT_PASSPHRASE=$passphrase/g" '.env'

sudo mkdir -p config/jwt/ | sudo tee -a /var/log/deploy/restartapache.log

echo "creation de la clé privée" | sudo tee -a /var/log/deploy/restartapache.log
sudo openssl genpkey -out config/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -pass pass:$passphrase

echo "creation de la clé public" | sudo tee -a /var/log/deploy/restartapache.log
sudo openssl pkey -in config/jwt/private.pem -out config/jwt/public.pem -pubout -passin pass:$passphrase

#echo "change mod tout le site" | sudo tee -a /var/log/deploy/restartapache.log
#chown -R www-data:www-data ../ | sudo tee -a /var/log/deploy/restartapache.log

#sudo a2enmod rewrite
#sudo a2enmod ssl 

cd $(pwd)/scripts

sudo unlink 'doc_back_symfony_ln'

#=============================================== apache =====================================================

cat /etc/httpd/conf/httpd.conf | grep -v "httpd-vhosts-9443.conf" | sudo tee /etc/httpd/conf/httpd.conf > /dev/null
echo "Include /var/www/html/doc_back_symfony/scripts/httpd-vhosts-9443.conf" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null

cat /etc/httpd/conf/httpd.conf | grep -v "Listen 9443" | sudo tee /etc/httpd/conf/httpd.conf > /dev/null
echo "Listen 9443" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null

sudo service httpd start
