
#!/bin/bash
echo 'exec installapache.sh'

apt update
apt install apache2

apt install locate

apt install php8.1-cli
apt install libapache2-mod-php

cat /etc/apache2/sites-available/000-default.conf | grep -v "9443.conf" | tee /etc/apache2/sites-available/000-default.conf > /dev/null
echo "Include /var/www/html/doc_back_symfony/scripts/000-default-9443.conf" | tee -a /etc/apache2/sites-available/000-default.conf > /dev/null

cat /etc/apache2/ports.conf | grep -v "9443" | tee /etc/apache2/ports.conf > /dev/null
echo "Listen 9443" | tee -a /etc/apache2/ports.conf > /dev/null

#export APP_ENV=prod 
#export APP_DEBUG=0 

./composer.phar install --${APP_ENV} --optimize-autoloader

php bin/console doctrine:migration:migrate

apt install pwgen -y

passphrase=$(pwgen -sBv 30 | tail -1)

sed -i "s/^JWT_PASSPHRASE=.*$/JWT_PASSPHRASE=$passphrase/g" '.env'

mkdir config/jwt/

echo "creation de la clé privée"
openssl genpkey -out config/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -pass pass:$passphrase
cat config/jwt/private.pem

echo "creation de la clé public"
openssl pkey -in config/jwt/private.pem -out config/jwt/public.pem -pubout -passin pass:$passphrase
cat config/jwt/public.pem

echo "change mod tout le site"
chown -R www-data:www-data ../

unlink /var/log/apache2/access.log
unlink /var/log/apache2/error.log
unlink /var/log/apache2/other_vhosts_access.log

a2enmod rewrite
a2enmod ssl 

service apache2 start

tail -f /dev/null
