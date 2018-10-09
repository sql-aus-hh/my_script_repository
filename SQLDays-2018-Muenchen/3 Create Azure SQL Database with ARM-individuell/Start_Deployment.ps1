<#

.SYNOPSIS
    Deployment of AzureStack Virtual Machines

.DESCRIPTION
    Deployment of AzureStack Virtual Machines via deployment scripts

.PARAMETER subscriptionId
    The subscription id where the template will be deployed.

.PARAMETER TestTemplate
    Optional, if set to "true" the script will only test if the script/template is valid otherwise it will deploy the requested machine.
 
.EXAMPLE
   Start_Deployment.ps1 -subscriptionId "1234-5678-9012-3456-7890"

.EXAMPLE
   Start_Deployment.ps1 -subscriptionId "1234-5678-9012-3456-7890" 

.NOTES
    Version:          1.0
    Author:           Björn Peters [bjoern.peters@atos.net]

    Creation Date:    03.09.2018
    Purpose/Change:   

#>

param (

    [Parameter(Mandatory = $false)]
    [string] $subscriptionId,

    [Parameter(Mandatory = $false)]
    [string] $TestTemplate = $false

)

Begin {
    Clear-Host

    # Define Variables externally
    . ".\Variables.ps1"

    #
    # Login into Azure and define which Subscription should be used
    #
    Login-AzureRmAccount
    ####

    ## select subscription
    Write-Host "Selecting subscription : " -ForegroundColor Green -NoNewLine; Write-Host $mySubscriptionID;
    Select-AzureRmSubscription -SubscriptionID $mySubscriptionID | out-null ;

    # Define Variables externally
    $TemplateFolderName = ".\"
        
    ## Helper Functions
    Function RegisterRP {
        Param(
            [string]$ResourceProviderNamespace
        )

        Write-Host "  -  $ResourceProviderNamespace";
        try {
            Get-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace -ErrorAction Stop | Out-Null;
        }
        catch {
            Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace | Out-Null;
        }            
    }
}

Process {
    Write-Host "Generating Data for Deployment-Part" -ForegroundColor Green

    ## define Name of Resourcegroup
    $ResourceGroupName = $resourcegroupname
    $ResourceGroupLocation = $location

    ## Register RPs
    $resourceProviders = @("microsoft.compute", "microsoft.devtestlab", "microsoft.storage", "microsoft.network");
    if ($resourceProviders.length) {
        Write-Host "Registering resource providers" -ForegroundColor Green
        foreach ($resourceProvider in $resourceProviders) {
            RegisterRP($resourceProvider);
        }
    }

    ## Create or check for existing resource group
    $ResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (!$ResourceGroup) {
        Write-Host "ResourceGroup '" -ForegroundColor Green -NoNewline; Write-Host $ResourceGroupName -NoNewline; Write-Host "' does not exist. We're creating one for this..." -ForegroundColor Green;
        Write-Host "Creating resource group '" -ForegroundColor Green -NoNewline; Write-Host $ResourceGroupName -NoNewline; Write-Host "' in location '" -ForegroundColor Green -NoNewline; Write-Host $ResourceGroupLocation;
        New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation | Out-Null
    } else {
        Write-Host "Using existing resource group '" -ForegroundColor Green -NoNewline; Write-Host $ResourceGroupName -NoNewline; Write-Host "' and updating Tags" -ForegroundColor Green;
    }

    ## Start the deployment
    Write-Host "Starting deployment..." -ForegroundColor Green;
    
    ## Define Deployment-Parameter
    $TemplateFilePath = $TemplateFolderName+"\template.json"

    $parameters  = @{
        "administratorLogin" = $adminlogin;
        "administratorLoginPassword" = $password;
        "collation"="SQL_Latin1_General_CP1_CI_AS";
        "databaseName"="db-azuresqldb-demos-ARM-indi";
        "tier"="Standard";
        "skuName"="S0";
        "location"="eastus2";
        "maxSizeBytes"=268435456000;
        "serverName"="server-azuresqldb-demos-arm-indi";
        "sampleName"="";
        "zoneRedundant"=$false;
        "licenseType"="";
        "enableATP"=$false;
        "allowAzureIps"=$true;
    }

    ## Deployment
    if ($TestTemplate -eq "$true") {
        Write-Host "Just testing if template and parameters are valid." -ForegroundColor Green
        Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath -TemplateParameterObject $parameters 
        Write-Host "Das ARM-Template wurde erfolgreich getestet." -ForegroundColor Green;
    } else {
        Write-Host "Deploying the requested template and parameters." -ForegroundColor Green
        New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath -TemplateParameterObject $parameters | Out-Null
        ## Checking the status of the deployment
        $status = $(Get-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName).ProvisioningState
        if ($status -eq 'Succeeded') {
            Write-Host "Das ARM-Template wurde mit Powershell erfolgreich verarbeitet." -ForegroundColor Green;
        }        
    }
}
End {}