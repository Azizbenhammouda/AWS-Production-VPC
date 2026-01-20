# AWS Production VPC Terraform Module

This repository contains a Terraform configuration to provision a standard, highly-available AWS networking environment. It is designed for production use-cases where private resources need internet access through a controlled gateway.

## Architecture Overview

The configuration creates a Custom VPC with a tiered subnet strategy:

Public Subnets: Hosted in us-east-1a. These subnets have a route to the Internet Gateway (IGW). They are intended for Load Balancers, Bastion hosts, or NAT Gateways.

Private Subnets: Hosted in us-east-1b. These subnets route outbound traffic through a NAT Gateway. They are intended for application servers and databases that should not be directly reachable from the internet.