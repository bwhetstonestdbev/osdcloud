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
Write-Host -ForegroundColor Cyan "Enter domain admin password"
$securedValue = Read-Host -AsSecureString
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
                          "IsPresent":  false
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
Invoke-RestMethod https://raw.githubusercontent.com/bwhetstonestdbev/osdcloud/refs/heads/main/PostDeploy.ps1 | Out-File -FilePath 'C:\Windows\Setup\scripts\PostDeploy.ps1' -Encoding ascii -Force

Write-Host -ForegroundColor Green "Create C:\Windows\Setup\Scripts\SetupComplete.cmd"
$SetupCompleteCMD = @'
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force
Set Path = %PATH%;C:\Program Files\WindowsPowerShell\Scripts
Start /Wait PowerShell -NoL -C Install-Module AutopilotOOBE -Force -Verbose
Start /Wait PowerShell -NoL -C Install-Module OSD -Force -Verbose
Start /Wait PowerShell -NoL -C Start-OOBEDeploy
powershell.exe -NoL -ExecutionPolicy Bypass -F C:\Windows\Setup\Scripts\JoinDomain.ps1 
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="NonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <AutoLogon>
                <Password>
                    <Value>UABAAHMAcwB3ADAAcgBkAFAAYQBzAHMAdwBvAHIAZAA=</Value>
                    <PlainText>false</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <Username>SBCAdmin</Username>
            </AutoLogon>
            <DesktopOptimization>
                <ShowWindowsStoreAppsOnTaskbar>false</ShowWindowsStoreAppsOnTaskbar>
            </DesktopOptimization>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Work</NetworkLocation>
                <ProtectYourPC>3</ProtectYourPC>
            </OOBE>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>QQBkAG0AaQBuAGkAcwB0AHIAYQB0AG8AcgBQAGEAcwBzAHcAbwByAGQA</Value>
                    <PlainText>false</PlainText>
                </AdministratorPassword>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>UABAAHMAcwB3ADAAcgBkAFAAYQBzAHMAdwBvAHIAZAA=</Value>
                            <PlainText>false</PlainText>
                        </Password>
                        <Name>SBCAdmin</Name>
                        <Group>Administrators</Group>
                        <DisplayName>SBCAdmin</DisplayName>
                        <Description>Local SBC Administrator</Description>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
        </component>
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>0409:00000409</InputLocale>
            <SystemLocale>en-us</SystemLocale>
            <UILanguage>en-us</UILanguage>
            <UserLocale>en-us</UserLocale>
        </component>
    </settings>
    <cpi:offlineImage cpi:source="wim://sbcitutil1/osdcloud/install.wim#Windows 11 Pro" xmlns:cpi="urn:schemas-microsoft-com:cpi" />
</unattend>
'@

if (-NOT (Test-Path 'C:\Windows\Panther')) {
    New-Item -Path 'C:\Windows\Panther'-ItemType Directory -Force -ErrorAction Stop | Out-Null
}

$Panther = 'C:\Windows\Panther'
$UnattendPath = "$Panther\Unattend.xml"
$UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force

$Batch = @'
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Windows\Setup\scripts\PostDeploy.ps1"
pause
'@

$BatchLoc = 'C:\Users\Public\Desktop'
$BatchPath = "$BatchLoc\run.bat"
$Batch | Out-File -FilePath $BatchPath -Encoding utf8 -Width 2000 -Force

Copy-Item X:\OSDCloud\Config\Scripts\Name.txt C:\OSDCloud\Scripts -Force
Copy-Item X:\OSDCloud\Config\Scripts\pass.txt C:\OSDCloud\Scripts -Force

Restart-Computer




