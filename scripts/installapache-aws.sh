#!/bin/bash

sudo mkdir -p /var/log/deploy

echo 'install' | sudo tee /var/log/deploy/installapache.log

pwd | sudo tee -a /var/log/deploy/installapache.log

ls -lrt | sudo tee -a /var/log/deploy/installapache.log
