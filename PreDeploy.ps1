#########################
# Enable loggimg
#########################
$stampDate = Get-Date
$scriptName = ([System.IO.Path]::GetFileNameWithoutExtension($(Split-Path $script:MyInvocation.MyCommand.Path -Leaf)))
$logFile = "$env:OSDCloud\Logs\$scriptName-" + $stampDate.ToFileTimeUtc() + ".log"
Start-Transcript -Path $logFile -NoClobber
$VerbosePreference = "Continue"

#########################
# Create Credentials
#########################
$key = Get-Content -Path $env:SystemDrive\OSDCloud\Scripts\key.txt
$SecurePassword = Get-Content -Path $env:SystemDrive\OSDCloud\Scripts\pass.txt | ConvertTo-SecureString -Key $Key
$Creds = New-Object System.Management.Automation.PSCredential ("stdbev.com\sbc.imaging",$SecurePassword)

#########################
# Set Default Taskbar Settings
#########################
REG LOAD HKLM\Default C:\Users\Default\NTUSER.DAT
# Default StartMenu alignment 0=Left
New-itemproperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -PropertyType Dword
REG UNLOAD HKLM\Default

#########################
# Create the desired computer name, and create CSV with data we'll use for active directory information later
#########################
$input = Get-Content -Path $env:SystemDrive\OSDCloud\Scripts\Name.txt
$Serial = Get-WmiObject Win32_bios | Select-Object -ExpandProperty SerialNumber
$computerName = $Serial + '-' + $input

$computerName | Out-File -FilePath "C:\OSDCloud\Scripts\DesiredCPUName.txt" -Encoding ascii -Force

#########################
# Add Computer to AD
#########################
$organizationalUnit = "OU=Computers - STDBEV,DC=stdbev,DC=com"

Add-Computer -DomainName stdbev.com -Credential $Creds -OUPath $organizationalUnit -NewName $computerName -Force -Restart

Stop-Transcript






