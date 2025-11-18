if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Green "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

# Prompt the user to enter the name of the co-worker the computer will be assigned to for the computer name
    
Write-Host -ForegroundColor Cyan "Enter name of co-worker using this computer:"
$user = Read-Host
$firstName, $lastName = $user -Split " "
$firstNameTrim = $firstName[0]
    if ($lastName.Length -ge 5){
        $lastNameTrim = $lastName.Substring(0,5)
    }

    else {$lastNameTrim = $lastName}
    $nameUpper = ("$firstNameTrim$lastNameTrim").ToUpper()
    $nameUpper | Out-File -FilePath "X:\OSDCloud\Config\Scripts\Name.txt" -Encoding ascii -Force
    
Write-Output "Co-worker name within computer name will be: $nameUpper"

#Get password for domain admin, convert to plain text and store in a text file that can be accessed by the script to join domain
$securedValue = Read-Host "Enter domain admin password" -AsSecureString
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securedValue)
$value = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
$value | Out-File -FilePath "X:\OSDCloud\Config\Scripts\pass.txt" -Encoding ascii -Force

Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
$Params = @{
    OSVersion  = "Windows 11"
    OSBuild    = "25H2"
    OSEdition  = "Pro"
    OSLanguage = "en-us"
    OSLicense  = "Volume"
    ZTI        = $true
    Firmware   = $true
}
Start-OSDCloud @Params

Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json"
$OOBEDeployJson = @'
{
    "AddNetFX3":  {
                      "IsPresent":  true
                  },
    "Autopilot":  {
                      "IsPresent":  false
                  },
    "RemoveAppx":  [
                    "Microsoft.BingWeather",
                    "Microsoft.BingNews",
                    "Microsoft.GamingApp",
                    "Microsoft.GetHelp",
                    "Microsoft.Getstarted",
                    "Microsoft.Messaging",
                    "Microsoft.MicrosoftOfficeHub",
                    "Microsoft.MicrosoftSolitaireCollection",
                    "Microsoft.MicrosoftStickyNotes",
                    "Microsoft.People",
                    "Microsoft.PowerAutomateDesktop",
                    "Microsoft.StorePurchaseApp",
                    "Microsoft.Todos",
                    "microsoft.windowscommunicationsapps",
                    "Microsoft.WindowsFeedbackHub",
                    "Microsoft.WindowsMaps",
                    "Microsoft.Xbox.TCUI",
                    "Microsoft.XboxGameOverlay",
                    "Microsoft.XboxGamingOverlay",
                    "Microsoft.XboxIdentityProvider",
                    "Microsoft.XboxSpeechToTextOverlay",
                    "Microsoft.YourPhone",
                    "Microsoft.ZuneMusic",
                    "Microsoft.ZuneVideo"
                   ],
    "UpdateDrivers":  {
                          "IsPresent":  true
                      },
    "UpdateWindows":  {
                          "IsPresent":  true
                      }
}
'@
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$OOBEDeployJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json" -Encoding ascii -Force

Invoke-RestMethod https://raw.githubusercontent.com/bwhetstonestdbev/osdcloud/refs/heads/main/JoinDomain.ps1 | Out-File -FilePath 'C:\Windows\Setup\scripts\JoinDomain.ps1' -Encoding ascii -Force

Write-Host -ForegroundColor Green "Create C:\Windows\Setup\Scripts\SetupComplete.cmd"
$SetupCompleteCMD = @'
powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\JoinDomain.ps1 
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

Copy-Item D:\unattend.xml C:\Windows\Panther -Force
Copy-Item X:\OSDCloud\Config\Scripts\Name.txt C:\OSDCloud\Scripts -Force
Copy-Item X:\OSDCloud\Config\Scripts\pass.txt C:\OSDCloud\Scripts -Force

Restart-Computer
