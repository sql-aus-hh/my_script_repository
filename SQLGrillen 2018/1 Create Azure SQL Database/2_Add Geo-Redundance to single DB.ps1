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
# Login-AzureRmAccount
# Set the resource group name and location for your server
$resourcegroupname = "RG-Azure-SQL-DB-Demo"
$primarylocation = "westus"
$secondarylocation = "southcentralus"
# Set an admin login and password for your server
$adminlogin = "dbadmin"
$password = "gab@2018"
# Set server name - the logical server name has to be unique in the system
$primaryservername = "server-gab2018hh"
$secondaryservername = "secondary-server-gab2018hh"
# The sample database name
$databasename = "db-gab2018hh"
# The ip address range that you want to allow to access your server
$clientIP = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$startip = $clientIP.replace("`n","").replace("`r","")
$endip = $clientIP.replace("`n","").replace("`r","")

Write-Host $resourcegroupname "Starting with 'Adding Geo-Redundancy'" -foregroundcolor "white"
Write-Host $resourcegroupname "Checking if Resourcegroup exist..." -foregroundcolor "white"

# Create a resource group
Get-AzureRmResourceGroup -Name $resourcegroupname -ev notPresent -ea 0 | Out-null
if ($notPresent) {
    Write-Host $resourcegroupname "does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $resourcegroup = New-AzureRmResourceGroup -Name $resourcegroupname -Location $location | Out-null
    Write-Host $resourcegroupname "successfully created" -foregroundcolor "white"
} else {
    Write-Host $resourcegroupname "already exists" -foregroundcolor "green"
}

# Create two new logical servers with a system wide unique server name
# Create a server with a system wide unique server name
Get-AzureRmSqlServer -ResourceGroupName $resourcegroupname -ServerName $primaryservername -ev notPresent -ea 0 | Out-null
if ($notPresent) {
    Write-Host $primaryservername "does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $server = New-AzureRmSqlServer -ResourceGroupName $resourcegroupname `
    -ServerName $primaryservername `
    -Location $primarylocation `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))  | Out-null
    Write-Host $primaryservername "successfully created" -foregroundcolor "white"
} else {
    Write-Host $primaryservername "already exists" -ForegroundColor "green"
}

Get-AzureRmSqlServer -ResourceGroupName $resourcegroupname -ServerName $secondaryservername -ev notPresent -ea 0 | Out-null
if ($notPresent) {
    Write-Host $secondaryservername "does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $server = New-AzureRmSqlServer -ResourceGroupName $resourcegroupname `
    -ServerName $secondaryservername `
    -Location $secondarylocation `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))  | Out-null
    Write-Host $secondaryservername "successfully created" -foregroundcolor "white"
} else {
    Write-Host $secondaryservername "already exists" -ForegroundColor "green"
}

# Establish Active Geo-Replication
Write-Host "Establish Active Geo-Replication" -foregroundcolor "white"
$database = Get-AzureRmSqlDatabase -DatabaseName $databasename -ResourceGroupName $resourcegroupname -ServerName $primaryservername
$database | New-AzureRmSqlDatabaseSecondary -PartnerResourceGroupName $resourcegroupname -PartnerServerName $secondaryservername -AllowConnections "All"

# ####################################################
# ##
# ##          ONLY EXECUTE ONLY TO HERE
# ##
# ####################################################

# Initiate a planned failover
Write-Host "Initiate a planned failover" -foregroundcolor "white"
$database = Get-AzureRmSqlDatabase -DatabaseName $databasename -ResourceGroupName $resourcegroupname -ServerName $secondaryservername
$database | Set-AzureRmSqlDatabaseSecondary -PartnerResourceGroupName $resourcegroupname -Failover

# Monitor Geo-Replication config and health after failover
Write-Host "Monitor Geo-Replication config and health after failover" -foregroundcolor "white"
$database = Get-AzureRmSqlDatabase -DatabaseName $databasename -ResourceGroupName $resourcegroupname -ServerName $secondaryservername
$database | Get-AzureRmSqlDatabaseReplicationLink -PartnerResourceGroupName $resourcegroupname -PartnerServerName $primaryservername

# Remove the replication link after the failover
Write-Host "Remove the replication link after the failover" -foregroundcolor "white"
$database = Get-AzureRmSqlDatabase -DatabaseName $databasename -ResourceGroupName $resourcegroupname -ServerName $secondaryservername
$secondaryLink = $database | Get-AzureRmSqlDatabaseReplicationLink -PartnerResourceGroupName $resourcegroupname -PartnerServerName $primaryservername
$secondaryLink | Remove-AzureRmSqlDatabaseSecondary