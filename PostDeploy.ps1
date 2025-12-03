$stampDate = Get-Date
$scriptName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $script:MyInvocation.MyCommand.Path -Leaf)))
$logFile = "$env:OSDCloud\Logs\$scriptName-" + $stampDate.ToFileTimeUtc() + ".log"
Start-Transcript -Path $logFile -NoClobber
$VerbosePreference = "Continue"

#=================================
#Post Image Deploy Cleanup
#=================================

#=================================
# Create Credentials for Application Deployment
#=================================
$username = 'intune.dem'
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
# Install Applications
#=================================

#Install Cisco VPN
Start-Process msiexec.exe -ArgumentList '/i "C:\Installers\cisco-secure-client-win-5.1.4.74-core-vpn-predeploy-k9.msi" /qn /norestart' -Wait 

#Copy Cisco VPN Preferences
Copy-Item "C:\Installers\Profiles\preferences.xml" -Destination "C:\ProgramData\Cisco\Cisco Secure Client\VPN\Profile" 


#Install Chrome
Start-Process msiexec.exe -ArgumentList '/i "C:\Installers\GoogleChromeStandaloneEnterprise64.msi" /qn' -Wait

#Install Acrobat Reader
Start-Process msiexec.exe -ArgumentList '/i "C:\Installers\AcroRdrDC2500120844_en_US\AcroRead.msi" /qn' -Wait

#Install Dell Command Update
Start-Process msiexec.exe -ArgumentList '/i "C:\Installers\DellCommandUpdateApp.msi" /qn' -Wait

#Install Teams
Start-Process -FilePath "C:\Installers\teamsbootstrapper.exe" -ArgumentList "-p" -Wait

#Install JRE 32-bit
Start-Process -FilePath "C:\Installers\jre-8u471-windows-i586.exe" -ArgumentList "/s" -Wait

#Install JRE 64-bit
Start-Process -FilePath "C:\Installers\jre-8u471-windows-x64.exe" -ArgumentList "/s" -Wait

#Install ASW
Start-Process -FilePath "C:\Installers\IBMiAccess_v1r1\Windows_Application\install_acs_32_allusers.js" -Wait
Move-Item -Path "C:\Users\Public\Desktop\Access Client Solutions.lnk" -Destination "C:\"
Move-Item -Path "C:\Users\Public\Desktop\ACS Session Mgr.lnk" -Destination "C:\"
Move-Item -Path "C:\Installers\ASW.hod" -Destination "C:\Users\Public\Desktop"


#=================================
# Post Deployment Clean Up
#=================================

#Reset Registry to not allow automatic login
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon' -Name 'AutoAdminLogon' -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon' -Name 'DefaultUserName' -Value "" -Force

#Delete OSDCloud Directory and unattend.xml 
#Remove-Item -Path "C:\OSDCloud" -Recurse
#Remove-Item -Path "C:\Windows\Panther\unattend.xml"
#Remove-Item -Path "C:\Windows\Setup\Scripts\JoinDomain.ps1"
#Remove-Item -Path "C:\Users\Public\Desktop\PostDeploy.ps1"

Stop-Transcript
#Restart-Computer



















