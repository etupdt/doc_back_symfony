#!/bin/bash

sudo mkdir -p /var/log/deploy

echo 'debut install mariadb' | sudo tee /var/log/deploy/restartapache.log

sudo curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --os-type=rhel --os-version=7 --mariadb-server-version=10.6
sudo yum install MariaDB-server MariaDB-client -y
sudo systemctl enable --now mariadb

sudo mysql -sfu root <<EOS
-- set root password
UPDATE mysql.user SET Password=PASSWORD('password') WHERE User='root';
-- delete anonymous users
DELETE FROM mysql.user WHERE User='';
-- delete remote root capabilities
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
-- drop database 'test'
DROP DATABASE IF EXISTS test;
-- also make sure there are lingering permissions to it
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
-- make changes immediately
FLUSH PRIVILEGES;
EOS

echo 'debut restartapache' | sudo tee /var/log/deploy/restartapache.log

sudo yum update | sudo tee -a /var/log/deploy/restartapache.log
sudo yum install httpd -y | sudo tee -a /var/log/deploy/restartapache.log

#sudo yum install locate | sudo tee -a /var/log/deploy/restartapache.log

sudo amazon-linux-extras install php8.2 -y | sudo tee -a /var/log/deploy/restartapache.log
sudo yum install php-xml -y | sudo tee -a /var/log/deploy/restartapache.log
#sudo yum install libapache2-mod-php | sudo tee -a /var/log/deploy/restartapache.log

cat /etc/httpd/conf/httpd.conf | grep -v "httpd-vhosts-9443.conf" | sudo tee /var/log/deploy/restartapache.log > /dev/null
echo "Include /var/www/html/doc_back_symfony/scripts/httpd-vhosts-9443.conf" | sudo tee -a /var/log/deploy/restartapache.log > /dev/null

cat /etc/httpd/conf/httpd.conf | grep -v "Listen 9443" | sudo tee /var/log/deploy/restartapache.log > /dev/null
echo "Listen 9443" | sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null

#export APP_ENV=prod 
#export APP_DEBUG=0 

#sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport .efs.eu-west-3a.amazonaws.com:/ ~/doc_back_symfony 
sudo curl -sS https://getcomposer.org/installer | sudo php | sudo tee -a /var/log/deploy/restartapache.log
sudo mv -f composer.phar /usr/local/bin/composer | sudo tee -a /var/log/deploy/restartapache.log
sudo ln -sf /usr/local/bin/composer /usr/bin/composer | sudo tee -a /var/log/deploy/restartapache.log

sudo composer install --no-dev --optimize-autoloader | sudo tee -a /var/log/deploy/restartapache.log

sudo php bin/console doctrine:database:create | sudo tee -a /var/log/deploy/restartapache.log
sudo php bin/console doctrine:migration:migrate --quiet | sudo tee -a /var/log/deploy/restartapache.log

passphrase=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32 | xargs)

sudo sed -i "s/^JWT_PASSPHRASE=.*$/JWT_PASSPHRASE=$passphrase/g" '.env'

sudo mkdir -p config/jwt/ | sudo tee -a /var/log/deploy/restartapache.log

echo "creation de la clé privée" | sudo tee -a /var/log/deploy/restartapache.log
sudo openssl genpkey -out config/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -pass pass:$passphrase

echo "creation de la clé public" | sudo tee -a /var/log/deploy/restartapache.log
sudo openssl pkey -in config/jwt/private.pem -out config/jwt/public.pem -pubout -passin pass:$passphrase

echo "change mod tout le site" | sudo tee -a /var/log/deploy/restartapache.log
chown -R www-data:www-data ../ | sudo tee -a /var/log/deploy/restartapache.log

#sudo unlink /var/log/apache/access.log
#sudo unlink /var/log/apache/error.log
#sudo unlink /var/log/apache/other_vhosts_access.log

#sudo a2enmod rewrite
#sudo a2enmod ssl 

sudo service httpd start
