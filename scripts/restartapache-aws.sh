#!/bin/bash

log=/var/log/deploy/restartapache.log

echo 'debut restartapache' | sudo tee $log

sudo ln -s /var/www/html/doc_back_symfony doc_back_symfony_ln
cd doc_back_symfony_ln

#=============================================== mysql for symfony =====================================================
echo 'mysql for symfony' | sudo tee -a $log
ls -lrta | sudo tee -a $log

export user=$(grep '^DATABASE_URL=' '.env' | cut -d'/' -f3 | sed 's/\@/\:/' | cut -d':' -f1)
echo "user : $user" |& sudo tee -a $log
export password=$(grep '^DATABASE_URL=' '.env' | cut -d'/' -f3 | sed 's/\@/\:/' | cut -d':' -f2)
echo "password : $password" |& sudo tee -a $log
export host=$(grep '^DATABASE_URL=' '.env' | cut -d'/' -f3 | sed 's/\@/\:/' | cut -d':' -f3)
echo "host : $host" |& sudo tee -a $log
export port=$(grep '^DATABASE_URL=' '.env' | cut -d'/' -f3 | sed 's/\@/\:/' | cut -d':' -f4)
echo "port : $port" |& sudo tee -a $log

sudo mysql -sfu root |& sudo tee -a $log <<EOS
-- create user with password
CREATE USER '${user}'@'${host}' IDENTIFIED BY '$password';
GRANT ALL PRIVILEGES ON *.logindoc TO '${user}'@'${host}';
-- make changes immediately",
FLUSH PRIVILEGES;
EOS

#=============================================== symfony =====================================================
echo 'symfony' | sudo tee -a $log

pwd | sudo tee -a $log

curl -sS https://getcomposer.org/installer | sudo php |& sudo tee -a $log

sudo mv -f composer.phar /usr/local/bin/composer |& sudo tee -a $log
sudo ln -sf /usr/local/bin/composer /usr/bin/composer |& sudo tee -a $log

sudo composer install --no-dev --optimize-autoloader |& sudo tee -a $log

sudo php bin/console doctrine:database:create |& sudo tee -a $log
sudo php bin/console doctrine:migration:migrate --quiet |& sudo tee -a $log

#export APP_ENV=prod 
#export APP_DEBUG=0 

#=============================================== certificates =====================================================

sudo mkdir -p /etc/httpd/ssl
sudo cp config/ssl/studi-cacert.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
sudo cp config/ssl/studi-public.crt /etc/httpd/ssl

#=============================================== cle pour jwt =====================================================
echo 'jwt' | sudo tee -a $log

passphrase=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32 | xargs)

sudo sed -i "s/^JWT_PASSPHRASE=.*$/JWT_PASSPHRASE=$passphrase/g" '.env'

sudo mkdir -p config/jwt/ | sudo tee -a $log

echo "creation de la clé privée" | sudo tee -a $log
sudo openssl genpkey -out config/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -pass pass:$passphrase

echo "creation de la clé public" | sudo tee -a $log
sudo openssl pkey -in config/jwt/private.pem -out config/jwt/public.pem -pubout -passin pass:$passphrase

#echo "change mod tout le site" | sudo tee -a /var/log/deploy/restartapache.log
#chown -R www-data:www-data ../ | sudo tee -a /var/log/deploy/restartapache.log

#sudo a2enmod rewrite
#sudo a2enmod ssl 

cd $(pwd)/scripts

sudo unlink 'doc_back_symfony_ln'

#=============================================== apache =====================================================
echo 'apache' | sudo tee -a $log

cat /etc/httpd/conf/httpd.conf | grep -v "httpd-vhosts-9443.conf" | sudo tee /etc/httpd/conf/httpd.conf > /dev/null
echo "Include /var/www/html/doc_back_symfony/scripts/httpd-vhosts-9443.conf" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null

cat /etc/httpd/conf/httpd.conf | grep -v "Listen 9443" | sudo tee /etc/httpd/conf/httpd.conf > /dev/null
echo "Listen 9443" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null

sudo service httpd stop |& tee -a $log
sudo service httpd start |& tee -a $log
