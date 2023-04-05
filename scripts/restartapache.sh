#!/bin/bash

docker exec -it my_container sh -c "cd /var/www/html/doc_back_symfony && ./scripts/"

#sudo systemctl restart httpd
