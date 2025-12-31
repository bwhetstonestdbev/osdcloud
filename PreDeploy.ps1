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
# Create the computer name and store it on ADSync Server so we can access it later
#########################
$sourcePath = "\\sbc365adsync01\OSDCloud\"
New-PSDrive -Name "Q" -PSProvider FileSystem -Root $sourcePath -Credential $Creds -ErrorAction Stop

$input = Get-Content -Path $env:SystemDrive\OSDCloud\Scripts\Name.txt
Write-Host -ForegroundColor Red "Rename Computer before Domain Join"
$Serial = Get-WmiObject Win32_bios | Select-Object -ExpandProperty SerialNumber
$computerName = $Serial + '-' + $input
$computerName | Out-File -FilePath "Q:\${computerName}_log.txt" -Encoding ascii -Force

Remove-PSDrive -Name Q

#########################
# See if computer exists in AD. If it does, remove it. Must run remote command on server with AD Powershell commands installed
#########################
Enable-WSManCredSSP -Role Client -DelegateComputer SBC365ADSYNC01.stdbev.com -Force
$session = New-PSSession -cn SBC365ADSYNC01.stdbev.com -Credential $Creds -Authentication Credssp
Invoke-Command -Session $session -ScriptBlock {C:\OSDCloud\CheckADComputer.ps1}

Add-Computer -DomainName stdbev.com -Credential $Creds -OUPath $organizationalUnit -NewName $computerName -Force -Restart

Stop-Transcript













