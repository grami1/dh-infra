#!/bin/bash
yum update -y
yum install docker -y
yum install amazon-ecr-credential-helper -y
systemctl start docker