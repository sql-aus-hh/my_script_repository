Clear-Host

# Define Variables externally
. ".\Variables.ps1"

#
# Login into Azure and define which Subscription should be used
#
Login-AzureRmAccount
####

Set-AzureRmContext -SubscriptionId $mySubscriptionID | Out-null

#
#   Process
#

# Start
Write-Host "Starting with 'Changing-PerformanceLevel-Demo'" -foregroundcolor "white"
Write-Host "Checking if Database exists..." -foregroundcolor "white"

# Dropping DB to stop costs
Get-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername_demo -DatabaseName $databasename_demo -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host $databasename_demo "doesn't exist - no further action needed" 
} else {
    Write-Host "Database" $databasename_demo "will be set to new performance level" $newdbDTUsize "..." -foregroundcolor "DarkYellow"
    Set-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername_demo -DatabaseName $databasename_demo -Edition "Standard" -RequestedServiceObjectiveName $newdbDTUsize | out-null
    Write-Host "Database" $databasename_demo "successfully set to new performance level" $newdbDTUsize -foregroundcolor "green"
}