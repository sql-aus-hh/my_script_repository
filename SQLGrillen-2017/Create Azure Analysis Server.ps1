Clear-Host

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

$myResourceGroupName = 'SQLPASS'
$myLocation = 'West Europe'
$myAAServerName = 'aaserver01'

Get-AzureRmResourceGroup -Name $myResourceGroupName -ev notPresent -ea 0
if ($notPresent) {
    New-AzureRmResourceGroup -Name $myResourceGroupName -Location $myLocation
} else {
    write-host "ResourceGroup already exists"
}

Get-AzureRmAnalysisServicesServer -ResourceGroupName $myResourceGroupName -Name $myAAServerName -ev notPresent -ea 0
if ($notPresent) {
    New-AzureRmAnalysisServicesServer -ResourceGroupName $myResourceGroupName -Name $myAAServerName -Location $myLocation -Sku "S1" -Administrator "info@sql-aus-hamburg.de"
} else {
    write-host "AAS Server already exists"
}