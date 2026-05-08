# Hub Shared Services 
 
## Azure Bastion 
- Name: bastion-hub 
- Subnet: AzureBastionSubnet (10.0.0.0/27) 
- Use: Secure SSH/RDP to all spoke VMs without public IPs 
 
## Key Vault 
- Name: kv-lab-yourname 
- Access model: RBAC (not vault access policies) 
- Secrets stored: db-connection-string 
- Logging: AuditEvent → Log Analytics Workspace 
 
## Log Analytics Workspace 
- Name: law-hub 
- SKU: PerGB2018 
- Retention: 30 days 
- Sources: Key Vault (AuditEvent, AllMetrics) 
