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

# Start
Write-Host "Starting with 'Cost-Saving-Demo'" -foregroundcolor "white"
Write-Host "Checking if Database exists..." -foregroundcolor "white"

# Dropping DB to stop costs
Get-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host $databasename "doesn't exist or is already deleted" -ForegroundColor "Red"
    #Exit
} else {
    Write-Host $databasename "will be deleted right now..." -ForegroundColor "DarkYellow"
    Remove-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename | Out-Null
    Write-Host $databasename "deleted successfully..." -ForegroundColor "yellow"
}

# Simuliere die Nacht ;-)
Write-Host "Es wird Nacht ;-) "
Start-Sleep -s 5
Write-Host "Es ist 23 Uhr"
Start-Sleep -s 5
Write-Host "Es ist 1 Uhr"
Start-Sleep -s 5
Write-Host "Es ist 3 Uhr"
Start-Sleep -s 5
Write-Host "Es ist 5 Uhr"
Start-Sleep -s 5
Write-Host "Es ist 7 Uhr"
Start-Sleep -s 5
Write-Host "Ein neuer Arbeitstag beginnt..."

# Start
Write-Host "Checking for database informations about last backup" -foregroundcolor "white"
$deleteddatabase = Get-AzureRmSqlDeletedDatabaseBackup -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename
Write-Host "Found following database information" -foregroundcolor "white"
$deleteddatabase


# Do not continue until the cmdlet returns information about the deleted database.
if(![string]::IsNullOrEmpty($deleteddatabase)) {
    Write-Host "Now restoring database "$databasename" to Point-in-Time "$deleteddatabase.DeletionDate "..." -foregroundcolor "DarkYellow"
    Restore-AzureRmSqlDatabase -FromDeletedDatabaseBackup `
        -ResourceGroupName $resourcegroupname `
        -ServerName $servername `
        -TargetDatabaseName $databasename `
        -ResourceId $deleteddatabase.ResourceID `
        -DeletionDate $deleteddatabase.DeletionDate `
        -Edition "Standard" `
        -ServiceObjectiveName "S0"
}
