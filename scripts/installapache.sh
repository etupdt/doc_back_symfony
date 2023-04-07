#!/bin/bash


#!/bin/bash
echo 'exec installapache.sh' | sudo tee /var/log/deploy/installapache.log

sudo apt update | sudo tee -a /var/log/deploy/installapache.log
sudo apt install apache2 | tee -a /var/log/deploy/installapache.log

sudo apt install locate | sudo tee -a /var/log/deploy/installapache.log

sudo apt install php8.1-cli | sudo tee -a /var/log/deploy/installapache.log
sudo apt install libapache2-mod-php | sudo tee -a /var/log/deploy/installapache.log

cat /etc/apache2/sites-available/000-default.conf | grep -v "9443.conf" | sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null
echo "Include /var/www/html/doc_back_symfony/scripts/000-default-9443.conf" | sudo tee -a /etc/apache2/sites-available/000-default.conf > /dev/null

cat /etc/apache2/ports.conf | grep -v "9443" | sudo tee /etc/apache2/ports.conf > /dev/null
echo "Listen 9443" | sudo tee -a /etc/apache2/ports.conf > /dev/null

#export APP_ENV=prod 
#export APP_DEBUG=0 

#sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport .efs.eu-west-3a.amazonaws.com:/ ~/doc_back_symfony 

./composer.phar install --no-dev --optimize-autoloader | sudo tee -a /var/log/deploy/installapache.log

php bin/console doctrine:migration:migrate

sudo apt install pwgen -y | sudo tee -a /var/log/deploy/installapache.log

passphrase=$(pwgen -sBv 30 | tail -1)

sed -i "s/^JWT_PASSPHRASE=.*$/JWT_PASSPHRASE=$passphrase/g" '.env'

mkdir config/jwt/ | sudo tee -a /var/log/deploy/installapache.log

echo "creation de la clé privée"
openssl genpkey -out config/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -pass pass:$passphrase
cat config/jwt/private.pem

echo "creation de la clé public"
openssl pkey -in config/jwt/private.pem -out config/jwt/public.pem -pubout -passin pass:$passphrase
cat config/jwt/public.pem

echo "change mod tout le site"
chown -R www-data:www-data ../

sudo unlink /var/log/apache2/access.log
sudo unlink /var/log/apache2/error.log
sudo unlink /var/log/apache2/other_vhosts_access.log

sudo a2enmod rewrite
sudo a2enmod ssl 

sudo service apache2 start
