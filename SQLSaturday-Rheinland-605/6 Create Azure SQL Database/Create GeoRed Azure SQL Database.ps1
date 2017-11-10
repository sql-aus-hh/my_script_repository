Clear-Host

#
# Login into Azure and define which Subscription should be used
#
Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId $mySubscriptionID

#
#   Process
#

# Set the resource group name and location for your primary server
$primaryresourcegroupname = "myPrimaryResourceGroup-sqlsatdemodb"
$primarylocation = "westeurope"
# Set the resource group name and location for your secondary server
$secondaryresourcegroupname = "mySecondaryResourceGroup-sqlsatdemodb"
$secondarylocation = "southcentralus"
# Set an admin login and password for your servers
$adminlogin = "dbadmin"
$password = "SQLSaturday@2017"
# Set server names - the logical server names have to be unique in the system
$primaryservername = "primary-server-server-sqlsatdemo"
$secondaryservername = "secondary-server-server-sqlsatdemo"
# The sample database name
$databasename = "db-sqlsatdemo-geo"
# The ip address range that you want to allow to access your servers
$clientIP = (Invoke-WebRequest ifconfig.me/ip).Content
$primarystartip = $clientIP
$primaryendip = $clientIP
$secondarystartip = $clientIP
$secondaryendip = $clientIP




# Create two new resource groups
Get-AzureRmResourceGroup -Name $primaryresourcegroupname -ev notPresent -ea 0
if ($notPresent) {
    $primaryresourcegroup = New-AzureRmResourceGroup -Name $primaryresourcegroupname -Location $primarylocation
    Write-Host "Primary Resource Group created"
} else {
    Write-Host "Primary Resource Group already exists"
}
Get-AzureRmResourceGroup -Name $secondaryresourcegroupname -ev notPresent -ea 0
if ($notPresent) {
    $secondaryresourcegroup = New-AzureRmResourceGroup -Name $secondaryresourcegroupname -Location $secondarylocation
    Write-Host "Secondary Resource Group created"
} else {
    Write-Host "Secondary Resource Group already exists"
}

# Create two new logical servers with a system wide unique server name
Get-AzureRmSqlServer -ResourceGroupName $primaryresourcegroupname -ServerName $primaryservername -ev notPresent -ea 0
if ($notPresent) {
    $primaryserver = New-AzureRmSqlServer -ResourceGroupName $primaryresourcegroupname `
    -ServerName $primaryservername `
    -Location $primarylocation `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))
    Write-Host "Primary Server created"
} else {
    Write-Host "Primary Server already exists"
}
Get-AzureRmSqlServer -ResourceGroupName $secondaryresourcegroupname -ServerName $secondaryservername -ev notPresent -ea 0
if ($notPresent) {
    $secondaryserver = New-AzureRmSqlServer -ResourceGroupName $secondaryresourcegroupname `
    -ServerName $secondaryservername `
    -Location $secondarylocation `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))
    Write-Host "Secondary Server created"
} else {
    Write-Host "Secondary Server already exists"
}

# Create a blank database with S0 performance level on the primary server
Get-AzureRmSqlDatabase -ResourceGroupName $primaryresourcegroupname -ServerName $primaryservername -DatabaseName $databasename -ev notPresent -ea 0
if ($notPresent) {
    $database = New-AzureRmSqlDatabase  -ResourceGroupName $primaryresourcegroupname `
    -ServerName $primaryservername `
    -DatabaseName $databasename -RequestedServiceObjectiveName "S0"
    Write-Host "Primary Azure SQL Database created"
} else {
    Write-Host "Primary Azure SQL Database already exists"
    $database = Get-AzureRmSqlDatabase -ResourceGroupName $primaryresourcegroupname -ServerName $primaryservername -DatabaseName $databasename
}

# Establish Active Geo-Replication
Get-AzureRmSqlDatabase -ResourceGroupName $secondaryresourcegroupname -ServerName $secondaryservername -DatabaseName $databasename -ev notPresent -ea 0
if ($notPresent) {
    $database = Get-AzureRmSqlDatabase -DatabaseName $databasename -ResourceGroupName $primaryresourcegroupname -ServerName $primaryservername
    $database | New-AzureRmSqlDatabaseSecondary -PartnerResourceGroupName $secondaryresourcegroupname -PartnerServerName $secondaryservername -AllowConnections "All"
    Write-Host "Secondary Azure SQL Database created"
} else {
    Write-Host "Secondary Azure SQL Database already exists"
}
<#
# Initiate a planned failover
Write-Host "Initiate a planned failover"
$database = Get-AzureRmSqlDatabase -DatabaseName $databasename -ResourceGroupName $secondaryresourcegroupname -ServerName $secondaryservername
$database | Set-AzureRmSqlDatabaseSecondary -PartnerResourceGroupName $primaryresourcegroupname -Failover

# Monitor Geo-Replication config and health after failover
Write-Host "Monitor Geo-Replication config and health after failover"
$database = Get-AzureRmSqlDatabase -DatabaseName $databasename -ResourceGroupName $secondaryresourcegroupname -ServerName $secondaryservername
$database | Get-AzureRmSqlDatabaseReplicationLink -PartnerResourceGroupName $primaryresourcegroupname -PartnerServerName $primaryservername

# Remove the replication link after the failover
Write-Host "Remove the replication link after the failover"
$database = Get-AzureRmSqlDatabase -DatabaseName $databasename -ResourceGroupName $secondaryresourcegroupname -ServerName $secondaryservername
$secondaryLink = $database | Get-AzureRmSqlDatabaseReplicationLink -PartnerResourceGroupName $primaryresourcegroupname -PartnerServerName $primaryservername
$secondaryLink | Remove-AzureRmSqlDatabaseSecondary

# Clean up deployment 
#Remove-AzureRmResourceGroup -ResourceGroupName $primaryresourcegroupname
#Remove-AzureRmResourceGroup -ResourceGroupName $secondaryresourcegroupname
#>
