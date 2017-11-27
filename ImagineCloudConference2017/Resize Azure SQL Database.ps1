clear
#
# Login into Azure and define which Subscription should be used
#
Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId $mySubscriptionID | Out-null

#
#   Process
#
# Set the resource group name and location for your server
$resourcegroupname = "RG-ImagineCloudConference"
# Set server name - the logical server name has to be unique in the system
$servername = "server-sqldbdemo"
# The sample database name
$databasename = "db-sqldbdemo"
# The new performance level
$newdbDTUsize = "S1"

# Start
Write-Host "Starting with 'Changing-PerformanceLevel-Demo'" -foregroundcolor "white"
Write-Host "Checking if Database exists..." -foregroundcolor "white"

# Dropping DB to stop costs
Get-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host $databasename "doesn't exist" 
} else {
    Write-Host "Database" $databasename "will be set to new performance level" $newdbDTUsize "..." -foregroundcolor "DarkYellow"
    Set-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename -Edition "Standard" -RequestedServiceObjectiveName $newdbDTUsize | out-null
    Write-Host "Database" $databasename "successfully set to new performance level" $newdbDTUsize -foregroundcolor "green"
}