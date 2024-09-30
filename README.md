# Terraform-Webapp-Architecture
This project demonstrates a highly available, fault-tolerant web application architecture deployed on AWS using Terraform. 

It includes:

A VPC with public and private subnets across 6 availability zones.

An Application Load Balancer (ALB) and an Auto Scaling Group (ASG) for high availability and dynamic scaling.

CloudWatch alarms to monitor CPU utilization and request count per target.

An S3 bucket for ALB log storage with lifecycle policies and encryption enabled.

Secure retrieval of AMI IDs from Vault, with tokens stored in AWS Secrets Manager.
