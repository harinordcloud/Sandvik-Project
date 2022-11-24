
$webhookReceiver = New-AzActionGroupReceiver `
                -Name 'Azure::AzureInfra::Prod::Gold::Critical::UK' `
                -WebhookReceiver `
                -ServiceUri 'https://events.pagerduty.com/URI INTEGRATION LINK'



  
$rgName = 'RG-UK-FME'
Set-AzActionGroup `
    -Name "AC-UK-FME-GOLD-AG" `
    -ShortName "FME-GOLD" `
    -ResourceGroupName $rgName `
    -Receiver $webhookReceiver






