#!/bin/bash

sudo mkdir -p /var/log/deploy

echo 'debut install mariadb' | sudo tee /var/log/deploy/startapache.log

pwd | sudo tee -a /var/log/deploy/startapache.log
