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
$databasename = "db-sqldbdemo"

Write-Host "Starting with 'Listing all available LongTerm Backups'" -foregroundcolor "white"
$databaseNeedingRestore = $databaseName

# Set the vault context to the vault we want to restore from
$vault = Get-AzureRmRecoveryServicesVault -ResourceGroupName $resourcegroupname
Set-AzureRmRecoveryServicesVaultContext -Vault $vault

# the following commands find the container associated with the server 'myserver' under resource group 'myresourcegroup'
$container = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureSQL -FriendlyName $vault.Name

# Get the long-term retention metadata associated with a specific database
$item = Get-AzureRmRecoveryServicesBackupItem -Container $container -WorkloadType AzureSQLDatabase -Name $databaseNeedingRestore

# Get all available backups for the previously indicated database
# Optionally, set the -StartDate and -EndDate parameters to return backups within a specific time period
$availableBackups = Get-AzureRmRecoveryServicesBackupRecoveryPoint -Item $item
$availableBackups