# Set the resource group name and location for your server
$resourcegroupname = "RG-Demo-Azure-SQL-DB"
$location = "east us 2"
# Set an admin login and password for your server
$adminlogin = "dbadmin"
$password = "Community@2018"
# Set server name - the logical server name has to be unique in the system
$servername = "server-community-demos"
# The sample database name
$databasename = "db-community-demos-powershell"
#The FirewallRule Name
$FirewallRuleName = $databasename+"-"+$(Get-Random)

# The new performance level - DemoScript - Resize
$newdbDTUsize = "S0"

# "Pause" database by dropping/recreate - database demo name
$databasename_pause = "db-backup-demo"
$servername_pause = "server-backup-demo"

# "LTR" servername/databasename
$databasename_ltr = "db-workload-demo"
$servername_ltr = "server-workload-demo"

# Workload-Table
$StorageAccountName = ""
$StorageAccountKey = ""
$tabName = ""

# Credential
$cred_username = ""
$cred_password = ""

# Variables for SQL Server VM
## Global
$prefix = "sqlvm"

## Storage
$sqlvm_storagename = $prefix + "storage"
$sqlvm_storagesku = "Premium_LRS"

## Network
$sqlvm_interfacename = $prefix + "serverinterface"
$sqlvm_vnetname = $prefix + "vnet"
$sqlvm_subnetname = "Default"
$sqlvm_VNetAddressPrefix = "10.0.0.0/16"
$sqlvm_VNetSubnetAddressPrefix = "10.0.0.0/24"
$sqlvm_TCPIPAllocationMethod = "Dynamic"
$sqlvm_domainname = $prefix + "domain"

##Compute
$sqlvm_vmname = "Demo-SQLSRV01"
$sqlvm_computername = $sqlvm_vmname
$sqlvm_size = "Standard_DS4"
$sqlvm_osdiskname = $VMName + "OSDisk"

##Image
$sqlvm_publishername = "MicrosoftSQLServer"
$sqlvm_offername = "SQL2016SP2-WS2016"
$sqlvm_sku = "Standard"
$sqlvm_version = "latest"