# Terraform on Azure samples

# Authentication 
Terraform has multiple ways to authenticate with azure. In most cases a service princple will be required in azure. Lets create it using **PowerShell**.

Please save the secret returned by the below secret as it is available to get only when you craete it. 

 
```PowerShell
$TenantID = 'your tennantid here'
$SubscriptionID = 'your subscriptionid here'
Connect-AzAccount -Tenant $TenantID
Set-AzContext -Subscription $SubscriptionID
$sp = New-AzADServicePrincipal -DisplayName TerraformSPN
```

We can use these variables as harcoded in the config but it is better to use them as environment varibles. Lets run the following to 

```PowerShell
$Secret = $sp.Secret | ConvertFrom-SecureString
$Scope = [System.EnvironmentVariableTarget]::Machine
 [System.Environment]::SetEnvironmentVariable('ARM_CLIENT_ID',$SP.ApplicationId.Guid,$Scope)
 [System.Environment]::SetEnvironmentVariable('ARM_CLIENT_SECRET',$Secret,$Scope)
 [System.Environment]::SetEnvironmentVariable('ARM_SUBSCRIPTION_ID',$SubscriptionID ,$Scope)
 [System.Environment]::SetEnvironmentVariable('ARM_TENANT_ID',$TenantID ,$Scope)
```

