Clear-Host

# Define Variables externally
. ".\Variables.ps1"

#
# Login into Azure and define which Subscription should be used
#
Login-AzureRmAccount
####

Set-AzureRmContext -SubscriptionId $mySubscriptionID | Out-null

# Define Variables externally
Write-Host "Reading Variables"
.$onedrive"\SQL-aus-Hamburg\Sessions\1_Einstieg in Azure SQL Databases und Powershell Automation\Demo\Variables.ps1"
Write-Host "Variables defined"

#
#   Process
#

# Start

# Checking if Server exists - get details of that server
# Create a server with a system wide unique server name
Write-Host "Checking if database server $servername_ltr existing..."
Get-AzureRmSqlServer -ResourceGroupName $resourcegroupname -ServerName $servername_ltr -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host "LTR Backup Policy cannot be defined ... because Server $servername_ltr does not exist..." -foregroundcolor "Red"
} else {
    $server = Get-AzureRmSqlServer -ServerName $servername_ltr -ResourceGroupName $resourcegroupname
}

Write-Host "Setting new LTR policy"
# create LTR policy with WeeklyRetention = 12 weeks. MonthlyRetention and YearlyRetention = 0 by default.
Set-AzureRmSqlDatabaseBackupLongTermRetentionPolicy -ServerName $servername_ltr -DatabaseName $databasename_ltr -ResourceGroupName $resourcegroupname -WeeklyRetention P12W 

# create LTR policy with WeeklyRetention = 12 weeks, YearlyRetetion = 5 years and WeekOfYear = 16 (week of April 15). MonthlyRetention = 0 by default.
# Set-AzureRmSqlDatabaseBackupLongTermRetentionPolicy -ServerName $servername_ltr -DatabaseName $databasename_ltr -ResourceGroupName $resourcegroupname -WeeklyRetention P12W -YearlyRetention P5Y -WeekOfYear 16
Write-Host "Script finished"


## Verifing LTR policies
# Get the LTR policy of a specific database 
# Get-AzureRmSqlDatabaseBackupLongTermRetentionPolicy -ServerName $servername_ltr -DatabaseName $databasename_ltr  -ResourceGroupName $resourcegroupname -Current

# List LTR backups only from live databases (you have option to choose All/Live/Deleted)
# Get-AzureRmSqlDatabaseLongTermRetentionBackup -Location $server.Location -DatabaseState Live
