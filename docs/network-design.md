# Network Design 
 
## Hub VNet (10.0.0.0/16) — rg-lab-hub 
| Subnet            | CIDR         | Purpose                    | 
|-------------------|--------------|----------------------------| 
| AzureBastionSubnet| 10.0.0.0/27  | Azure Bastion host         | 
| snet-shared       | 10.0.1.0/24  | Key Vault, Log Analytics   | 
 
## Spoke VNet (10.1.0.0/16) — rg-lab-spoke 
| Subnet  | CIDR         | Purpose      | NSG      | 
|---------|--------------|--------------|----------| 
| snet-app| 10.1.1.0/24  | App servers  | nsg-app  | 
| snet-db | 10.1.2.0/24  | Databases    | nsg-db   |
