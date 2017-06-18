#
# Pause/Resume Azure Analysis Services using AzureRM.AnalysisServices
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

# Pause AAS
Get-AzureRmAnalysisServicesServer -ResourceGroupName $myResourceGroupName -Name $myAAServerName -ev notPresent -ea 0
if ($notPresent) {
    write-host "AAS Server does not exists"
} else {
    #Suspend-AzureRmAnalysisServicesServer -Name $myAAServerName -ResourceGroupName $myResourceGroupName
}

# Resume AAS
Get-AzureRmAnalysisServicesServer -ResourceGroupName $myResourceGroupName -Name $myAAServerName -ev notPresent -ea 0
if ($notPresent) {
    write-host "AAS Server does not exists"
} else {
    Resume-AzureRmAnalysisServicesServer -Name $myAAServerName -ResourceGroupName $myResourceGroupName
}