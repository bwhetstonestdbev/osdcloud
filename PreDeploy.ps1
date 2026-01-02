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
$pass = Get-Content -Path $env:SystemDrive\OSDCloud\Scripts\pass.txt 
$SecurePassword = ConvertTo-SecureString $pass -AsPlainText -Force
$Creds = New-Object System.Management.Automation.PSCredential ("stdbev.com\sbc.imaging",$SecurePassword)

#########################
# Set Default Taskbar Settings
#########################
REG LOAD HKLM\Default C:\Users\Default\NTUSER.DAT
# Default StartMenu alignment 0=Left
New-itemproperty "HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -PropertyType Dword
REG UNLOAD HKLM\Default

#########################
# Create the computer name
#########################
$input = Get-Content -Path $env:SystemDrive\OSDCloud\Scripts\Name.txt
Write-Host -ForegroundColor Red "Rename Computer before Domain Join"
$Serial = Get-WmiObject Win32_bios | Select-Object -ExpandProperty SerialNumber
$computerName = $Serial + '-' + $input

$sourcePath = "\\sbc365adsync01\OSDCloud\"
New-PSDrive -Name "Q" -PSProvider FileSystem -Root $sourcePath -Credential $Creds -ErrorAction Stop
$computerName | Out-File -FilePath "Q:\${computerName}_log.txt" -Encoding ascii -Force

Remove-PSDrive -Name Q

#########################
# Add Computer to AD
#########################
$organizationalUnit = "OU=Computers - STDBEV,DC=stdbev,DC=com"

Add-Computer -DomainName stdbev.com -Credential $Creds -OUPath $organizationalUnit -NewName $computerName -Force -Restart

Stop-Transcript


