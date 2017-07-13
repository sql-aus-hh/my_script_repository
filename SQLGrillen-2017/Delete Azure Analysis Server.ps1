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
$myAAServerName = 'aaserver01'

Get-AzureRmAnalysisServicesServer -ResourceGroupName $myResourceGroupName -Name $myAAServerName -ev notPresent -ea 0
if ($notPresent) {
    write-host "AAS Server does not exists"
} else {
    Remove-AzureRmAnalysisServicesServer -ResourceGroupName $myResourceGroupName -Name $myAAServerName
}

Get-AzureRmResourceGroup -Name $myResourceGroupName -ev notPresent -ea 0
if ($notPresent) {
    write-host "ResourceGroup doesn't exist"
} else {
    Remove-AzureRmResourceGroup -Name $myResourceGroupName -Force
}