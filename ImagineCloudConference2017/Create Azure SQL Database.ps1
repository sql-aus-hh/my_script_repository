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
$location = "west us"
# Set an admin login and password for your server
$adminlogin = "dbadmin"
$password = "Imagine@2017"
# Set server name - the logical server name has to be unique in the system
$servername = "server-sqldbdemo"
# The sample database name
$databasename = "db-sqldbdemo"
#The FirewallRule Name
$FirewallRuleName = $databasename+"-"+$(Get-Random)
# The ip address range that you want to allow to access your server
$clientIP = (Invoke-WebRequest ifconfig.me/ip).Content
$startip = $clientIP.replace("`n","").replace("`r","")
$endip = $clientIP.replace("`n","").replace("`r","")

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
Get-AzureRmSqlServer -ResourceGroupName $resourcegroupname -ServerName $servername -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host $servername "does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $server = New-AzureRmSqlServer -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force)) | Out-null
    Write-Host $servername "successfully created" -foregroundcolor "white"
} else {
    Write-Host $servername "already exists" -ForegroundColor "green"
}

# Create a server firewall rule that allows access from the specified IP range
Get-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname -ServerName $servername -FirewallRuleName $FirewallRuleName -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host "FirewallRule does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $serverfirewallrule = New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -FirewallRuleName $FirewallRuleName -StartIpAddress "$startip" -EndIpAddress "$endip" | Out-null
    Write-Host "FirewallRule successfully created" -foregroundcolor "white"
} else {
    Write-Host "FirewallRule already exists"
}

# Create a blank database with an S0 performance level
Get-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename -ev notPresent -ea 0 | out-null
if ($notPresent) {
    Write-Host "Database" $databasename "does not exist... have to create it..." -foregroundcolor "DarkYellow"
    $database = New-AzureRmSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -DatabaseName $databasename `
    -RequestedServiceObjectiveName "S0" `
    -SampleName "AdventureWorksLT" | Out-null
    Write-Host "Database" $databasename "successfully created" -foregroundcolor "white"
} else {
    Write-Host "Database" $databasename "already exists"
}

Write-Host "Connect to : '$servername.database.windows.net' with '"$adminlogin"' and '"$password"'"

# Clean up deployment 
# Remove-AzureRmResourceGroup -ResourceGroupName $resourcegroupname -force