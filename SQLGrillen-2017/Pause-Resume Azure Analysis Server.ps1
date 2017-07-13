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