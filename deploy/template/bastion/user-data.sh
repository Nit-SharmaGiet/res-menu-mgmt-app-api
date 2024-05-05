#!/bin/bash

#create a docker inside bastion 
sudo yum update -y
sudo amazon-linux-extras install -y docker
sudo systemctl enable docker.service
sudo systemctl start docker.service
#default user: ec2-user
sudo usermod -aG docker ec2-user
