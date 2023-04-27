#!/bin/bash
cd terraform/azure
terraform init
terraform apply -auto-approve
