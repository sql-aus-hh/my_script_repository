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
$serverLocation = (Get-AzureRmSqlServer -ServerName $servername -ResourceGroupName $resourcegroupname).Location
# Set BackupFault Name
$recoveryServiceVaultName = "AzureSQLDB-LT-Backups"

Write-Host "Starting with 'Activating LongTerm Backup'" -foregroundcolor "white"

$vault = New-AzureRmRecoveryServicesVault -Name $recoveryServiceVaultName -ResourceGroupName $resourcegroupname -Location $serverLocation
Set-AzureRmRecoveryServicesBackupProperties -BackupStorageRedundancy LocallyRedundant -Vault $vault 
Write-Host $recoveryServiceVaultName "successfully created" -foregroundcolor "white"

# Set your server to use the vault to for long-term backup retention 
Write-Host "Setting"$servername" to use the vault '"$recoveryServiceVaultName"' for long-term backup retention" -foregroundcolor "white"
Set-AzureRmSqlServerBackupLongTermRetentionVault -ResourceGroupName $resourcegroupname -ServerName $serverName -ResourceId $vault.Id
# Retrieve the default retention policy for the AzureSQLDatabase workload type
Write-Host "Retrieve the default retention policy for the AzureSQLDatabase workload type" -foregroundcolor "white"
$retentionPolicy = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType AzureSQLDatabase


# Set the retention value to two years (you can set to any time between 1 week and 10 years)
Write-Host "Setting parameters for vault '"$recoveryServiceVaultName"'" -foregroundcolor "white"
$retentionPolicy.RetentionDurationType = "Years"
$retentionPolicy.RetentionCount = 2
$retentionPolicyName = "my2YearRetentionPolicy"

# Set the vault context to the vault you are creating the policy for
Write-Host "Setting the vault context '"$recoveryServiceVaultName"' for the policy." -foregroundcolor "white"
Set-AzureRmRecoveryServicesVaultContext -Vault $vault

# Create the new policy
Write-Host "Create the new policy '"$retentionPolicyName"' for long-term backup retention and AzureSQLDatabase" -foregroundcolor "white"
$policy = New-AzureRmRecoveryServicesBackupProtectionPolicy -name $retentionPolicyName -WorkloadType AzureSQLDatabase -retentionPolicy $retentionPolicy
$policy

# Enable long-term retention for a specific SQL database
Write-Host "Enable long-term backup with retention policy for AzureSQLDatabase" -foregroundcolor "white"
$policyState = "enabled"
Set-AzureRmSqlDatabaseBackupLongTermRetentionPolicy -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databaseName -State $policyState -ResourceId $policy.Id