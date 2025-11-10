er #Script to deploy Windows 11 Part Time, Contractors, etc Staff (A1) shared devices.
#================================================
#   [PreOS] Update Module
#================================================
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Green "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}
#Prompt the user for secure password string we'll use later
$secureInput = Read-Host "Enter password for intune.dem" -AsSecureString
    
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
    
Write-Output "Co-worker name within computer name will be: $nameUpper"

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
    OSEdition  = "Enterprise"
    OSLanguage = "en-us"
    OSLicense  = "Retail"
    ZTI        = $true
    Firmware   = $true
}
Start-OSDCloud @Params

#================================================
#  [PostOS] OOBEDeploy Configuration
#================================================
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

#================================================
#  [PostOS] AutopilotOOBE Configuration Staging
#================================================
# AssignedComputerName needs to be blank for Self-Deploying Autopilot
#$Serial = Get-WmiObject Win32_bios | Select-Object -ExpandProperty SerialNumber
#$AssignedComputerName = "CEC-$Serial"

#Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json"
#$AutopilotOOBEJson = @"
#{
#    "AssignedComputerName" : "",
#    "AddToGroup":  "Autopilot - Device - Staff Shared Win11",
#    "Assign":  {
#                   "IsPresent":  true
#               },
#    "GroupTag":  "Staff",
#    "Hidden":  [
#                   "AddToGroup",
#                   "AssignedUser",
#                   "PostAction",
#                   "GroupTag",
#                   "Assign",
#                   "Docs"
#               ],
#    "PostAction":  "Restart",
#    "Run":  "NetworkingWireless",
#    "Title":  "CEC Autopilot Manual Register"
#}
#"@
#
#If (!(Test-Path "C:\ProgramData\OSDeploy")) {
#   New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
#}
#$AutopilotOOBEJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json" -Encoding ascii -Force

#================================================
#  [PostOS] OOBE CMD Command Line
#================================================
#Invoke-RestMethod https://raw.githubusercontent.com/caseydaviscec/osdcloud/main/Set-LenovoAssetTag.ps1 | Out-File -FilePath 'C:\Windows\Setup\scripts\set-lenovoassettag.ps1' -Encoding ascii -Force
Invoke-RestMethod https://raw.githubusercontent.com/caseydaviscec/osdcloud/refs/heads/main/Rename-Computer.ps1 | Out-File -FilePath 'C:\Windows\Setup\scripts\rename-computer.ps1' -Encoding ascii -Force
#Invoke-RestMethod https://raw.githubusercontent.com/caseydaviscec/osdcloud/refs/heads/main/Autopilot.ps1 | Out-File -FilePath 'C:\Windows\Setup\scripts\autopilot.ps1' -Encoding ascii -Force
#Invoke-RestMethod https://raw.githubusercontent.com/caseydaviscec/osdcloud/refs/heads/main/Set-LenovoBios.ps1 | Out-File -FilePath 'C:\Windows\Setup\scripts\set-lenovobios.ps1' -Encoding ascii -Force
#$OOBECMD = @'
#@echo off

# Prompt for setting Lenovo Asset Tag
#start /wait powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\set-lenovoassettag.ps1


# Below a PS session for debug and testing in system context, # when not needed 
# start /wait powershell.exe -NoL -ExecutionPolicy Bypass

#exit 
#'@
#$OOBECMD | Out-File -FilePath 'C:\Windows\Setup\scripts\oobe.cmd' -Encoding ascii -Force

#================================================
#  [PostOS] SetupComplete CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\Setup\Scripts\SetupComplete.cmd"
$SetupCompleteCMD = @'
powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\rename-computer.ps1 -Name $nameUpper
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-UnattendedJoin" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Identification>
                    <Credentials>
                      <Domain>stdbev.com</Domain>
                      <Username>intune.dem/Username>
                      <Password>$secureInput</Password>
                    </Credentials>
                    <JoinDomain>stdbev.com</JoinDomain>
                    <MachinePassword>P@ssw0rd</MachinePassword>
            </Identification>
        </component>
    </settings>
</unattend>
'@

if (-NOT (Test-Path 'C:\Windows\Panther')) {
    New-Item -Path 'C:\Windows\Panther'-ItemType Directory -Force -ErrorAction Stop | Out-Null
}

$Panther = 'C:\Windows\Panther'
$UnattendPath = "$Panther\Unattend.xml"
$UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force

Write-Host "Copying USB Drive Scripts"
Copy-Item X:\OSDCloud\Config\Scripts C:\OSDCloud\ -Recurse -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host  -ForegroundColor Green "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot





