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
$Creds = New-Object System.Management.Automation.PSCredential ("stdbev.com\intune.dem",$SecurePassword)

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

#########################
# See if computer exists in AD. If it does, remove it.
#########################
$organizationalUnit = "OU=Computers - STDBEV,DC=stdbev,DC=com"

# Find the computer in the specific OU
$computer = Get-ADComputer -Filter "Name -eq '$computerName'" -SearchBase $organizationalUnit

# Check if computer exists and remove it
if ($computer) {
    Write-Host "Computer '$computerName' found. Removing from Active Directory..."
    Remove-ADComputer -Identity $computer -Confirm:$false -Credential $Creds
    Write-Host "`nComputer '$computerName' has been removed."
    Write-Host "`nAdding computer '$computerName' to active directory."
} else {
    Write-Host "Computer '$computerName' not found in OU: $organizationalUnit"
    Write-Host "`nAdding computer '$computerName' to active directory."
}

Add-Computer -DomainName stdbev.com -Credential $Creds -OUPath $organizationalUnit -NewName $computerName -Force -Restart

Stop-Transcript








