# Terraform on Azure samples

 Terraform has multiple ways to authenticate with azure. Top 3 scenarios is as follows.

 - Authentication using Service Principal
 - Authentication using Az Client
 - Authentication using Managed Idendity

## Authentication using Service Principal
 In most cases a service principle will be required in azure to use with Terraform. Lets create it using **PowerShell**.

Please save the secret returned by the below secret as it is available to get only when you craete it. 
 
```PowerShell
$TenantID = 'your tennantid here'
$SubscriptionID = 'your subscriptionid here'
Connect-AzAccount -Tenant $TenantID
Set-AzContext -Subscription $SubscriptionID
$sp = New-AzADServicePrincipal -DisplayName TerraformSPN
$sp.Secret | ConvertFrom-SecureString
```

We can use these variables as harcoded in the config but it is better to use them as environment variables. Lets run the following to create permenant system environment variables so that all users can access.

```PowerShell
$Secret = $sp.Secret | ConvertFrom-SecureString
$Scope = [System.EnvironmentVariableTarget]::Machine
 [System.Environment]::SetEnvironmentVariable('ARM_CLIENT_ID',$SP.ApplicationId.Guid,$Scope)
 [System.Environment]::SetEnvironmentVariable('ARM_CLIENT_SECRET',$Secret,$Scope)
 [System.Environment]::SetEnvironmentVariable('ARM_SUBSCRIPTION_ID',$SubscriptionID ,$Scope)
 [System.Environment]::SetEnvironmentVariable('ARM_TENANT_ID',$TenantID ,$Scope)
```

## Authentication using Az Client

