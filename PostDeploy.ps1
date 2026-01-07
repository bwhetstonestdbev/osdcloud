$stampDate = Get-Date
$scriptName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $script:MyInvocation.MyCommand.Path -Leaf)))
$logFile = "$env:OSDCloud\Logs\$scriptName-" + $stampDate.ToFileTimeUtc() + ".log"
Start-Transcript -Path $logFile -NoClobber
$VerbosePreference = "Continue"

#=================================
# Script to install software and delete files needed for imaging
#=================================

#=================================
# Create Credentials for Application Deployment
#=================================
$username = 'sbc.imaging'
$pass = 'C:\OSDCloud\Scripts\pass.txt' 
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, (Get-Content $pass | ConvertTo-SecureString -AsPlainText -Force)

#=================================
#Activate Windows
#=================================

$key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
slmgr //b /ipk $key

#=================================
#Set Timezone
#=================================
Set-TimeZone -Name 'Central Standard Time'

#=================================
# Create CSV to move to domain controller with information to update AD description
#=================================
$data = @(
    [PSCustomObject]@{
        $computerName = $env:COMPUTERNAME
        $timestamp = Get-Date -Format "MM/dd/yyyy"
        $name = 'C:\OSDCloud\Scripts\uname.txt'
    }    
)
$data | Export-Csv -Path "\\sbc365adsync01\c$\Scripts\update_ad_computer_descriptiondescription_info.csv" -Credential $credentials

#=================================
# Copy Installers To Local Machine
#=================================
$installerPath = 'C:\Installers'

if(-not (Test-Path -Path $installerPath)){
    New-Item -Path $installerPath -ItemType Directory
}
else{
    Write-Host "Path exists"
}

$sourcePath = "\\sbcitutil1\OSDCloud\Installers"

try{
New-PSDrive -Name "Z" -PSProvider FileSystem -Root $sourcePath -Credential $credentials -ErrorAction Stop

Copy-Item -Path "Z:\*" -Destination $installerPath -Recurse -Force -ErrorAction Stop

}

catch{
 Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

finally {
 Remove-PSDrive -Name "Z" -Force -ErrorAction SilentlyContinue
}

#=================================
# Create AppData Directory for Diver .ini and move files over
#=================================

New-Item -Path "C:\Users\Default\AppData\Local\VirtualStore\Windows" -ItemType Directory
Move-Item -Path "C:\Installers\Newest DivePack\diver.ini" -Destination "C:\Users\Default\AppData\Local\VirtualStore\Windows"
Move-Item -Path "C:\Installers\Newest DivePack\diver-default.tpl" -Destination "C:\Users\Default\AppData\Local\VirtualStore\Windows"


#=================================
# Install Applications
#=================================

#Install Cisco VPN
Write-Host "`nStarting Cisco VPN Install..."
Start-Process msiexec.exe -ArgumentList '/i "C:\Installers\cisco-secure-client-win-5.1.4.74-core-vpn-predeploy-k9.msi" /qn /norestart' -Wait 
Write-Host "Cisco VPN Install Finished"

#Copy Cisco VPN Preferences
Write-Host "`nCopying Cisco VPN Prefrences"
Copy-Item "C:\Installers\Profiles\preferences.xml" -Destination "C:\ProgramData\Cisco\Cisco Secure Client\VPN\Profile" 

#Install .NET 8.0 Desktop Runtime (v8.0.22) for Dell Command Update
Write-Host "`nStarting .NET 8.0 Desktop Runtime Install..."
Start-Process -FilePath "C:\Installers\windowsdesktop-runtime-8.0.22-win-x64.exe" -ArgumentList "/install /quiet" -Wait
Write-Host ".NET 8.0 Desktop Runtime Install Finished"

#Install Chrome
Write-Host "`nStarting Google Chrome Install..."
Start-Process msiexec.exe -ArgumentList '/i "C:\Installers\GoogleChromeStandaloneEnterprise64.msi" /qn' -Wait
Write-Host "Google Chrome Install Finished"

#Install Acrobat Reader
Write-Host "`nStarting Adobe Acrobat Install..."
Start-Process msiexec.exe -ArgumentList '/i "C:\Installers\AcroRdrDC2500120844_en_US\AcroRead.msi" /qn' -Wait
Write-Host "Adobe Acrobat Install Finished"

#Install Dell Command Update
Write-Host "`nStarting Dell Command Update Install..."
Start-Process msiexec.exe -ArgumentList '/i "C:\Installers\DellCommandUpdateApp.msi" /qn' -Wait
Write-Host "Dell Command Update Install Finished"

#Install Teams
Write-Host "`nStarting Microsoft Teams Install..."
Start-Process -FilePath "C:\Installers\teamsbootstrapper.exe" -ArgumentList "-p" -Wait
Write-Host "Microsot Teams Install Finished"

#Install JRE 32-bit
Write-Host "`nStarting Java RE 32-bit Install..."
Start-Process -FilePath "C:\Installers\jre-8u471-windows-i586.exe" -ArgumentList "/s" -Wait
Write-Host "Java RE 32-bit Install Finished"

#Install JRE 64-bit
Write-Host "`nStarting Java RE 64-bit Install..."
Start-Process -FilePath "C:\Installers\jre-8u471-windows-x64.exe" -ArgumentList "/s" -Wait
Write-Host "Java RE 32-bit Install Finished"

#Install ProDiver
Write-Host "`nStarting ProDiver Install..."
Start-Process -FilePath "C:\Installers\Newest DivePack\ProDiver-Setup.exe" -ArgumentList "/S" -Wait
Write-Host "ProDiver Install Finished"

#Install DiveTab
Write-Host "`nStarting DiveTab Install..."
Start-Process -FilePath "C:\Installers\Newest DivePack\DiveTab-Setup-7.1.40.exe" -ArgumentList "/S" -Wait
Write-Host "DiveTab Install Finished"

#Install ASW
#Write-Host "`nStarting ASW Install..."
#Start-Process -FilePath "C:\Installers\IBMiAccess_v1r1\Windows_Application\install_acs_64_allusers.js" -Wait
#Write-Host "ASW Install Finished"

#Copy ASW shortcuts to C: drive
#Write-Host "`nMoving ASW shortcuts"
#Move-Item -Path "C:\Users\Public\Desktop\Access Client Solutions.lnk" -Destination "C:\"
#Move-Item -Path "C:\Users\Public\Desktop\ACS Session Mgr.lnk" -Destination "C:\"

#Remove Desktop Shortcuts from Public
Remove-Item -Path 'C:\Users\Public\Desktop\*' -Recurse

#Put .hod shortcut for ASW on desktop
#Move-Item -Path "C:\Installers\ASW.hod" -Destination "C:\Users\Public\Desktop"



#=================================
# Run command on remote server to apply flag to computer to install Splashtop
#=================================

Invoke-Command -ComputerName SBC365ADSYNC01 -FilePath C:\OSDCloud\UpdateExtAttribute.ps1 -Credential $Creds 


#=================================
# Post Deployment Clean Up
#=================================

#Reset Registry to not allow automatic login
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon' -Name 'AutoAdminLogon' -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon' -Name 'DefaultUserName' -Value "" -Force

#Delete OSDCloud Directory and unattend.xml 
Remove-Item -Path "C:\OSDCloud" -Recurse
Remove-Item -Path "C:\Installers" -Recurse
Remove-Item -Path "C:\Windows\Panther\unattend.xml"
Remove-Item -Path "C:\Windows\Setup\Scripts\PreDeploy.ps1"
Remove-Item -Path "C:\Windows\Setup\Scripts\PostDeploy.ps1"
Remove-Item -Path "C:\Windows\Users\Public\Desktop\run.bat"

Stop-Transcript
Restart-Computer









































