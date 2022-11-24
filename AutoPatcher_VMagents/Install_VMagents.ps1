#Azure Subscription 
$subscriptionId = ""
Set-AzContext -Subscription $subscriptionId

$output =""

#Resource Group for VMs 
$resourceGroup = "RG-UK-CTERA-SD"

#get running VMs in RG
$myAzureVMs = Get-AzVM -ResourceGroupName $resourceGroup -status | Where-Object {$_.PowerState -eq "VM running"}

# for paralel processing: 
# $myAzureVMs | ForEach-Object -Parallel {

$myAzureVMs | ForEach-Object  {

    if ($_.StorageProfile.OSDisk.OSType -eq "Linux") {
        $out = Invoke-AzVMRunCommand `
                -ResourceGroupName $_.ResourceGroupName `
                 -Name $_.Name  `
                -CommandId 'RunShellScript' `
                -ScriptPath .\autopatcher_linux.sh
    }
    elseif ($_.StorageProfile.OSDisk.OSType -eq "Windows") {
        $out = Invoke-AzVMRunCommand `
                -ResourceGroupName $_.ResourceGroupName `
                -Name $_.Name  `
                -CommandId 'RunPowerShellScript' `
                -ScriptPath .\autopatcher_win.ps1
    }
    #Formating the Output with the VM name
    $output = $_.Name + " " + $out.Value[0].Message
    $output   
}
