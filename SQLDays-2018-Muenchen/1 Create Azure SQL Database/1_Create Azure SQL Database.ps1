Clear-Host

# Define Variables externally
. ".\Variables.ps1"

#
# Login into Azure and define which Subscription should be used
#
Login-AzureRmAccount
####

Set-AzureRmContext -SubscriptionId $mySubscriptionID | Out-null

# The ip address range that you want to allow to access your server
$clientIP = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$startip = $clientIP.replace("`n","").replace("`r","")
$endip = $clientIP.replace("`n","").replace("`r","")

#
#   Process
#

# Start
Write-Host "Starting with 'Create Azure SQL Database'" -foregroundcolor "white"
Write-Host "Checking if Resourcegroup exist..." -foregroundcolor "white"

# Create a resource group
Get-AzureRmResourceGroup -Name $resourcegroupname -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host $resourcegroupname "does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $resourcegroup = New-AzureRmResourceGroup -Name $resourcegroupname -Location $location | Out-null
    Write-Host $resourcegroupname "successfully created" -foregroundcolor "white"
} else {
    Write-Host $resourcegroupname "already exists" -foregroundcolor "green"
}

# Create a server with a system wide unique server name
Get-AzureRmSqlServer -ResourceGroupName $resourcegroupname -ServerName $servername_demo -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host $servername_demo "does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $server = New-AzureRmSqlServer -ResourceGroupName $resourcegroupname `
    -ServerName $servername_demo `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force)) | Out-null
    Write-Host $servername_demo "successfully created" -foregroundcolor "white"
} else {
    Write-Host $servername_demo "already exists" -ForegroundColor "green"
}

# Create a server firewall rule that allows access from the specified IP range
Get-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname -ServerName $servername_demo -FirewallRuleName $FirewallRuleName -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host "FirewallRule does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $serverfirewallrule = New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname `
    -ServerName $servername_demo `
    -FirewallRuleName $FirewallRuleName -StartIpAddress "$startip" -EndIpAddress "$endip" | Out-null
    Write-Host "FirewallRule successfully created" -foregroundcolor "white"
} else {
    Write-Host "FirewallRule already exists"
}

# Create a server firewall rule that allows access from the specified IP range
Get-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname -ServerName $servername_demo -FirewallRuleName "AllowAllWindowsAzureIps" -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host "FirewallRule for all Azure Services does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $serverfirewallrule = New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname `
    -ServerName $servername_demo `
    -FirewallRuleName "AllowAllWindowsAzureIps" -StartIpAddress "0.0.0.0" -EndIpAddress "0.0.0.0" | Out-null
    Write-Host "FirewallRule for all Azure Services successfully created" -foregroundcolor "white"
} else {
    Write-Host "FirewallRule already exists"
}

# Create a blank database with an S0 performance level
Get-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername_demo -DatabaseName $databasename_demo -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host "Database" $databasename_demo "does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $database = New-AzureRmSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $servername_demo `
    -DatabaseName $databasename_demo `
    -RequestedServiceObjectiveName "S0" `
    -SampleName "AdventureWorksLT" | Out-null
    Write-Host "Database" $databasename "successfully created" -foregroundcolor "white"
} else {
    Write-Host "Database" $databasename "already exists"
}

try {
    Get-AzureRmSqlServerActiveDirectoryAdministrator -ResourceGroupName $resourcegroupname -ServerName $servername_demo -ErrorAction Stop | Out-Null
    Write-Host "AAD SQL Server Admin Account already exists on $servername_demo, no more actions needed " -ForegroundColor Green
}
catch {
    Set-AzureRmSqlServerActiveDirectoryAdministrator -ResourceGroupName $resourcegroupname -ServerName $servername_demo -DisplayName "Björn Peters" -ObjectId "c473bd03-fdf4-4633-8bcd-1888a0a40440"
    Write-Host "AAD SQL Server Admin Account must be set for AzureSQLDB-Server $servername_demo" -ForegroundColor DarkGreen
}

Write-Host "Connect to : '$servername_demo.database.windows.net' with '$adminlogin' and '$password'"

# Clean up deployment 
# Remove-AzureRmResourceGroup -ResourceGroupName $resourcegroupname -force