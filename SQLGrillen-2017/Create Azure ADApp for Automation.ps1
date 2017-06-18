# AutomationAccount erstellen
# https://cmatskas.com/automate-login-for-azure-powershell-scripts/
Login-AzureRmAccount  

Get-AzureRmSubscription

Select-AzureRmSubscription -SubscriptionId "1234567-1234-1234-1234-012345678912"  

$azureAdApplication = New-AzureRmADApplication -DisplayName "PoShAutomation" -HomePage "http://www.testurl.de" -IdentifierUris "http://www.testurl.de/poshautomation" -Password "SQLGrillen@2017"

$azureAdApplication

New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication.ApplicationId  

New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName "1234567-1234-1234-1234-012345678912"