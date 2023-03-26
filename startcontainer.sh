
#cd /var/www/html/doc_back_symfony

./composer.phar install --no-dev --optimize-autoloader

php bin/console doctrine:migration:migrate

tail -f /dev/null
