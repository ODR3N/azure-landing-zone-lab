# azure-landing-zone-lab

> Production-aligned hub-spoke Azure environment built from scratch using the Azure CLI and Bicep — with network segmentation, secretless authentication, RBAC governance, and centralized observability.

<br>

[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=flat-square&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com)
[![Bicep](https://img.shields.io/badge/IaC-Bicep-5C2D91?style=flat-square&logo=microsoftazure&logoColor=white)](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)]()

<br>

## Overview

This project provisions a complete **hub-spoke Azure landing zone** following enterprise network design principles. All infrastructure is defined as code using **Bicep modules** and can be deployed or torn down with a single CLI command.

It was built as a hands-on portfolio project covering:

- Enterprise network topology and IP address planning
- Zero-trust network security with NSG least-privilege rules
- Secretless VM authentication using Managed Identities
- RBAC governance across multiple roles and scopes
- Centralized observability with Azure Monitor and Log Analytics
- Infrastructure as Code with modular, reusable Bicep

<br>

## Architecture

```
                              Internet
                                 │
                          HTTP/HTTPS (443/80)
                                 │
┌────────────────────────────────▼──────────────────────────────────┐
│  Hub VNet  ·  10.0.0.0/16  ·  rg-lab-hub                         │
│                                                                    │
│  ┌─────────────────────────┐   ┌──────────────────────────────┐   │
│  │  AzureBastionSubnet     │   │  snet-shared                 │   │
│  │  10.0.0.0/27            │   │  10.0.1.0/24                 │   │
│  │                         │   │                              │   │
│  │  ┌───────────────────┐  │   │  ┌──────────┐ ┌───────────┐ │   │
│  │  │  Azure Bastion    │  │   │  │Key Vault │ │    Log    │ │   │
│  │  │  bastion-hub      │  │   │  │kv-lab    │ │Analytics  │ │   │
│  │  │  Basic SKU        │  │   │  │RBAC mode │ │law-hub    │ │   │
│  │  └─────────┬─────────┘  │   │  └────┬─────┘ └─────┬─────┘ │   │
│  │            │  pip-bastion│   │       │  reads secrets│ logs  │   │
│  └────────────┼─────────────┘   └───────┼───────────────┼───────┘   │
│               │                         │               │           │
└───────────────┼─────────────────────────┼───────────────┼───────────┘
                │                         │               │
                │    VNet Peering (↕ bidirectional)       │
                │                         │               │
┌───────────────┼─────────────────────────┼───────────────┼───────────┐
│  Spoke VNet  ·  10.1.0.0/16  ·  rg-lab-spoke            │           │
│               │                         │               │           │
│  ┌────────────┼──────────────┐  ┌───────┼───────────────┼────────┐  │
│  │  snet-app  │  10.1.1.0/24 │  │  snet-db  10.1.2.0/24 │        │  │
│  │  NSG: nsg-app             │  │  NSG: nsg-db           │        │  │
│  │            │              │  │                        │        │  │
│  │  ┌─────────▼───────────┐  │  │  ┌──────────────────┐ │        │  │
│  │  │  vm-app-01          │  │  │  │  Database tier   │ │        │  │
│  │  │  Ubuntu 22.04 LTS   │  │  │  │  Reserved        │ │        │  │
│  │  │  No public IP       │  │  │  │  :5432 from app  │ │        │  │
│  │  │  mi-app-vm (MI) ────┼──┼──┼──┼──────────────────┼─┘        │  │
│  │  └─────────────────────┘  │  └──────────────────────────────┘  │
│  │  Allow: SSH (Bastion only) │                                    │
│  │  Allow: :80/:443 inbound   │  Allow: :5432 from snet-app only  │
│  │  Allow: :5432 outbound     │  Deny:  Internet inbound (explicit)│
│  └───────────────────────────┘  └────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘

RBAC Governance
─────────────────────────────────────────────────────────────────────
  Developer   →  Contributor         scope: rg-lab-spoke
  Operator    →  Reader              scope: rg-lab-spoke
              →  VM Contributor      scope: rg-lab-spoke
  Auditor     →  Reader              scope: /subscriptions/<id>

Azure Monitor
─────────────────────────────────────────────────────────────────────
  alert-vm-cpu-high   avg CPU > 80% · 5 min window · Severity 2
  budget-lab-monthly  $20 limit · alert at 80% spend
```

<br>

## Key Design Decisions

| Decision | Rationale |
|---|---|
| No public IPs on VMs | Eliminates internet attack surface on compute entirely |
| SSH only from Bastion subnet | Restricts VM access to a managed, audited path |
| Key Vault with RBAC authorization | Unified access model, fully auditable via Log Analytics |
| User-Assigned Managed Identity | Survives VM deletion, shareable across VMs, zero credentials stored |
| Explicit deny on DB subnet | Defense in depth beyond Azure's default deny |
| NSG attached at subnet (not NIC) | Enforces policy at the perimeter, not per-resource |
| Hub-spoke topology | Blast radius containment — compromised spoke cannot affect hub |
| Modular Bicep | Each component is independently reusable and testable |

<br>

## Tech Stack

| Technology | Purpose |
|---|---|
| Azure CLI | Resource provisioning and scripting |
| Azure Bicep | Infrastructure as Code — modular, declarative |
| Azure Virtual Network + NSG | Network segmentation and traffic control |
| Azure Bastion | Secure VM access without public IP exposure |
| Azure Key Vault | Centralized secrets management (RBAC model) |
| Azure Log Analytics | Centralized log store — queried with KQL |
| Azure Monitor | Metric alerts and spending budget |
| Managed Identity | Zero-credential authentication for workloads |
| Ubuntu 22.04 LTS | Application VM OS |

<br>

## Repository Structure

```
azure-landing-zone-lab/
├── bicep/
│   ├── main.bicep                  # Entry point — subscription scope
│   └── modules/
│       ├── network-hub.bicep       # Hub VNet, Bastion, shared subnet
│       ├── network-spoke.bicep     # Spoke VNet, NSGs, subnet rules
│       ├── peering.bicep           # VNet Peering (reusable, bidirectional)
│       └── keyvault.bicep          # Key Vault with RBAC authorization
├── scripts/
│   └── set-vars.sh                 # Session variable loader
├── docs/
│   ├── network-design.md           # IP addressing and subnet plan
│   ├── shared-services.md          # Bastion, Key Vault, Log Analytics
│   ├── rbac-design.md              # Role assignments and reasoning
│   └── monitoring-design.md        # Alerts, budget, KQL queries
├── .gitignore
└── README.md
```

<br>

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) `2.50+`
- [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) (install via `az bicep install`)
- An Azure account with an active subscription
- WSL (Windows) or any Bash-compatible terminal

<br>

## Deploy

```bash
# 1. Clone the repository
git clone https://github.com/ODR3N/azure-landing-zone-lab.git
cd azure-landing-zone-lab

# 2. Login to Azure
az login
az account set --subscription 'your-subscription-name'

# 3. Install Bicep
az bicep install

# 4. Deploy the full environment (subscription scope)
az deployment sub create \
  --name 'deploy-landing-zone' \
  --location eastus \
  --template-file bicep/main.bicep \
  --parameters keyVaultName=kv-your-unique-name

# 5. Verify deployment
az deployment sub show \
  --name 'deploy-landing-zone' \
  --query 'properties.provisioningState'
```

> **Note:** `keyVaultName` must be globally unique across all Azure tenants (3–24 alphanumeric characters and hyphens).

<br>

## Teardown

```bash
# Delete both resource groups and all resources inside them
az group delete --name rg-lab-hub   --yes --no-wait
az group delete --name rg-lab-spoke --yes --no-wait
```

The environment can be fully rebuilt at any time with the deploy command above. This is the core value of Infrastructure as Code.

<br>

## Network Security Rules

### nsg-app (snet-app — 10.1.1.0/24)

| Priority | Name | Direction | Source | Destination | Port | Action |
|---|---|---|---|---|---|---|
| 100 | allow-ssh-from-bastion | Inbound | 10.0.0.0/27 | 10.1.1.0/24 | 22 | Allow |
| 110 | allow-http-inbound | Inbound | Any | Any | 80 | Allow |
| 120 | allow-https-inbound | Inbound | Any | Any | 443 | Allow |
| 200 | allow-app-to-db | Outbound | Any | 10.1.2.0/24 | 5432 | Allow |
| 65500 | DenyAllInBound | Inbound | Any | Any | Any | Deny |

### nsg-db (snet-db — 10.1.2.0/24)

| Priority | Name | Direction | Source | Destination | Port | Action |
|---|---|---|---|---|---|---|
| 100 | allow-app-subnet-to-db | Inbound | 10.1.1.0/24 | Any | 5432 | Allow |
| 4000 | deny-internet-to-db | Inbound | Internet | Any | Any | Deny |
| 65500 | DenyAllInBound | Inbound | Any | Any | Any | Deny |

<br>

## RBAC Design

| Persona | Role | Scope | Maximum damage if over-granted |
|---|---|---|---|
| Developer | Contributor | rg-lab-spoke | Can destroy all workload resources. Cannot touch hub or escalate privileges. |
| Operator | Reader + VM Contributor | rg-lab-spoke | Can start/stop VMs. Cannot create resources or modify security config. |
| Auditor | Reader | Subscription | Read-only across everything. Cannot modify any resource anywhere. |

<br>

## Observability

All resources ship logs to `law-hub` (Log Analytics Workspace). Sample KQL queries are in [`docs/monitoring-design.md`](docs/monitoring-design.md).

**Find all Key Vault secret reads in the last 24 hours:**
```kql
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName == "SecretGet"
| where TimeGenerated > ago(24h)
| project TimeGenerated, CallerIPAddress, ResultType, identity_claim_oid_g
| order by TimeGenerated desc
```

**Find failed access attempts:**
```kql
AzureDiagnostics
| where ResourceType == "VAULTS"
| where ResultType != "Success"
| where TimeGenerated > ago(7d)
| summarize FailedAttempts = count() by CallerIPAddress, OperationName
| order by FailedAttempts desc
```

<br>

## Cost Awareness

> Approximate monthly cost if all resources run continuously:

| Resource | Cost |
|---|---|
| Standard_B1s VM | ~$8/month |
| Azure Bastion Basic | ~$140/month |
| Standard Public IP | ~$3/month |
| Key Vault | ~$0.03/month |
| Log Analytics (lab volume) | ~$0/month |

**Azure Bastion is the only expensive component.** Delete it when not in use and redeploy with one command when you need VM access. A budget alert at 80% of $20/month is configured to prevent unexpected charges.

```bash
# Stop the VM when not in use (deallocate = no compute charge)
az vm deallocate --name vm-app-01 --resource-group rg-lab-spoke

# Delete Bastion when done with SSH work
az network bastion delete --name bastion-hub --resource-group rg-lab-hub
```

<br>

## Learning Objectives

This project was built to practice and demonstrate:

- Hub-spoke topology and enterprise network design on Azure
- NSG rule design implementing least-privilege at the subnet level
- Managed Identity authentication flow via Azure IMDS
- RBAC scope hierarchy and role composition
- Azure Monitor alert rules and KQL log queries
- Modular Bicep IaC with parameters, outputs, and cross-module references
- Idempotent infrastructure deployments

<br>

## Related Projects

| Project | Description |
|---|---|
| [containerized-api-platform](https://github.com/ODR3N/containerized-api-platform) | Dockerized REST API with secure CI/CD pipeline |
| [aks-production-platform](https://github.com/ODR3N/aks-production-platform) | AKS deployment with Helm, Prometheus, and Grafana |
| [aks-infra-pipeline](https://github.com/ODR3N/aks-infra-pipeline) | Terraform modules + Azure DevOps Pipelines |

<br>

## Author

**Adrian Fonseca**
LinkedIn: [linkedin.com/in/afc2806](https://linkedin.com/in/afc2806) · GitHub: [github.com/ODR3N](https://github.com/ODR3N) · Portfolio: [odr3n.github.io](https://odr3n.github.io)

<br>

## License

[MIT](LICENSE)
