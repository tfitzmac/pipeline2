#Requires -Version 3.0
#Requires -Module Az.Resources

Param(
    [string] [Parameter(Mandatory = $true)][alias("ResourceGroupLocation")] $Location,
    [string] $ResourceGroupName,
    [string] $TemplateFile,
    [string] $TemplateParametersFile,
    [string] $Mode = "Incremental",
    [string] $DeploymentName = ((Split-Path $TemplateFile -LeafBase) + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm'))
)


$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

$TemplateArgs = New-Object -TypeName Hashtable

$TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateFile))
$TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile))

$TemplateArgs.Add('TemplateFile', $TemplateFile)

if(Test-Path $TemplateParametersFile){
    $TemplateArgs.Add('TemplateParameterFile', $TemplateParametersFile)
}

# Create the resource group only when it doesn't already exist - and only in RG scoped deployments
if ((Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue) -eq $null) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -Force -ErrorAction Stop
}

New-AzResourceGroupDeployment -Name $DeploymentName `
            -ResourceGroupName $ResourceGroupName `
            @TemplateArgs 
