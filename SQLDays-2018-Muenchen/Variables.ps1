# Set the resource group name and location for your server
$resourcegroupname = 'RG-Demo-Azure-SQL-DB'
$location = 'east us 2'
# Set an admin login and password for your server
$adminlogin = 'dbadmin'
$password = 'Community@2018'
# Set server name - the logical server name has to be unique in the system
$servername_demo = 'server-azuresqldb-demos'
# The sample database name
$databasename_demo = 'db-azuresqldb-demos-powershell'
#The FirewallRule Name
$FirewallRuleName = $databasename+'-'+$(Get-Random)

# The new performance level - DemoScript - Resize
$newdbDTUsize = 'S0'

# 'Pause' database by dropping/recreate - database demo name
$databasename_backup = 'db-backup-demo'
$servername_backup = 'server-backup-demo'

# 'LTR' servername/databasename
$databasename_workload = 'db-workload-demo'
$servername_workload = 'server-workload-demo'

# Powershell Deployment Demo
$databasename_powershell = 'db-powershell-demo'
$servername_powershell = 'server-powershell-demo'

## GeoRedudance
$primarylocation = $location
$primaryservername = $servername_demo
$secondarylocation = "southcentralus"
$secondaryservername = "server-azuresqldb-secondary"

# Workload-Table
$StorageAccountName = 'demosqldb'
$StorageAccountKey = 'WBpt6GWXImIlXjcBp2ifVjZIpy3oh4b+6dXNMjhFaUPWl5p557vz/h07m9IIikKuzKuX6V+H90ByPRPzcexT5Q=='
$tabName = 'TableWorkloadDemo'

# Credential
$automation_account = 'azure-automation'
$cred_username = 'cred-azure-automation'

# Variables for SQL Server VM
## Global
$prefix = 'sqlvm'

## Storage
$sqlvm_storagename = $prefix + 'storage'
$sqlvm_storagesku = 'Premium_LRS'

## Network
$sqlvm_interfacename = $prefix + 'serverinterface'
$sqlvm_vnetname = $prefix + 'vnet'
$sqlvm_subnetname = 'Default'
$sqlvm_VNetAddressPrefix = '10.0.0.0/16'
$sqlvm_VNetSubnetAddressPrefix = '10.0.0.0/24'
$sqlvm_TCPIPAllocationMethod = 'Dynamic'
$sqlvm_domainname = $prefix + 'domain'

##Compute
$sqlvm_vmname = 'Demo-SQLSRV01'
$sqlvm_computername = $sqlvm_vmname
$sqlvm_size = 'Standard_D4s_v3'
$sqlvm_osdiskname = $VMName + 'OSDisk'

##Image
$sqlvm_publishername = 'MicrosoftSQLServer'
$sqlvm_offername = 'SQL2016SP2-WS2016'
$sqlvm_sku = 'Standard'
$sqlvm_version = 'latest'

##VM Shutdown Options
$shutdown_time = '1900'
$shutdown_timezone = 'W. Europe Standard Time'

#OMS
$OMSWorkspaceName = 'azuresqldemo'
$SQLResourceGroup = $resourcegroupname
$OMSResourceGroup = $resourcegroupname

#Github
$git_user = 'info@sql-aus-hamburg.de'
$git_pwd = 'Kimob_01'