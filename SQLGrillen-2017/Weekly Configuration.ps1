#
# Automatically pause/resume and scale up/down Azure Analysis Services using AzureRM.AnalysisServices
# Author : Rui Rumano
#
# https://ruiromanoblog.wordpress.com/2017/05/06/automatically-pauseresume-and-scale-updown-your-azure-analysis-services-using-azurerm-analysisservices/
#

param(     
    [string] $resourceGroupName = "SQLGrillen2017",
    [string] $serverName = "asbeer01",
    [string] $configStr = "
                            [
                                {
                                    WeekDays:[1,2,3,4,5]	
                                    ,StartTime: ""08:00:00""
                                    ,StopTime: ""17:59:59""
                                    ,Sku: ""S2""
                                }
                                ,
                                {
                                    WeekDays:[1,2,3,4,5]	
                                    ,StartTime: ""18:00:00""
                                    ,StopTime: ""23:59:59""
                                    ,Sku: ""S1""
                                }
                                ,
                                {
                                    WeekDays:[6, 0]	
                                    ,StartTime: ""08:00:00""
                                    ,StopTime: ""23:59:59""
                                    ,Sku: ""S1""
                                }    
                            ]
                        "
)

$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

Import-Module "AzureRM.AnalysisServices" 

Write-Verbose "Logging in to Azure..."

$azureAccountName = "1234567-1234-1234-1234-012345678912"
$azurePassword = ConvertTo-SecureString "SQLGrillen@2017" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

Add-AzureRmAccount -Credential $psCred -ServicePrincipal -TenantId "1234567-1234-1234-1234-012345678912"

$stateConfig = $configStr | ConvertFrom-Json
$startTime = Get-Date
$currentDayOfWeek = [Int]($startTime).DayOfWeek

# Find a match in the config
$dayObjects = $stateConfig | Where-Object {$_.WeekDays -contains $currentDayOfWeek } `
    | Select-Object Sku, @{Name="StartTime"; Expression = {[datetime]::ParseExact($_.StartTime,"HH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture)}}, @{Name="StopTime"; Expression = {[datetime]::ParseExact($_.StopTime,"HH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture)}}

# Get the server status
$asServer = Get-AzureRmAnalysisServicesServer -ResourceGroupName $resourceGroupName -Name $serverName
Write-Verbose "Current Azure AS status: $($asServer.State)"

# If not match any day then exit
if($dayObjects -ne $null){
    # Can't treat several objects for same time-frame, if there's more than one, pick first
    $matchingObject = $dayObjects | Where-Object { ($startTime -ge $_.StartTime) -and ($startTime -lt $_.StopTime) } | Select-Object -First 1
    if($matchingObject -ne $null) {
        Write-Verbose "Is in active hours"

        # if Paused resume
        if($asServer.State -eq "Paused") {
            $asServer | Resume-AzureRmAnalysisServicesServer -Verbose
        }        
    
        # Change the SKU if needed
        if($asServer.Sku.Name -ne $matchingObject.Sku) {
            Write-Verbose "Updating AAS server from $($asServer.Sku.Name) to $($matchingObject.Sku)"
            #$asServer | Set-AzureRmAnalysisServicesServer -Sku $matchingObject.Sku
            Set-AzureRmAnalysisServicesServer -Name $asServer.Name -ResourceGroupName $resourceGroupName -Sku $matchingObject.Sku -Verbose
        }
    } else {
        Write-Verbose "Is in offline hours"
        if($asServer.State -eq "Succeeded") {
            $asServer | Suspend-AzureRmAnalysisServicesServer -Verbose
        } 
    }
} else {
    Write-Verbose "No object config for current day of week"
    if($asServer.State -eq "Succeeded") {
        $asServer | Suspend-AzureRmAnalysisServicesServer -Verbose
    }         
}