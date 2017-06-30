clear
#
# Login into Azure and define which Subscription should be used
#
$onedrive = (Get-Content Env:\USERPROFILE)+"\Onedrive"
.$onedrive"\SQL-aus-Hamburg\Demos"\Azure_Automation_Login_MVPSubscription.ps1
Login
####

Set-AzureRmContext -SubscriptionId $mySubscriptionID

#
#   Process
#
# Login-AzureRmAccount
# Set the resource group name and location for your server
$resourcegroupname = "RG-AzureSQLDatabase-Demo"
$location = "west europe"
# Set an admin login and password for your server
$adminlogin = "dbadmin"
$password = "DemoPwd@2017"
# Set server name - the logical server name has to be unique in the system
$servername = "server-sqldbdemo"
# The sample database name
$databasename = "db-sqldbdemo"
# The ip address range that you want to allow to access your server
$clientIP = (Invoke-WebRequest ifconfig.me/ip).Content
$startip = $clientIP
$endip = $clientIP

# Create a resource group
Get-AzureRmResourceGroup -Name $resourcegroupname -ev notPresent -ea 0
if ($notPresent) {
    $resourcegroup = New-AzureRmResourceGroup -Name $resourcegroupname -Location $location
} else {
    Write-Host $resourcegroupname "already exists"
}

# Create a server with a system wide unique server name
Get-AzureRmSqlServer -ResourceGroupName $resourcegroupname -ServerName $servername -ev notPresent -ea 0
if ($notPresent) {
    $server = New-AzureRmSqlServer -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))
} else {
    Write-Host $servername "already exists"
}

# Create a server firewall rule that allows access from the specified IP range
Get-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname -ServerName $servername -FirewallRuleName "AllowedIPs" -ev notPresent -ea 0
if ($notPresent) {
    $serverfirewallrule = New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -FirewallRuleName "AllowedIPs" -StartIpAddress $startip -EndIpAddress $endip
} else {
    Write-Host "FirewallRule already exists"
}

# Create a blank database with an S0 performance level
Get-AzureRmSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename -ev notPresent -ea 0
if ($notPresent) {
    $database = New-AzureRmSqlDatabase  -ResourceGroupName $resourcegroupname `
    -ServerName $servername `
    -DatabaseName $databasename `
    -RequestedServiceObjectiveName "S0" `
    -SampleName "AdventureWorksLT"
} else {
    Write-Host "Database" $databasename "already exists"
}

# Clean up deployment 
# Remove-AzureRmResourceGroup -ResourceGroupName $resourcegroupname