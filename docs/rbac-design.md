# RBAC Design 
 
## Persona: Developer 
| Role        | Scope           | Rationale                              | 
|-------------|-----------------|----------------------------------------| 
| Contributor | rg-lab-spoke    | Deploy and manage workload resources   | 
 
Maximum damage if role is too broad: if Contributor were assigned at 
subscription scope, a developer could modify hub shared services, 
delete Key Vault, and disrupt all security controls. 
 
## Persona: Operator 
| Role                     | Scope        | Rationale              | 
|--------------------------|--------------|------------------------| 
| Reader                   | rg-lab-spoke | Read all configurations| 
| Virtual Machine Contributor | rg-lab-spoke | Start/stop/restart VMs | 
 
## Persona: Auditor 
| Role   | Scope        | Rationale                                    | 
|--------|--------------|----------------------------------------------| 
| Reader | Subscription | Read all resources across all resource groups|
