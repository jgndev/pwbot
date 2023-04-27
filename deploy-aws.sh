#!/bin/bash
cd terraform/aws
terraform init
terraform apply -auto-approve
