#!/bin/bash

docker exec -it my_container sh -c "cd /var/www/html/doc_back_symfony && php bin/console doctrine:migration:migrate && apt install pwgen -y"

#sudo systemctl restart httpd
