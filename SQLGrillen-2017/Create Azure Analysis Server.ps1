#
# Create Azure Analysis Services using AzureRM.AnalysisServices
# Author : Bjoern Peters (info@sql-aus-hamburg.de)
#

$azureAccountName = "1234567-1234-1234-1234-012345678912"
$azurePassword = ConvertTo-SecureString "SQLGrillen@2017" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

Add-AzureRmAccount -Credential $psCred -ServicePrincipal -TenantId "1234567-1234-1234-1234-012345678912"

$myResourceGroupName = 'SQLGrillen2017'
$mySubscriptionID = '1234567-1234-1234-1234-012345678912'
$myLocation = 'West Europe'
$myAAServerName = 'asbeer02'

Set-AzureRmContext -SubscriptionId $mySubscriptionID

Get-AzureRmResourceGroup -Name $myResourceGroupName -ev notPresent -ea 0
if ($notPresent) {
    New-AzureRmResourceGroup -Name $myResourceGroupName -Location $myLocation
} else {
    write-host "ResourceGroup already exists"
}

Get-AzureRmAnalysisServicesServer -ResourceGroupName $myResourceGroupName -Name $myAAServerName -ev notPresent -ea 0
if ($notPresent) {
    New-AzureRmAnalysisServicesServer -ResourceGroupName $myResourceGroupName -Name $myAAServerName -Location $myLocation -Sku "S2" -Administrator "your-adress@test-url.de"
} else {
    write-host "AAS Server already exists"
}