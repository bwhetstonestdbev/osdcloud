Write-Host -ForegroundColor Green "Starting OSDCloud"
Start-Sleep -Seconds 5

#Make sure I have the latest OSD Content
Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force

#Start OSDCloudScriptPad
Write-Host -ForegroundColor Green "Start CEC Windows Imaging"
Start-OSDPad -RepoOwner bwhetstonestdbev -RepoName osdcloud -repofolder Deploy -BrandingTitle 'Standard Beverage' -Color Blue -Hide Script

