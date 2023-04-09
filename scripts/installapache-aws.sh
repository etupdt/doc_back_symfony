#!/bin/bash

sudo mkdir -p /var/log/deploy

echo 'debut install mariadb' | sudo tee /var/log/deploy/installapache.log

pwd | sudo tee -a /var/log/deploy/installapache.log

ls -lrt | sudo tee -a /var/log/deploy/installapache.log
