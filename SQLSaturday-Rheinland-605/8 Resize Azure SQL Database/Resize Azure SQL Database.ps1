Clear-Host

#
# Login into Azure and define which Subscription should be used
#
$onedrive = (Get-Content Env:\USERPROFILE)+"\Onedrive"
.$onedrive"\SQL-aus-Hamburg\Demos"\Azure_Automation_Login_MVPSubscription.ps1
Login
####

Set-AzureRmContext -SubscriptionId $mySubscriptionID

#
#   Process
#
# Login-AzureRmAccount


# Set the resource group name for your server
$resourcegroupname = "RG-AzureSQLDatabase-Demo"
# Set logical server name
$servername = "server-sqldbdemo"
# The sample database name
$databasename = "db-sqldbdemo"
# Set new performance-level
$newdbDTUsize = "S0"

# Resize Azure SQL Database to new performance-level
Get-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename -ev notPresent -ea 0
if ($notPresent) {
    Write-Host $databasename "doesn't exist" 
} else {
    Set-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename -Edition "Standard" -RequestedServiceObjectiveName $newdbDTUsize
}