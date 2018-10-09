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
Write-Host "Starting with 'Cost-Saving-Demo'" -foregroundcolor "white"
Write-Host "Checking if Database exists..." -foregroundcolor "white"

# Dropping DB to stop costs
Get-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername_backup -DatabaseName $databasename_backup -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host $databasename_backup "doesn't exist or is already deleted" -ForegroundColor "Red"
    #Exit
} else {
    Write-Host $databasename_backup "will be deleted right now..." -ForegroundColor "DarkYellow"
    Remove-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername_backup -DatabaseName $databasename_backup | Out-Null
    Write-Host $databasename_backup "deleted successfully..." -ForegroundColor "yellow"
}

# Simuliere die Nacht ;-)
Write-Host "Es wird Nacht ;-) "
Start-Sleep -s 25
Write-Host "Es ist 23 Uhr"
Start-Sleep -s 25
Write-Host "Es ist 1 Uhr"
Start-Sleep -s 25
Write-Host "Es ist 3 Uhr"
Start-Sleep -s 25
Write-Host "Es ist 5 Uhr"
Start-Sleep -s 25
Write-Host "Es ist 7 Uhr"
Start-Sleep -s 25
Write-Host "Ein neuer Arbeitstag beginnt..."
Start-Sleep -s 25

# Start
Write-Host "Checking for database informations about last backup" -foregroundcolor "white"
$deleteddatabase = Get-AzureRmSqlDeletedDatabaseBackup -ResourceGroupName $resourcegroupname -ServerName $servername_backup -DatabaseName $databasename_backup | Sort-Object -Descending 
Write-Host "Found following database information" -foregroundcolor "white"
$deleteddatabase


# Do not continue until the cmdlet returns information about the deleted database.
if(![string]::IsNullOrEmpty($deleteddatabase)) {
    Write-Host "Now restoring database $databasename_backup ..." -foregroundcolor "DarkYellow"
    Restore-AzureRmSqlDatabase -FromDeletedDatabaseBackup `
        -ResourceGroupName $resourcegroupname `
        -ServerName $servername_backup `
        -TargetDatabaseName $databasename_backup `
        -ResourceId ($deleteddatabase.ResourceID | Select-Object -Last 1) `
        -DeletionDate ($deleteddatabase.DeletionDate | Select-Object -Last 1) `
        -Edition "Standard" `
        -ServiceObjectiveName "S0"
}
