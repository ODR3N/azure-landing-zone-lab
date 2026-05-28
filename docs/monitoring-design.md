# Monitoring and Alerting Design

## Log Analytics Workspace
- Name: law-hub
- SKU: PerGB2018
- Retention: 30 days
- Sources: Key Vault (AuditEvent), VM (OMS Agent)

## Action Group
- Name: ag-lab-ops
- Short name: OpsAlert
- Email: adrfc.pro@gmail.com

## Alert Rules
| Alert Name        | Condition     | Window | Severity | Action      |
|-------------------|---------------|--------|----------|-------------|
| alert-vm-cpu-high | avg CPU > 80% | 5m     | Warning  | ag-lab-ops  |

## Budget
| Name               | Amount | Threshold | Notification       |
|--------------------|--------|-----------|--------------------|
| budget-lab-monthly | $20    | 80%       | adrfc.pro@gmail.com|

## KQL Queries

### All Key Vault secret reads in last 24 hours
```kql
AzureDiagnostics
| where ResourceType == "VAULTS"
| where OperationName == "SecretGet"
| where TimeGenerated > ago(24h)
| project TimeGenerated, CallerIPAddress, ResultType
| order by TimeGenerated desc
```

### Failed Key Vault access attempts
```kql
AzureDiagnostics
| where ResourceType == "VAULTS"
| where ResultType != "Success"
| where TimeGenerated > ago(7d)
| summarize FailedAttempts = count() by CallerIPAddress, OperationName
| order by FailedAttempts desc
```
