## Example Configuration
### A common choice for a new VPC is /16, which allows for 65,536 IP addresses
VPC CIDR: 10.0.0.0/16

## Public Subnets:
10.0.1.0/24 (AZ1)
10.0.2.0/24 (AZ2)
10.0.3.0/24 (AZ3)
## Private Subnets:
10.0.4.0/24 (AZ1)
10.0.5.0/24 (AZ2)
10.0.6.0/24 (AZ3)

## Others
Pod CIDR: 192.168.0.0/16
Service CIDR: 172.20.0.0/16