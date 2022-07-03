Following assumptions are made for the challenge 1
- Terraform is the tool used for IaaC 
- The cloud provider is assumed to be azure
- 3 Tier environment is Web server / Application Server / Data server 
- there will be 1 resource group 
- 1 virtual network 
- 1 storage account
- 3 subnets - web / app / data
- 3 NSG - web / app / data
    - rules should be added for each NSG ... only certain ports will be allowed from one subnet to another .. 
- 3 Network interface - web/ app / data




